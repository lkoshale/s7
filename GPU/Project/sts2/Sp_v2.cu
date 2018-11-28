#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<math.h>
#include<time.h>

#define O_TIlE_SIZE 32

__global__ void Transpose(int *T, int *index, int *O, int *new_stride, int size, int rank, int *stride,int start,int chunk)
{
	int j = blockIdx.x * blockDim.x +threadIdx.x;
	// printf("%d--%d--%d:\n",start,j,size);
	if(start + j < size && j < chunk){
	    int rm = index[j];
	    int f_ind =0;
	    for(int i=0;i<rank;i++){
	        f_ind += rm/stride[i]*new_stride[i];
	        rm = rm%stride[i];
	    }   
		O[f_ind]=T[j];
		
		// printf("%d--%d--%d\n",f_ind,T[j],j);
		
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



	//divide in 1mb of data for each iteration streams
    int chunkSize1 = sparse_index/2;
    int chunkSize2= (sparse_index+2-1)/2;
	
	cudaStream_t stream1, stream2;
	cudaStreamCreate (&stream1); cudaStreamCreate (&stream2);


	int *Dtensor_index1;cudaMalloc(&Dtensor_index1,sizeof(int)*chunkSize1);
	int *Dtensor1;cudaMalloc(&Dtensor1,sizeof(int)*chunkSize1);

	int *Dtensor_index2;cudaMalloc(&Dtensor_index2,sizeof(int)*chunkSize2);
	int *Dtensor2;cudaMalloc(&Dtensor2,sizeof(int)*chunkSize2);

	int *Doutput;cudaMalloc(&Doutput,sizeof(int)*size);
	int *Dnew_stride;cudaMalloc(&Dnew_stride,sizeof(int)*rank);
	int *Dpermute;cudaMalloc(&Dpermute,sizeof(int)*rank);
	int *Dstride;cudaMalloc(&Dstride,sizeof(int)*rank);

	

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	
	int threadsPerBlock = O_TIlE_SIZE;
    int blocksPerGrid1 = (chunkSize1+O_TIlE_SIZE-1)/O_TIlE_SIZE;
    int blocksPerGrid2 = (chunkSize2+O_TIlE_SIZE-1)/O_TIlE_SIZE;

	cudaMemcpy(Dpermute, permute, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dstride, stride, sizeof(int)*rank,cudaMemcpyHostToDevice);
	cudaMemcpy(Dnew_stride, inverse_permute_stride, sizeof(int)*rank,cudaMemcpyHostToDevice);



	
//	cudaMemcpy(Dtensor, tensor, sizeof(int)*sparse_index,cudaMemcpyHostToDevice);
//	cudaMemcpy(Dtensor_index, tensor_index, sizeof(int)*sparse_index,cudaMemcpyHostToDevice);
	cudaMemset(Doutput,0,sizeof(int)*size);

	cudaEventRecord(start,stream1);
	
    cudaMemcpyAsync(Dtensor1, tensor, sizeof(int)*chunkSize1,cudaMemcpyHostToDevice,stream1);
    cudaMemcpyAsync(Dtensor_index1, tensor_index, sizeof(int)*chunkSize1,cudaMemcpyHostToDevice,stream1);

    Transpose<<<blocksPerGrid, threadsPerBlock,0,stream1>>>(Dtensor1, Dtensor_index1, Doutput, Dnew_stride,sparse_index, rank, Dstride,0,chunkSize1);

    cudaMemcpyAsync(Dtensor2, tensor+chunkSize1, sizeof(int)*chunkSize2,cudaMemcpyHostToDevice,stream2);
    cudaMemcpyAsync(Dtensor_index2, tensor_index+chunkSize1, sizeof(int)*chunkSize2,cudaMemcpyHostToDevice,stream2);

    Transpose<<<blocksPerGrid, threadsPerBlock,0,stream2>>>(Dtensor2, Dtensor_index2, Doutput, Dnew_stride,sparse_index, rank, Dstride,chunkSize1,chunkSize2);

	cudaDeviceSynchronize();

	cudaEventRecord(stop,stream1);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(int)*size,cudaMemcpyDeviceToHost);

	for(i=0;i<size;i++) printf("%d ",output[i]);
}
