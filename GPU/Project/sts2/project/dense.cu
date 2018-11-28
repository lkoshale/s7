#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<math.h>

#define O_TIlE_SIZE 32


//use const memory 
//use shared memory for input burst (same burst)

//try to paramaterize streams

__global__ void Transpose(int *T, int *O, const int* __restrict__ new_stride, int size, int rank,const  int* __restrict__ permute,const int* __restrict__ stride,int start)
{
	int j = blockIdx.x * blockDim.x +threadIdx.x + start;
	if(j < size+start){
	    int rm = j;
	    int f_ind =0;
	    for(int i=0;i<rank;i++){
	        f_ind += rm/stride[i]*new_stride[i];
	        rm = rm%stride[i];
	    }   
	    O[f_ind]=T[j-start];
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

    
    //create streams
    cudaStream_t stream1, stream2;
    cudaStreamCreate (&stream1); cudaStreamCreate (&stream2);

    //create two input vectors for two streams
    int s1 = size/2;                    //floor
    int s2 = (size+2-1)/2;              //ciel
    int *tensor1=(int*)malloc(sizeof(int)*s1);
    int *tensor2=(int*)malloc(sizeof(int)*s2);
    
    int *output=(int*)malloc(sizeof(int)*size);

    for(i = 0;i < size; i++) {
		if(i<s1) tensor1[i] = i;
		else tensor2[i-s1]=i;
	}

    //alocate memory on device
    int *Dtensor1;cudaMalloc(&Dtensor1,sizeof(int)*s1);
    int *Dtensor2;cudaMalloc(&Dtensor2,sizeof(int)*s2);

	int *Doutput;cudaMalloc(&Doutput,sizeof(int)*size);
	int *Dnew_stride;cudaMalloc(&Dnew_stride,sizeof(int)*rank);
	int *Dpermute;cudaMalloc(&Dpermute,sizeof(int)*rank);
	int *Dstride;cudaMalloc(&Dstride,sizeof(int)*rank);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;

	

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

    int threadsPerBlock = O_TIlE_SIZE;
    int blocksPerGrid1 = (s1+O_TIlE_SIZE-1)/O_TIlE_SIZE;
    int blocksPerGrid2 = (s2+O_TIlE_SIZE-1)/O_TIlE_SIZE;

    cudaMemcpy(Dpermute, permute, sizeof(int)*rank,cudaMemcpyHostToDevice);
    cudaMemcpy(Dstride, stride, sizeof(int)*rank,cudaMemcpyHostToDevice);
    cudaMemcpy(Dnew_stride, inverse_permute_stride, sizeof(int)*rank,cudaMemcpyHostToDevice);

	cudaEventRecord(start,stream1);
    //load memory async
    cudaMemcpyAsync(Dtensor1, tensor1, sizeof(int)*s1,cudaMemcpyHostToDevice,stream1);

	//Dense Kernel
    Transpose<<<blocksPerGrid1, threadsPerBlock,0,stream1>>>(Dtensor1, Doutput, Dnew_stride, s1, rank, Dpermute, Dstride,0);
	
	//second kernel
	cudaMemcpyAsync(Dtensor2, tensor2, sizeof(int)*s2,cudaMemcpyHostToDevice,stream2);
	Transpose<<<blocksPerGrid2, threadsPerBlock,0,stream2>>>(Dtensor2, Doutput, Dnew_stride, s2, rank, Dpermute, Dstride,s1);

	cudaDeviceSynchronize();

	cudaEventRecord(stop,stream1);

	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(int)*size,cudaMemcpyDeviceToHost);

	//for(i=0;i<size;i++) printf("%d ",output[i]);
}
