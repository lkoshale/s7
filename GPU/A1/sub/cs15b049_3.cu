#include <stdio.h>
#include <stdlib.h>


//device kernel code
__global__ void vec_add( int* a, int* b,int* c,int N){

    int i = ( blockIdx.x * blockDim.x )+ threadIdx.x;

    if(i<N)
        c[i]= a[i]+b[i];

}

int main(int argc , char* argv[]){
    FILE* f1;
    FILE* f2;
    if(argc>2){
        f1= fopen(argv[1],"r");
        f2= fopen(argv[2],"r");
    }else
        return 0;
    

    int N = 32768;
    // int N = 5;
    int size = sizeof(int)*N;
    int* h_A = (int*)malloc(size);
    int* h_B = (int*)malloc(size);
    int* h_C = (int*)malloc(size);

    int i=0;
    for(i=0;i<N;i++){
        fscanf(f1,"%d\n",&h_A[i]);
        fscanf(f2,"%d\n",&h_B[i]);
    }

    // Allocate vectors in device memory
    int* d_A;
    cudaMalloc(&d_A,size);
    int* d_B;
    cudaMalloc(&d_B,size);
    int* d_C;
    cudaMalloc(&d_C,size);

    //copy to device
    cudaMemcpy(d_A,h_A,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,h_B,size,cudaMemcpyHostToDevice);

    // set kernel prams
    int threads_per_block = 256;
    int blocks_per_grid = 128;
    
    vec_add<<<blocks_per_grid,threads_per_block>>>(d_A,d_B,d_C,N);

    //copy result array back to host
    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    FILE* out = fopen("cs15b049_3_out.txt","w");
    for(int i=0;i<N;i++){
        fprintf(out,"%d %d %d\n",h_A[i],h_B[i],h_C[i]);
    }

}