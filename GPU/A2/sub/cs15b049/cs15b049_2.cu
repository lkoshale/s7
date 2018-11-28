#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>
#include<string.h>

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

__global__ void MatrixMulKernel(double* M, double* N, double* P, int Width) {
    
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


int main(int argc,char* argv[]){

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


    {
        dim3 threads(2,2);
        dim3 blocks(4096,4096);

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

    {
        dim3 threads(4,4);
        dim3 blocks(2048,2048);

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

    {
        dim3 threads(8,8);
        dim3 blocks(1024,1024);

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

    {
        dim3 threads(8,16);
        dim3 blocks(1024,512);

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



    //8 data points for diiferent blcok configurations
    {
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

    {
        dim3 threads(16,32);
        dim3 blocks(512,256);

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

    {
        dim3 threads(32,32);
        dim3 blocks(256,256);

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






}
