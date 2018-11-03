#include <stdio.h>

int f_1(int k){
  printf("f_1");
  return k;
}

int f_2(int k){
  int i;
  printf("f_2");
  i = 2;
  i = i - k;
  return i;
}

int f_3(int j){
  int val;
  printf("f_3");
  val = 2;
  return val;
}

void main(){
  int i,j,k;
  int a,b,c;
  i = 0;
  j = 2;
  k = i + j;
  a = f_1(k);
  printf("%d\n", a);
  b = f_2(a);
  printf("%d\n", b);
  c = f_3(b);
  printf("%d\n", c);
}
