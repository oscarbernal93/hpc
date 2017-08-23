#include <omp.h>
#include <time.h>
#include "pollux.h"

#define SIZE 100

int main (int argc, char *argv[]) 
{
	if (2 != argc ) {
	    printf("Wrong number of arguments, remember to provide the chunk size\n");
	    return 1;
	}
	int **a, **b, **c;
	int tid, nt, id, i, j, k;
	int s = SIZE, chunk = atoi(argv[1]); 

	reserve_mat(&a,s,s);
	reserve_mat(&b,s,s);
	reserve_mat(&c,s,s);
	
	fill_mat(a ,s ,s);
	fill_mat(b ,s ,s);	
	
	clock_t begin = clock();
	
	#pragma omp parallel shared(a,b,c,s,nt,chunk) private(id,i,j,k)
	{
	//id = omp_get_thread_num();
	//nt = omp_get_num_threads();

	#pragma omp for schedule (dynamic, chunk)
	for(i=0; i<s; ++i)
		for(j=0; j<s; ++j)
		    for(k=0; k<s; ++k)
		    {
		        c[i][j]+=a[i][k]*b[k][j];
		    }
	}

	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	
	printf("%f\n",time_spent);
	free_mat(a,s);
	free_mat(b,s);
	free_mat(c,s);

}
