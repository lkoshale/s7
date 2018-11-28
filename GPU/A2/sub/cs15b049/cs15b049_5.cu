#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>

#define TILE_WIDTH_A 4
#define TILE_WIDTH_B 8
#define TILE_WIDTH_C 16
#define TILE_WIDTH_D 32

void fill_matrix(double *mat, unsigned numRows, unsigned numCols)
{
    for(unsigned i=0; i < numRows; i++)
        for(unsigned j=0; j < numCols; j++){
             mat[i*numCols + j] = i*2.1f + j*3.2f;
        }
}

void print_matrix_to_file(double *mat,unsigned numRows,unsigned numCols){
    const char *fname = "assignment2_out";
    FILE *f = fopen(fname, "a");
 
    for(unsigned i=0; i < numRows; i++)
    {
        for(unsigned j=0; j < numCols; j++)
            fprintf(f,"%4.4f ", mat[i*numCols + j]);
        
            fprintf(f,"\n");
    }
    fclose(f);
}


//using tiling
__global__ void KernelA(double* M, double* N, double* P, int Width){
    
    __shared__ double ds_M[TILE_WIDTH_A][TILE_WIDTH_A];
    __shared__ double ds_N[TILE_WIDTH_A][TILE_WIDTH_A];


    int bx = blockIdx.x; 
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int Row = by * blockDim.y+ty; 
    int Col = bx * blockDim.x+tx;

    double Pvalue = 0;

    // Loop over the M and N tiles required to compute the P element
    for (int p = 0; p < Width/TILE_WIDTH_A; ++p) {
        // Collaborative loading of M and N tiles into shared memory
        ds_M[ty][tx] = M[Row*Width + (p*TILE_WIDTH_A)+tx];
        ds_N[ty][tx] = N[((p*TILE_WIDTH_A)+ty)*Width + Col];
        
        __syncthreads();
        
        for (int i = 0; i < TILE_WIDTH_A; ++i)
            Pvalue += ds_M[ty][i] * ds_N[i][tx];
        __syncthreads();
    }
    P[Row*Width+Col] = Pvalue;

}

__global__ void KernelB(double* M, double* N, double* P, int Width){
    
    __shared__ double ds_M[TILE_WIDTH_B][TILE_WIDTH_B];
    __shared__ double ds_N[TILE_WIDTH_B][TILE_WIDTH_B];


    int bx = blockIdx.x; 
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int Row = by * blockDim.y+ty; 
    int Col = bx * blockDim.x+tx;

    double Pvalue = 0;

    // Loop over the M and N tiles required to compute the P element
    for (int p = 0; p < Width/TILE_WIDTH_B; ++p) {
        // Collaborative loading of M and N tiles into shared memory
        ds_M[ty][tx] = M[Row*Width + p*TILE_WIDTH_B+tx];
        ds_N[ty][tx] = N[(p*TILE_WIDTH_B+ty)*Width + Col];
        
        __syncthreads();
        
        for (int i = 0; i < TILE_WIDTH_B; ++i)
            Pvalue += ds_M[ty][i] * ds_N[i][tx];
        __syncthreads();
    }
    P[Row*Width+Col] = Pvalue;

}

__global__ void KernelC(double* M, double* N, double* P, int Width){
    
    __shared__ double ds_M[TILE_WIDTH_C][TILE_WIDTH_C];
    __shared__ double ds_N[TILE_WIDTH_C][TILE_WIDTH_C];


    int bx = blockIdx.x; 
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int Row = by * blockDim.y+ty; 
    int Col = bx * blockDim.x+tx;

    double Pvalue = 0;

    // Loop over the M and N tiles required to compute the P element
    for (int p = 0; p < Width/TILE_WIDTH_C; ++p) {
        // Collaborative loading of M and N tiles into shared memory
        ds_M[ty][tx] = M[Row*Width + p*TILE_WIDTH_C+tx];
        ds_N[ty][tx] = N[(p*TILE_WIDTH_C+ty)*Width + Col];
        
        __syncthreads();
        
        for (int i = 0; i < TILE_WIDTH_C; ++i)
            Pvalue += ds_M[ty][i] * ds_N[i][tx];
        __syncthreads();
    }
    P[Row*Width+Col] = Pvalue;

}

