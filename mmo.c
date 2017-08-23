#include <omp.h>
#include <time.h>
#include "pollux.h"

#define SIZE 1000

int main (int argc, char *argv[]) 
{
	int **a, **b, **c;
	int ra, rb, ca, cb, tid, nt, id, i, j, k,chunk;
	printf("Size of first matrix: ");
	scanf("%d %d", &ra, &ca);
	printf("Size of second matrix: ");
	scanf("%d %d",&rb, &cb);

	if(ca != rb)
	{
		printf("Error! column of first matrix not equal to row of second one.\n");
		return 0;
	}
	
	reserve_mat(&a,ra,ca);
	reserve_mat(&b,rb,cb);
	reserve_mat(&c,ra,cb);
	
	fill_mat(a ,ra ,ca);
	fill_mat(b ,rb ,cb);	

	printf("Size of chunk: ");
	scanf("%d",&chunk);
	
	clock_t begin = clock();
	
	#pragma omp parallel shared(a,b,c,ra, rb, ca, cb,nt,chunk) private(id,i,j,k)
	{
	//id = omp_get_thread_num();
	//nt = omp_get_num_threads();

	#pragma omp for schedule (static, chunk)
	for(i=0; i<ra; ++i)
		for(j=0; j<cb; ++j)
		    for(k=0; k<rb; ++k)
		    {
		        c[i][j]+=a[i][k]*b[k][j];
		    }
	}

	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	
	printf("Spent: %f\n",time_spent);
	free_mat(a,ra);
	free_mat(b,rb);
	free_mat(c,ra);

}
