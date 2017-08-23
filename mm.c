#include "pollux.h"
#include <time.h>

#define SIZE 1000

int main()
{
    int **a, **b, **r;
    int i, j, k;
    int s = SIZE;

    reserve_mat(&a,s,s);
    reserve_mat(&b,s,s);
    reserve_mat(&r,s,s);
    
    fill_mat(a ,s ,s);
    fill_mat(b ,s ,s);

    clock_t begin = clock();

    for(i=0; i<s; ++i)
        for(j=0; j<s; ++j)
            for(k=0; k<s; ++k)
            {
                r[i][j]+=a[i][k]*b[k][j];
            }

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    
    printf("Time Spent: %f\n",time_spent);
    free_mat(a,s);
    free_mat(b,s);
    free_mat(r,s);
    return 0;
}
