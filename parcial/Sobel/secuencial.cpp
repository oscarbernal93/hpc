#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <cv.h>
#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
 
using namespace cv;

int main(int argc, char **argv)
{
	int alto, ancho, tamanno;
	char *nombre_imagen = argv[1];
	char *nombre_resultado;
	nombre_resultado = (char*)malloc(sizeof(char)*255);
	struct timeval inicio, fin; 
	double tiempo;

	Mat imagen;
	Mat resultado;
	
	imagen = imread(nombre_imagen, CV_LOAD_IMAGE_GRAYSCALE);
	Size t_imagen = imagen.size();
	alto = t_imagen.height;
	ancho = t_imagen.width;
	tamanno = sizeof(unsigned char)*alto*ancho;

	gettimeofday(&inicio, NULL);
	
	Sobel(imagen, resultado, CV_8U, 1, 0);
	
	gettimeofday(&fin, NULL);
	tiempo = ((fin.tv_sec  - inicio.tv_sec) * 1000000u + fin.tv_usec - inicio.tv_usec) / 1.e6;
	printf("%f\n",tiempo);	
	
	nombre_resultado = strcat(nombre_imagen,".seq.jpg");
	imwrite(nombre_resultado,resultado);
	
	return 0;
}
