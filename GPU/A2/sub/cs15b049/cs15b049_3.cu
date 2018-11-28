#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>

#define MAT_SIZE_A 32
#define BLOCK_DIM_A 16


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

__global__ void kernelA(double* M, double* N, double* P) {

    __shared__ double ds_M[BLOCK_DIM_A][MAT_SIZE_A];
    __shared__ double ds_N[BLOCK_DIM_A][MAT_SIZE_A];

    int Width = MAT_SIZE_A;
    int bx = blockIdx.x;  int by = blockIdx.y;
    int tx = threadIdx.x; int ty = threadIdx.y;
    
    // Calculate the row index of the P element and M
    int Row = by*blockDim.y+ty;
    // Calculate the column index of P and N
    int Col = bx*blockDim.x+tx;


    int px = Width/blockDim.x;
    int py = Width/blockDim.y;

    if( (Row<Width) && (Col<Width) ){

        //load your part of rows from M
        for(int i=0;i<px;i++){
            ds_M[ty][tx*px+i] = M[(Row*Width)+(tx*px)+i];
        }

        //load your part of cols from N
        //as transpose matrix
        for(int i=0;i<py;i++){
            int idx = (ty*py+i)*Width+Col;
            ds_N[tx][ty*py+i] = N[idx];
        }

        __syncthreads();


        double Pvalue = 0;
        //compute multiplication each thread individually
        // Row*Col'
        for(int i=0 ;i<Width;++i ){
            Pvalue+= ds_M[tx][i] * ds_N[ty][i];
        }
        
        P[Row*Width+Col]=Pvalue;
        
    }
}


int main(){

    int N = MAT_SIZE_A;
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

    dim3 threads(BLOCK_DIM_A,BLOCK_DIM_A);

    int block_per_grid = (N +BLOCK_DIM_A -1)/ BLOCK_DIM_A;

    dim3 blocks(block_per_grid,block_per_grid);

    //invoke kernel
    kernelA<<<blocks,threads>>>(d_A,d_B,d_C);

    cudaMemcpy(h_C,d_C,size,cudaMemcpyDeviceToHost);

    print_matrix_to_file(h_C,N,N);

}