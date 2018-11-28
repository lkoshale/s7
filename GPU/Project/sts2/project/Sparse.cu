#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<math.h>
#include<time.h>

#define O_TIlE_SIZE 32

__global__ void Transpose(int *T, int *index, int *O, int *new_stride, int size, int rank, int *stride)
{
	int j = blockIdx.x * blockDim.x +threadIdx.x;
	if(j < size){
	    int rm = index[j];
	    int f_ind =0;
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
	int i,size = 1;
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
	int *tensor_index = (int*)malloc(sizeof(int)*size);
	int *output=(int*)malloc(sizeof(int)*size);
	int sparse_index = 0;
	
	//take input
	for(i = 0;i < size; i++){
		int val;
		scanf("%d",&val);
		if(val!=0){
			tensor[sparse_index] = val;
			tensor_index[sparse_index] = i;
			sparse_index++;
		}
	}

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



	int *Dtensor_index;cudaMalloc(&Dtensor_index,sizeof(int)*sparse_index);
	int *Dtensor;cudaMalloc(&Dtensor,sizeof(int)*sparse_index);
	int *Doutput;cudaMalloc(&Doutput,sizeof(int)*size);
	int *Dnew_stride;cudaMalloc(&Dnew_stride,sizeof(int)*rank);
	int *Dpermute;cudaMalloc(&Dpermute,sizeof(int)*rank);
	int *Dstride;cudaMalloc(&Dstride,sizeof(int)*rank);

	

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	
	int threadsPerBlock = O_TIlE_SIZE;
	int blocksPerGrid = (sparse_index+O_TIlE_SIZE-1)/O_TIlE_SIZE;

	

	cudaMemcpy(Dpermute, permute, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dstride, stride, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dnew_stride, inverse_permute_stride, sizeof(int)*rank,cudaMemcpyHostToDevice);


	cudaEventRecord(start,0);
	
	cudaMemcpy(Dtensor, tensor, sizeof(int)*sparse_index,cudaMemcpyHostToDevice);
	cudaMemcpy(Dtensor_index, tensor_index, sizeof(int)*sparse_index,cudaMemcpyHostToDevice);
	cudaMemset(Doutput,0,sizeof(int)*size);
	
	Transpose<<<blocksPerGrid, threadsPerBlock>>>(Dtensor, Dtensor_index, Doutput, Dnew_stride, sparse_index, rank, Dstride);

	cudaDeviceSynchronize();


	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(int)*size,cudaMemcpyDeviceToHost);


	for(i=0;i<size;i++) printf("%d ",output[i]);
}
