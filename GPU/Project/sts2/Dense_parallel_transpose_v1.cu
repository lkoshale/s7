#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<math.h>

#define O_TIlE_SIZE 32
#define Rank 3

__global__ void Transpose(int *T, int *O, int *new_stride, int size, int rank, int *permute, int *stride)
{
	int j = blockIdx.x * blockDim.x +threadIdx.x;
	if(j < size){
		int index[Rank];
		int N = rank;
	    int rm = j;
	    for(int i=0;i<N;i++){
	        int id = rm/stride[i];
	        index[i]= id;
	        rm = rm%stride[i];
	    }   
	    int new_index[Rank]; 
	    for(int i=0;i<N;i++){
	        new_index[i]=index[permute[i]];

	    }
	    int f_ind =0;
	    for(int i=0;i<N;i++){
	        f_ind += new_index[i]*new_stride[i];
	    }


	    O[f_ind]=T[j];
	}
}

int main(int argc, char* argv[])
{

	int rank = atoi(argv[1]);
	int extent[rank];
	int permute[rank];
	int stride[rank];
	int i,size = 1;
	for(i = 0; i < rank; i++) {
		extent[i] = atoi(argv[i+2]);
		size *= extent[i];
	}
	stride[rank-1] = 1;
	for(i = rank-2; i >= 0; i--){
		stride[i] = stride[i+1]*extent[i+1];
	}
	for(i = 0; i < rank; i++) permute[i] = atoi(argv[i+rank+2]);

	int *tensor=(int*)malloc(sizeof(int)*size);
	int *output=(int*)malloc(sizeof(int)*size);

	for(i = 0;i < size; i++) tensor[i] = i;

	int *Dtensor;cudaMalloc(&Dtensor,sizeof(int)*size);
	int *Doutput;cudaMalloc(&Doutput,sizeof(int)*size);
	int *Dnew_stride;cudaMalloc(&Dnew_stride,sizeof(int)*rank);
	int *Dpermute;cudaMalloc(&Dpermute,sizeof(int)*rank);
	int *Dstride;cudaMalloc(&Dstride,sizeof(int)*rank);

	cudaMemcpy(Dtensor, tensor, sizeof(int)*size,cudaMemcpyHostToDevice);
	cudaMemcpy(Dpermute, permute, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dstride, stride, sizeof(int)*rank,cudaMemcpyHostToDevice);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	cudaEventRecord(start,0);
	int threadsPerBlock = O_TIlE_SIZE;
	int blocksPerGrid = (size+O_TIlE_SIZE-1)/O_TIlE_SIZE;

	int new_stride[rank];
    int new_extent[rank];
    for(int i=0;i<rank;i++){
        new_extent[i] = extent[permute[i]];
    }
    
    for(int i=rank-1;i>=0;i--){
        if(i==rank-1)
            new_stride[i]=1;
        else    
            new_stride[i]= new_extent[i+1]*new_stride[i+1];
        
    }
    cudaMemcpy(Dnew_stride, new_stride, sizeof(int)*rank,cudaMemcpyHostToDevice);
	//Dense Kernel
	Transpose<<<blocksPerGrid, threadsPerBlock>>>(Dtensor, Doutput, Dnew_stride, size, rank, Dpermute, Dstride);

	cudaDeviceSynchronize();


	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(int)*size,cudaMemcpyDeviceToHost);

	for(i=0;i<size;i++) printf("%d ",output[i]);
}