__global__ void KernelD(double* M, double* N, double* P, int Width){
    
    __shared__ double ds_M[TILE_WIDTH_D][TILE_WIDTH_D];
    __shared__ double ds_N[TILE_WIDTH_D][TILE_WIDTH_D];


    int bx = blockIdx.x; 
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int Row = by * blockDim.y+ty; 
    int Col = bx * blockDim.x+tx;

    double Pvalue = 0;

    // Loop over the M and N tiles required to compute the P element
    for (int p = 0; p < Width/TILE_WIDTH_D; ++p) {
        // Collaborative loading of M and N tiles into shared memory
        ds_M[ty][tx] = M[Row*Width + p*TILE_WIDTH_D+tx];
        ds_N[ty][tx] = N[(p*TILE_WIDTH_D+ty)*Width + Col];
        
        __syncthreads();
        
        for (int i = 0; i < TILE_WIDTH_D; ++i)
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

    cudaEvent_t startA, stopA;
    cudaEvent_t startB, stopB;
    cudaEvent_t startC, stopC;
    cudaEvent_t startD, stopD;

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

    {
        dim3 threads(TILE_WIDTH_A,TILE_WIDTH_A);
        int b_wid = (N + TILE_WIDTH_A - 1)/TILE_WIDTH_A ;
        dim3 blocks(b_wid,b_wid);
        cudaEventCreate(&startA);
        cudaEventCreate(&stopA);

        cudaEventRecord(startA);

        KernelA<<<blocks,threads>>>(d_A,d_B,d_C,N);

        cudaEventRecord(stopA);

        cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

        cudaEventSynchronize(stopA);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, startA, stopA); 
        printf("%lf\n",milliseconds);

        print_matrix_to_file(h_C,N,N);

    }

    {
        dim3 threads(TILE_WIDTH_B,TILE_WIDTH_B);
        int b_wid = (N + TILE_WIDTH_B - 1)/TILE_WIDTH_B ;
        dim3 blocks(b_wid,b_wid);
        cudaEventCreate(&startB);
        cudaEventCreate(&stopB);

        cudaEventRecord(startB);

        KernelB<<<blocks,threads>>>(d_A,d_B,d_C,N);

        cudaEventRecord(stopB);

        cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

        cudaEventSynchronize(stopB);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, startB, stopB); 
        printf("%lf\n",milliseconds);

        print_matrix_to_file(h_C,N,N);

    }

    {
        dim3 threads(TILE_WIDTH_C,TILE_WIDTH_C);
        int b_wid = (N + TILE_WIDTH_C - 1)/TILE_WIDTH_C ;
        dim3 blocks(b_wid,b_wid);
        cudaEventCreate(&startC);
        cudaEventCreate(&stopC);

        cudaEventRecord(startC);

        KernelC<<<blocks,threads>>>(d_A,d_B,d_C,N);

        cudaEventRecord(stopC);

        cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

        cudaEventSynchronize(stopC);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, startC, stopC); 
        printf("%lf\n",milliseconds);

        print_matrix_to_file(h_C,N,N);

    }

    {
        dim3 threads(TILE_WIDTH_D,TILE_WIDTH_D);
        int b_wid = (N + TILE_WIDTH_D - 1)/TILE_WIDTH_D ;
        dim3 blocks(b_wid,b_wid);
        cudaEventCreate(&startD);
        cudaEventCreate(&stopD);

        cudaEventRecord(startD);

        KernelD<<<blocks,threads>>>(d_A,d_B,d_C,N);

        cudaEventRecord(stopD);

        cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

        cudaEventSynchronize(stopD);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, startD, stopD); 
        printf("%lf\n",milliseconds);

        print_matrix_to_file(h_C,N,N);

    }
}