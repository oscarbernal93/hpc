#include <stdio.h>
#include <stdlib.h>

void print_mat( int **m ,int rows ,int cols  )
{
    int i,j;
    printf("\n");
    for(i=0; i<rows; ++i)
        for(j=0; j<cols; ++j)
        {
            printf("%d ", m[i][j]);
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

int main()
{
    int **a, **b, **r, ra, ca, rb, cb, i, j, k;

    printf("Size of first matrix: ");
    scanf("%d %d", &ra, &ca);

    printf("Size of second matrix: ");
    scanf("%d %d",&rb, &cb);

    reserve_mat(&a,ra,ca);
    reserve_mat(&b,rb,cb);
    reserve_mat(&r,ra,cb);

    //print_mat(a,ra,ca);
    //print_mat(b,rb,cb);
    //print_mat(r,ra,cb);

    if(ca != rb)
    {
	printf("Error! column of first matrix not equal to row of second one.\n");
	return 0;
    }
    
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

    return 0;
}