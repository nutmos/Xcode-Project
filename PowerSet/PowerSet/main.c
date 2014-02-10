#include <stdio.h>
#include <math.h>

int to_base_2(int base10, int n){
    unsigned int ans = 0, base2[n],i;
    
    for(i=0; i < n; i++)
    {
        base2[i] = base10 % 2;
        base10 = base10 / 2;
    }
    
    for (i = 0; i < n; i++) {
        ans = ans + (base2[i] * pow(10,i));
    }
    
    return ans;
}

int main(){
    int n,po,bitint;
    double bit;
    int i,j;
    
    printf("Enter size of set: ");
    scanf("%d",&n);
    
    char ch[n];
    
    po = pow(2,n);
                      
    for (i = 0; i < n; i++) {
        printf("Enter Element: ");
        scanf("%d",&ch[i]);
    }
    
    printf("\n");
    
    int base2array[po];
    
    printf("{");
    
    for (i = 0; i < po; i++) {
        printf("{ ");
        base2array[i] = to_base_2(i, n);
        //printf("%d",base2array[i]);
        for (j = 0; j < n; j++) {
            bit = fmod((base2array[i] / pow(10,j)), 10);
            bitint = (int)bit;
            //printf("%d/",bitint);
            if (bitint == 1){
                printf("%d ",ch[j]);
            }
        }
        printf("}, ");
    }
    printf("}");
    
    return 0;
}

