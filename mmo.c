#include <omp.h>
#include "pollux.h"

#define NRA 62                 /* number of rows in matrix A */
#define NCA 15                 /* number of columns in matrix A */
#define NCB 7                  /* number of columns in matrix B */

int main (int argc, char *argv[]) 
{
	int **a, **b, **c;
	int ra, rb, ca, cb, tid, nt, i, j, k, chunk;
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
	scanf("%d ",&chunk);

#pragma omp parallel shared(a,b,c,ra, rb, ca, cb,nt,chunk) private(tid,i,j,k)
  {
  tid = omp_get_thread_num();
  if (tid == 0)
    {
    nt = omp_get_num_threads();
    printf("Threads: %d\n",nt);
    }

  printf("Thread %d starts to multiply...\n",tid);
  #pragma omp for schedule (static, chunk)
  for (i=0; i<ra; i++)    
    {
    printf("Thread %d working on row %d\n",tid,i);
    for(j=0; j<cb; j++)       
      for (k=0; k<ca; k++)
        c[i][j] += a[i][k] * b[k][j];
    }
  }

printf("\nResult:");
print_mat(c,ra,cb);

}
