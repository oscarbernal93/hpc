#include "pollux.h"
#include <sys/time.h>

#define SIZE 100

int main()
{
    int **a, **b, **r;
    int i, j, k;
    int s = SIZE;

    struct timeval start, end;

    reserve_mat(&a,s,s);
    reserve_mat(&b,s,s);
    reserve_mat(&r,s,s);
    
    fill_mat(a ,s ,s);
    fill_mat(b ,s ,s);

    gettimeofday(&end, NULL);

    for(i=0; i<s; ++i)
        for(j=0; j<s; ++j)
            for(k=0; k<s; ++k)
            {
                r[i][j]+=a[i][k]*b[k][j];
            }

    gettimeofday(&end, NULL);
    double delta = ((end.tv_sec  - start.tv_sec) * 1000000u + end.tv_usec - start.tv_usec) / 1.e6;
    
    printf("%f\n",delta);
    free_mat(a,s);
    free_mat(b,s);
    free_mat(r,s);
    return 0;
}
