#include <stdio.h>

int addByFive(int a){
     int num;
     int five;
     five = 5;
     num = a + five;
     return num;
}

int mulBy2(int b){
    int num;
    num = b * 2;
    return num;
}

void main(){
    int num;
    num = 3;
    num = addByFive(num);
    num = mulBy2(num);
    printf("num value: %d\n",num);
}
