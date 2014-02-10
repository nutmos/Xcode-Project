//
//  main.cpp
//  CPP
//
//  Created by Nattapong Mos on 26/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
using namespace std;

int main() {
    int n;
    scanf("%d",&n);
    char **str = new char*[n];
    for (int i = 0; i < n; ++i) {
        char *sub_str = new char[101];
        str[i] = sub_str;
        scanf("%s",sub_str);
    }
    for (int i = n-1; i >= 0; --i) {
        for (int j = 0; j < i; ++j) {
            //printf("%s cmp %s", str[j], str[j+1]);
            int cmp = strcmp(str[j], str[j+1]);
            if (cmp > 0) {
                char *tmp = str[j];
                str[j] = str[j+1];
                str[j+1] = tmp;
            }
        }
    }
    for (int i = 0; i < n; ++i) {
        printf("%s\n", str[i]);
    }
}