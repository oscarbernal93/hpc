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
	int i,j,x,y;
	int valor = 0;
	unsigned int col = blockIdx.x*blockDim.x+threadIdx.x;
	unsigned int fil = blockIdx.y*blockDim.y+threadIdx.y;
	
	for(i = 0; i <= 2; i++)
	{
		for(j = 0; j <= 2; j++)
		{
			x=col + i - 1;
			y=fil + j - 1;
			if(x >= 0 && y >= 0 && x < ancho && y < alto)
			{
				valor += (gpu_kernel[j*3+i])*(origen[y*ancho+x]);
			}
		}
	}
	destino[fil*ancho+col] = ajustar(valor);
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
	if(mi_error != cudaSuccess){printf("Error copiando origen primero \n");exit(-1);}
	
	int t_bloque = 32;
	dim3 dim_bloque(t_bloque,t_bloque,1);
	dim3 dim_rejilla(ceil(ancho/float(t_bloque)),ceil(alto/float(t_bloque)),1);
	filtro_sobel<<<dim_rejilla,dim_bloque>>>(gpu_origen, gpu_destino, alto, ancho);

	mi_error = cudaMemcpy(cpu_destino,gpu_destino,tamanno, cudaMemcpyDeviceToHost);
	if(mi_error != cudaSuccess){printf("Error con \n");exit(-1);}
	gettimeofday(&fin, NULL);
	tiempo = ((fin.tv_sec  - inicio.tv_sec) * 1000000u + fin.tv_usec - inicio.tv_usec) / 1.e6;
	printf("%f\n",tiempo);		

	Mat resultado;
	resultado.create(alto,ancho,CV_8UC1);
	resultado.data = cpu_destino;
	nombre_resultado = strcat(nombre_imagen,".const.jpg");
	imwrite(nombre_resultado,resultado);
	
	//free(cpu_origen);
	//free(cpu_destino);
	cudaFree(gpu_origen);
	cudaFree(gpu_destino);
	
	return 0;
}
