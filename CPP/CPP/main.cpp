//
//  main.cpp
//  CPP
//
//  Created by Nattapong Mos on 26/12/56.
//  Copyright (c) พ.ศ. 2556 Nattapong Mos. All rights reserved.
//

#include <iostream>
#include <stack>

using namespace std;

int main() {
    stack<int> stk;
    stk.push(5);
    cout << stk.top() << endl;
    stk.pop();
    cout << stk.empty();
}