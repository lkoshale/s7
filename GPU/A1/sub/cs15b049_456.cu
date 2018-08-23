#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>


//device kernel code
__global__ void vec_add( int* a, int* b,int* c,int N,int ops_per_thread){

    int idx = ( blockIdx.x * blockDim.x )+ threadIdx.x;

    for(int i=ops_per_thread*idx; i< ops_per_thread*(idx+1);i++){
        if(i<N)
            c[i]= a[i]+b[i];
    }

}

int main(int argc , char* argv[]){
    FILE* f1;
    FILE* f2;

      // set kernel prams
      int threads_per_block;
      int ops_per_thread;
      int N;
        

    if(argc>5){
        threads_per_block = atoi(argv[1]);
        ops_per_thread = atoi(argv[2]);
        N = atoi(argv[3]);
        f1= fopen(argv[4],"r");
        f2= fopen(argv[5],"r");

    }else
        return 0;
    

    int blocks_per_grid =  (N + (threads_per_block*ops_per_thread)-1)/(threads_per_block*ops_per_thread) ;

    // int N = 5;
    int size = sizeof(int)*N;
    int* h_A = (int*)malloc(size);
    int* h_B = (int*)malloc(size);
    int* h_C = (int*)malloc(size);

    //clock variable for measuring runtime
    clock_t begin, end;
	double timeSpent;

    //take input from file
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

  
    //start time
    begin  = clock();
    //invoke kernel
    vec_add<<<blocks_per_grid,threads_per_block>>>(d_A,d_B,d_C,N,ops_per_thread);
    //synchronise
    cudaDeviceSynchronize();
    //end time
    end = clock();

    timeSpent = (double)(end - begin) * 1000 / CLOCKS_PER_SEC;	// milliseconds

    //copy result array back to host
    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    //free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    printf("%lf\n",timeSpent);
}