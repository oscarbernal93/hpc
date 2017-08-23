#include "pollux.h"
#include <time.h>

#define SIZE 1000

int main()
{
    int **a, **b, **r;
    int ra, ca, rb, cb, i, j, k;

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
    reserve_mat(&r,ra,cb);
    
    fill_mat(a ,ra ,ca);
    fill_mat(b ,rb ,cb);

    clock_t begin = clock();

    for(i=0; i<ra; ++i)
        for(j=0; j<cb; ++j)
            for(k=0; k<rb; ++k)
            {
                r[i][j]+=a[i][k]*b[k][j];
            }

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    
    printf("Spent: %f\n",time_spent);
    free_mat(a,ra);
    free_mat(b,rb);
    free_mat(r,ra);
    return 0;
}
