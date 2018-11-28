#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>

#define TILE_WIDTH 16


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


//using tiling
__global__ void MatrixMulKernel(double* M, double* N, double* P, int Width){
    
    __shared__ double ds_M[TILE_WIDTH][TILE_WIDTH];
    __shared__ double ds_N[TILE_WIDTH][TILE_WIDTH];


    int bx = blockIdx.x; 
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int Row = by * blockDim.y+ty; 
    int Col = bx * blockDim.x+tx;

    double Pvalue = 0;

    // Loop over the M and N tiles required to compute the P element
    for (int p = 0; p < Width/TILE_WIDTH; ++p) {
        // Collaborative loading of M and N tiles into shared memory
        ds_M[ty][tx] = M[Row*Width + p*TILE_WIDTH+tx];
        ds_N[ty][tx] = N[(p*TILE_WIDTH+ty)*Width + Col];
        
        __syncthreads();
        
        for (int i = 0; i < TILE_WIDTH; ++i)
            Pvalue += ds_M[ty][i] * ds_N[i][tx];
        __syncthreads();
    }
    P[Row*Width+Col] = Pvalue;

}

int main(){
    int N = 8192;
    int size =  sizeof(double)*N*N;
    double* h_A = (double*)malloc(size);
    double* h_B = (double*)malloc(size);
    double* h_C = (double*)malloc(size);

    fill_matrix(h_A,N,N);
    fill_matrix(h_B,N,N);

    double* d_A;
    double* d_B;
    double* d_C;

    cudaMalloc(&d_A,size);
    cudaMalloc(&d_B,size);
    cudaMalloc(&d_C,size);

    //copy to device
    cudaMemcpy(d_A,h_A,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,h_B,size,cudaMemcpyHostToDevice);

    dim3 threads(16,16);
    dim3 blocks(512,512);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    MatrixMulKernel<<<blocks,threads>>>(d_A,d_B,d_C,N);

    cudaEventRecord(stop);

    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop); 
    printf("%lf\n",milliseconds);

    print_matrix_to_file(h_C,N,N);

}