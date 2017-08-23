#ifndef _POLLUX_HH_
  #define _POLLUX_HH_

#include <stdio.h>
#include <stdlib.h>

#define ZERO 0

//print to stdin the matrix
void print_mat( int **m ,int rows ,int cols  );

//reserve memory to the matrix
void reserve_mat( int ***mat, int rows ,int cols );

//free memory of the matrix
void free_mat( int **mat, int rows);

//fill the matrix whit 1~9 numbers
void fill_mat(int **mat ,int rows ,int cols);
#endif
