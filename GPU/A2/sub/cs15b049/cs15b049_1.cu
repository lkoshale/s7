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
    FILE *f = fopen(fname, "a");
 
    for(unsigned i=0; i < numRows; i++)
    {
        for(unsigned j=0; j < numCols; j++)
            fprintf(f,"%4.4f ", mat[i*numCols + j]);
        
            fprintf(f,"\n");
    }
    fclose(f);
}

__global__ void MatrixMulKernelA(double* M, double* N, double* P, int Width) {
    
    // Calculate the row index of the P element and M
    int Row = blockIdx.y*blockDim.y+threadIdx.y;
    // Calculate the column index of P and N
    int Col = blockIdx.x*blockDim.x+threadIdx.x;
    
    if ((Row < Width) && (Col < Width)) {
        double Pvalue = 0;
        // each thread computes one element of the block sub-matrix
        for (int k = 0; k < Width; ++k) {
            Pvalue += M[Row*Width+k]*N[k*Width+Col];
        }
        P[Row*Width+Col] = Pvalue;
    }

}



__global__ void MatrixMulKernelB(double* M, double* N, double* P, int Width) {
    
    // Calculate the row index of the P element and M
    int Row = blockIdx.y*blockDim.y+threadIdx.y;
    // Calculate the column index of P and N
    int Col = blockIdx.x*blockDim.x+threadIdx.x;
    
    if ((Row < Width) && (Col < Width)) {
        double Pvalue = 0;
        // each thread computes one element of the block sub-matrix
        for (int k = 0; k < Width; ++k) {
            Pvalue += M[Row*Width+k]*N[k*Width+Col];
        }
        P[Row*Width+Col] = Pvalue;
    }

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

    MatrixMulKernelA<<<blocks,threads>>>(d_A,d_B,d_C,N);

    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    print_matrix_to_file(h_C,N,N);

    MatrixMulKernelB<<<blocks,threads>>>(d_A,d_B,d_C,N);

    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    print_matrix_to_file(h_C,N,N);
}