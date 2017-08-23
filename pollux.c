#include "pollux.h"

void print_mat( int **mat ,int rows ,int cols  )
{
    int i,j;
    printf("\n");
    for(i=0; i<rows; ++i)
        for(j=0; j<cols; ++j)
        {
            printf("%d ", mat[i][j]);
            if(j == cols-1)
                printf("\n");
        }
}

void reserve_mat( int ***mat, int rows ,int cols )
{
int i;
*mat = (int **)malloc(rows * sizeof(int*));
for(i = 0; i < rows; i++) (*mat)[i] = (int *)calloc(cols, sizeof(int));
}

void free_mat( int **mat, int rows)
{
int i;
for(i = 0; i < rows; i++) free(mat[i]);
free(mat);
}

void fill_mat(int **mat ,int rows ,int cols)
{
    int i,j;
    for (i=0; i<rows; i++)
    {
        for (j=0; j<cols; j++)
        {
            mat[i][j]= rand() % 10;
        }
    }
}

