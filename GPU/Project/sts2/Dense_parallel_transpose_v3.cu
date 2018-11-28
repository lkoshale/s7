#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<math.h>

#define O_TIlE_SIZE 32

__global__ void Transpose(int *T, int *O, int *new_stride, unsigned int size, int rank, int *permute, int *stride)
{
	unsigned int j = blockIdx.x * blockDim.x +threadIdx.x;
	if(j < size){
	    unsigned int rm = j;
	    unsigned int f_ind =0;
	    for(int i=0;i<rank;i++){
	        f_ind += rm/stride[i]*new_stride[i];
	        rm = rm%stride[i];
	    }   
	    O[f_ind]=T[j];
	}
}

int main(int argc, char* argv[])
{

	int rank;
	scanf("%d",&rank);
	int extent[rank];
	int permute[rank];
	int stride[rank];
	int i;
	unsigned int size = 1;
	for(i = 0; i < rank; i++) {
		scanf("%d",&extent[i]);
		size *= extent[i];
	}
	stride[rank-1] = 1;
	for(i = rank-2; i >= 0; i--){
		stride[i] = stride[i+1]*extent[i+1];
	}

	for(i = 0; i < rank; i++){
		 scanf("%d",&permute[i]);
	}

	int *tensor=(int*)malloc(sizeof(int)*size);
	int *output=(int*)malloc(sizeof(int)*size);

	for(unsigned int i = 0;i < size; i++){
		scanf("%d",&tensor[i]);
	} 

	int *Dtensor;cudaMalloc(&Dtensor,sizeof(int)*size);
	int *Doutput;cudaMalloc(&Doutput,sizeof(int)*size);
	int *Dnew_stride;cudaMalloc(&Dnew_stride,sizeof(int)*rank);
	int *Dpermute;cudaMalloc(&Dpermute,sizeof(int)*rank);
	int *Dstride;cudaMalloc(&Dstride,sizeof(int)*rank);

	

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	
	int threadsPerBlock = O_TIlE_SIZE;
	int blocksPerGrid = (size+O_TIlE_SIZE-1)/O_TIlE_SIZE;

	int new_stride[rank];
	int inverse_permute_stride[rank];
	int inverse_permute[rank];
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

    for(int i=0;i<rank;i++){
        inverse_permute[permute[i]] = i;
    }
    for(int i=0;i<rank;i++){
        inverse_permute_stride[i] = new_stride[inverse_permute[i]];
	}

	cudaMemcpy(Dpermute, permute, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dstride, stride, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dnew_stride, inverse_permute_stride, sizeof(int)*rank,cudaMemcpyHostToDevice);


	cudaEventRecord(start,0);
	
	cudaMemcpy(Dtensor, tensor, sizeof(int)*size,cudaMemcpyHostToDevice);
	//Dense Kernel
	Transpose<<<blocksPerGrid, threadsPerBlock>>>(Dtensor, Doutput, Dnew_stride, size, rank, Dpermute, Dstride);

	cudaDeviceSynchronize();


	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(int)*size,cudaMemcpyDeviceToHost);

	for(unsigned int i=0;i<size;i++) printf("%d ",output[i]);
}
