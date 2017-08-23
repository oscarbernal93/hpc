#include "pollux.h"

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
    
    printf("Elements of first matrix:\n");
    for(i=0; i<ra; ++i)
        for(j=0; j<ca; ++j)
        {
            scanf("%d", &a[i][j]);
        }

    printf("Elements of second matrix:\n");
    for(i=0; i<rb; ++i)
        for(j=0; j<cb; ++j)
        {
            scanf("%d", &b[i][j]);
        }

    printf("\nFirst:");
    print_mat(a,ra,ca);
    printf("\nSecond:");
    print_mat(b,rb,cb);

    for(i=0; i<ra; ++i)
        for(j=0; j<cb; ++j)
            for(k=0; k<rb; ++k)
            {
                r[i][j]+=a[i][k]*b[k][j];
            }
    
    printf("\nResult:");
    print_mat(r,ra,cb);

    free_mat(a,ra);
    free_mat(b,rb);
    free_mat(r,ra);
    return 0;
}
