#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>

void fill_matrix(double *mat, unsigned numRows, unsigned numCols)
{
    for(unsigned i=0; i < numRows; i++)
        for(unsigned j=0; j < numCols; j++){
             mat[i*numCols + j] = i*2.1f + j*3.2f;
        }
}

void print_matrix_to_file(double *mat,unsigned numRows,unsigned numCols){
    const char *fname = "assignment2_out";
    FILE *f = fopen(fname, "w");
 
    for(unsigned i=0; i < numRows; i++)
    {
        for(unsigned j=0; j < numCols; j++)
            fprintf(f,"%4.4f ", mat[i*numCols + j]);
        
            fprintf(f,"\n");
    }
    fclose(f);
}

__global__ void MatrixMulKernel(double* M, double* N, double* P, int M_W,int N_W,int K_W) {
    
    // Calculate the row index of the P element and M
    int Row = blockIdx.y*blockDim.y+threadIdx.y;
    // Calculate the column index of P and N
    int Col = blockIdx.x*blockDim.x+threadIdx.x;
    
    if ((Row < M_W) && (Col < K_W)) {
        double Pvalue = 0;
        // each thread computes one element of the block sub-matrix
        for (int k = 0; k < N_W; ++k) {
            Pvalue += M[Row*N_W+k]*N[k*K_W+Col];
        }
        P[Row*K_W+Col] = Pvalue;
    }

}


int main(){
    int M = 4096;
    int N = 8192;
    int K = 16384;
    int size_A =  sizeof(double)*M*N;
    int size_B =  sizeof(double)*N*K;
    int size_C =  sizeof(double)*M*K;
    double* h_A = (double*)malloc(size_A);
    double* h_B = (double*)malloc(size_B);
    double* h_C = (double*)malloc(size_C);

    fill_matrix(h_A,M,N);
    fill_matrix(h_B,N,K);

    double* d_A;
    double* d_B;
    double* d_C;

    cudaMalloc(&d_A,size_A);
    cudaMalloc(&d_B,size_B);
    cudaMalloc(&d_C,size_C);

    //copy to device
    cudaMemcpy(d_A,h_A,size_A,cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,h_B,size_B,cudaMemcpyHostToDevice);

    int thread_x = 16;
    dim3 threads(thread_x,thread_x);
    int block_x = (M + thread_x -1)/thread_x;
    int block_y = (K + thread_x -1)/thread_x;
    dim3 blocks(block_y,block_x);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    MatrixMulKernel<<<blocks,threads>>>(d_A,d_B,d_C,M,N,K);

    cudaEventRecord(stop);

    cudaMemcpy(h_C,d_C,size_C,cudaMemcpyDeviceToHost);


    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop); 
    printf("%lf\n",milliseconds);

    print_matrix_to_file(h_C,M,K);

}