#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <cv.h>
#include <sys/time.h>
#include <cuda.h>

using namespace cv;

__constant__ char gpu_kernel[9];

__device__ unsigned char ajustar(int valor)
{
	if(valor < 0)
	{
		valor = 0;
	}
	else if(valor > 255)
	{
		valor = 255;
	}
    return (unsigned char)valor;
}

__global__ void filtro_sobel(unsigned char *origen, unsigned char *destino, int alto, int ancho)
{
	__shared__ float chunk[1156];
	int posicion_chunk,c_y,c_x,y,x,i,j,col,fil;
	for(int a = 0; a <= 1024; a +=1024)
	{
		posicion_chunk = threadIdx.y*32+threadIdx.x + a;
		c_y = posicion_chunk / (34);
		c_x = posicion_chunk % (34);
		y = blockIdx.y * 32 + c_y - 1;
		x = blockIdx.x * 32 + c_x - 1;
		if(c_x < 34 && c_y < 34){
			if (x >= 0 && y >= 0 && x < ancho && y < alto)
			{
				chunk[c_y*34+c_x] = origen[y * ancho + x];
			}
			else
			{
				chunk[c_y*34+c_x] = 0;
			}
		}
	}
	__syncthreads();
	int valor = 0;
	for(i = 0; i <= 2; i++)
	{
		for(j = 0; j <= 2; j++)
		{
			valor += gpu_kernel[j*3+i]*chunk[(threadIdx.y+j)*34+threadIdx.x+i];
	    	}
	}
	col = blockIdx.x * 32 + threadIdx.x;
	fil = blockIdx.y * 32 + threadIdx.y;
	if (x >= 0 && y >= 0 && x < ancho && y < alto)
		destino[fil*ancho+col] = ajustar(valor);
	__syncthreads();
}

int main(int argc, char **argv)
{
	cudaError_t mi_error = cudaSuccess;
	int alto, ancho, tamanno;
	char cpu_kernel[] = {-1,0,1,-2,0,2,-1,0,1};
	char *nombre_imagen = argv[1];
	char *nombre_resultado;
	nombre_resultado = (char*)malloc(sizeof(char)*255);
	unsigned char *cpu_origen, *cpu_destino;
	unsigned char *gpu_origen, *gpu_destino;
	struct timeval inicio, fin; 
	double tiempo;

	Mat imagen;
	imagen = imread(nombre_imagen, CV_LOAD_IMAGE_GRAYSCALE);
	Size t_imagen = imagen.size();
	alto = t_imagen.height;
	ancho = t_imagen.width;
	tamanno = sizeof(unsigned char)*alto*ancho;

	cpu_origen = (unsigned char*)malloc(tamanno);
	cpu_destino = (unsigned char*)malloc(tamanno);
	mi_error = cudaMemcpyToSymbol(gpu_kernel,cpu_kernel,sizeof(char)*9);
	if(mi_error != cudaSuccess){printf("Error con kernel\n");exit(-1);}
	mi_error = cudaMalloc((void**)&gpu_origen,tamanno);
	if(mi_error != cudaSuccess){printf("Error con origen\n");exit(-1);}
	mi_error = cudaMalloc((void**)&gpu_destino,tamanno);
	if(mi_error != cudaSuccess){printf("Error con destino\n");exit(-1);}
	cpu_origen = imagen.data;

	gettimeofday(&inicio, NULL);
	
	mi_error = cudaMemcpy(gpu_origen,cpu_origen,tamanno, cudaMemcpyHostToDevice);
	if(mi_error != cudaSuccess){printf("Error copiando origen\n");exit(-1);}

	int t_bloque = 32;	
	dim3 dim_bloque(t_bloque,t_bloque,1);
	dim3 dim_rejilla(ceil(ancho/float(t_bloque)),ceil(alto/float(t_bloque)),1);
	filtro_sobel<<<dim_rejilla,dim_bloque>>>(gpu_origen, gpu_destino, alto, ancho);
	cudaDeviceSynchronize();

	mi_error = cudaMemcpy(cpu_destino,gpu_destino,tamanno, cudaMemcpyDeviceToHost);
	if(mi_error != cudaSuccess){printf("Error copiando destino: %s\n",cudaGetErrorString(mi_error));exit(-1);}
	gettimeofday(&fin, NULL);
	tiempo = ((fin.tv_sec  - inicio.tv_sec) * 1000000u + fin.tv_usec - inicio.tv_usec) / 1.e6;
	printf("%f\n",tiempo);		

	Mat resultado;
	resultado.create(alto,ancho,CV_8UC1);
	resultado.data = cpu_destino;
	nombre_resultado = strcat(nombre_imagen,".comp.jpg");
	imwrite(nombre_resultado,resultado);
	
	//free(cpu_origen);
	//free(cpu_destino);
	cudaFree(gpu_origen);
	cudaFree(gpu_destino);
	
	return 0;
}
