#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <cstring>
#include <math.h>

using namespace std;

int main() {
    int NN;
    scanf("%d",&NN);
    for (int II = 0; II < NN; ++II) {
        int n;
        scanf("%d",&n);
        char str[n][101];
        char str_tmp[n][101];
        int count[n][101];
        for (int i = 0; i < n; ++i) {
            scanf("%s",str[i]);
            int len = (int)strlen(str[i]), indicate = 0;
            str_tmp[i][0] = str[i][0];
            count[i][0] = 1;
            for (int j = 1; j < len; ++j) {
                if (str[i][j] != str[i][j-1]) {
                    ++indicate;
                    str_tmp[i][indicate] = str[i][j];
                    count[i][indicate] = 1;
                }
                else {
                    count[i][indicate] += 1;
                }
            }
            str_tmp[i][indicate+1] = '\0';
            printf("%s\n",str_tmp[i]);
        }
        bool canContinue = true;
        for (int i = 1; i < n; ++i) {
            if (strcmp(str_tmp[i], str_tmp[i-1]) != 0) {
                canContinue = false;
                break;
            }
        }
        if (canContinue == false) {
            printf("Case #%d: Fegla Won\n", II+1);
            continue;
        }
        int len = (int)strlen(str_tmp[0]);
        int reccommend[len];
        for (int i = 0; i < len; ++i) {
            int sum = 0, sumPow2 = 0;
            for (int j = 0; j < n; ++j) {
                sum += count[j][i];
                sumPow2 += count[j][i] * count[j][i];
            }
            float mean = sum/n;
            float tmp = sqrt((sumPow2/n)+mean*mean);
            if (fmod((tmp * 10), 10) >= 5) {
                reccommend[i] = (int)tmp + 1;
            }
            else {
                reccommend[i] = (int)tmp;
            }
            printf("reccommend[%d] = %d\n",i, reccommend[i]);
        }
        int countChange = 0;
        for (int i = 0; i < len; ++i) {
            for (int j = 0; j < n; ++j) {
                countChange += abs(count[j][i] - reccommend[i]);
            }
        }
        printf("Case #%d: %d\n", II+1, countChange);
    }
}
