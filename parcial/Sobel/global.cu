#include <stdio.h>
#include <stdlib.h>
#include <cv.h>
#include <sys/time.h>
#include <cuda.h>

using namespace cv;

__global__ unsigned char ajustar(int valor)
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

__global__ void filtro_sobel(unsigned char *origen, unsigned char *destino, char *kernel, int alto, int ancho)
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
				valor += kernel[j*3+i]*origen[y*ancho+x];
			}
		}
	}
	destino[fil*ancho+col] = ajustar(valor);
}

int main(int argc, char **argv)
{
	int alto, ancho, tamanno;
	char cpu_kernel[] = {-1,0,1,-2,0,2,-1,0,1}
	char *gpu_kernel;
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
	cudaMalloc((void**)&gpu_kernel,sizeof(char)*9);
	cudaMalloc((void**)&gpu_origen,tamanno);
	cudaMalloc((void**)&gpu_destino,tamanno);
	cpu_origen = imagen.data;

	gettimeofday(&inicio, NULL);
	
	cudaMemcpy(gpu_origen,cpu_origen,tamanno, cudaMemcpyHostToDevice);
	cudaMemcpy(gpu_kernel,cpu_kernel,sizeof(char)*9, cudaMemcpyHostToDevice);

	int t_bloque = 32;
	dim3 dim_bloque(t_bloque,t_bloque,1);
	dim3 dim_rejilla(ceil(ancho/float(t_bloque)),ceil(alto/float(t_bloque)),1);
	filtro_sobel<<<dim_rejilla,dim_bloque>>>(gpu_origen, gpu_destino, gpu_kernel, alto, ancho);
	cudaDeviceSynchronize();

	cudaMemcpy(cpu_destino,gpu_destino,tamanno, cudaMemcpyDeviceToHost);

	gettimeofday(&fin, NULL);
	tiempo = ((fin.tv_sec  - inicio.tv_sec) * 1000000u + fin.tv_usec - inicio.tv_usec) / 1.e6;
	printf("%f\n",tiempo);		

	Mat resultado;
	resultado.create(alto,ancho,CV_8UC1);
	resultado.data = cpu_destino;
	nombre_resultado = strcat(nombre_imagen,".sobel_global.jpg");
	imwrite("./sobel_global.jpg",resultado);
	
	free(cpu_origen);
	free(cpu_destino);
	cudaFree(gpu_kernel);
	cudaFree(gpu_origen);
	cudaFree(gpu_destino);
	
	return 0;
}