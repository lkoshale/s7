#include <stdio.h>
#include <cuda.h>
#include <string.h>
#include <stdlib.h>

#define MAXWORDS 20000


__global__ void kernel1(int* A,int* C,int size){
    __shared__ int hist[20];

    int x = threadIdx.x;
    int idx = (blockIdx.x*blockDim.x)+x;

    if(idx < size){

        //initailize share mem
        if(x<20){
            hist[x]=0;
        }
        __syncthreads();

        int k = A[idx];

        atomicAdd(&hist[k-1],1);

        //sync all threads so to update in global memory
        __syncthreads();

        //first 20 threads write back to global
        if(x <20){
            atomicAdd(&C[x],hist[x]);
        }
        __syncthreads();
    }

}

/*
__global__ void kernel2(int* A,int* C,int size){
    __shared__ int hist[400];
    
    int x = threadIdx.x;
    int idx = (blockIdx.x*blockDim.x)+x;

    if(idx < size){

        //initailize share mem
        if(x<400){
            hist[x]=0;
        }
        __syncthreads();
    
        // get a value and update

        int m = A[idx];
        int n = A[idx+1];

        int h_idx=0;
        if(n/10==0 && m/10==0){
            h_idx = (m*10 + n)-11;
        }
        else if( (n/100==0 && m/10 == 0)
            h_idx = (m*100 + n)
        }
        else if(n/10==0 && m/100=0) {
            h_idx = (m*100)
        }
        else if(n/100==0 && m/100==0){

        }


    }

}
*/

__global__ void kernelfinal(int* A,int* C,int* ind_array,int* C_size,int size,int N,int* lock){
    int x = threadIdx.x;
    int idx = (blockIdx.x*blockDim.x)+x;

    int curidx[5];

    if(idx < size){
        //current window
        for(int i=0;i<N;i++){
            curidx[i]=A[idx+i];
        }

        int i = 0;
        //update val in global if exists
        for(i=0;i<(*C_size);i++){
            //check for index present in window
            int m = 1;
            for(int j=0;j<N;j++){
                if(curidx[j]==ind_array[N*i+j])
                    m = m && 1;    
                else {
                    m = m && 0;
                    break;
                }
            }

            if(m==1){
                atomicAdd(&C[i],1);
                break;
            }
        }

        //add if doesnt exist with locking
        if(i==*C_size){
            //insert at end
            //get lock
            while(atomicCAS(lock,0,1)!=0){
                //loop
            }

            //critical part
            for(int j=0;j<N;j++){
                ind_array[*C_size*N+j]=curidx[j];
            }

            C[*C_size]=1;
            *C_size+=1;

            //unlock
            atomicCAS(lock,1,0);
        }

    }
}


void checkWord(char* word,int* array,int* len){

   int count = 0;
   for(int i=0;i<strlen(word);i++){
        char c= word[i];
        if(c=='-' && count>0){
            array[*len]=count;
            *len+=1;
            count=0;
        }
        else if(c=='.'||c=='!'||c==','||c=='?'||c==';'|c==':'||c=='\''||c=='\"'||c=='('||c==')'||c=='['||c==']'){
            continue;
        }
        else{
            count++;
        }
   }

    if(count>0){
        array[*len]=count;
        *len+=1;
    }


}


void print(int* array,int* len){

    for(int i=0;i<*len;i++){
        printf("%d %d\n",i,array[i]);
    }

}

int main(int argc , char* argv[]){

    int size = sizeof(int)*MAXWORDS;
    int* h_A = (int*)malloc(size);
    
    int N = atoi(argv[1]);    // For calculating N-count-grams
    char *filename = argv[2];  // Filename: shaks.txt


    char curWord[40];   // Take input string into this
    int totalWordCount = 0;
    int* len = (int*)malloc(sizeof(int));
    *len = 0;

    // Count of number of words read
    FILE *ipf = fopen(filename,"r");
    while (fscanf(ipf, "%s",curWord)!=EOF && totalWordCount < MAXWORDS) {
        checkWord(curWord,h_A,len);
        totalWordCount++;
    }

    //size of output histogram 
    //no of combinations can be possible
    int len_C;
    switch(N){
        case 1: len_C=20;
                break;
        case 2: len_C=400;
                    break;
        case 3: len_C=8000;
                    break;
        case 4: len_C= totalWordCount -3;
                break;
        case 5: len_C = totalWordCount -4;
                break;
        
        default: len_C = totalWordCount -N;
    }
    
    //two arrays one for index and one for storage

    int size_C = len_C*sizeof(int);
    int* h_C = (int*)malloc(size_C);
    int* h_index = (int*)malloc(size_C*N);
    int* h_C_size = (int*)malloc(sizeof(int));
    

    // print(h_A,len);

    int* d_A;
    cudaMalloc(&d_A,size);
    int* d_C;
    cudaMalloc(&d_C,size_C);
    int* d_index;
    cudaMalloc(&d_index,size_C*N);
    int* d_C_size;
    cudaMalloc(&d_C_size,sizeof(int));
    int* d_lock;
    cudaMalloc(&d_lock,sizeof(int));

    //set initail value to 0
    cudaMemset(d_C,0,size_C);
    cudaMemset(d_C_size,0,sizeof(int));
    cudaMemset(d_lock,0,sizeof(int));
    
    cudaMemcpy(d_A,h_A,size,cudaMemcpyHostToDevice);
    

    int threads_per_block,blocks;

    //dimensions of kernel
    if(N==1){

        //call kernel 1
        threads_per_block = 1024;
        //each block does single computation
        blocks = ( totalWordCount + threads_per_block -1)/threads_per_block;

        kernel1<<<blocks,threads_per_block>>>(d_A,d_C,totalWordCount);
        
        cudaMemcpy(h_C,d_C,size_C,cudaMemcpyDeviceToHost);
        cudaMemcpy(h_index,d_index,size_C*N,cudaMemcpyDeviceToHost);
        print(h_C,&len_C);

    }
    else{

        //no use of shared mem
        threads_per_block = 1024;
        int work = totalWordCount - (N-1);

        //1 per op
        blocks = ( work + threads_per_block -1)/threads_per_block;
        
        kernelfinal<<<blocks,threads_per_block>>>(d_A,d_C,d_index,d_C_size,work,N,d_lock);

        cudaMemcpy(h_C,d_C,size_C,cudaMemcpyDeviceToHost);
        cudaMemcpy(h_index,d_index,size_C*N,cudaMemcpyDeviceToHost);
        cudaMemcpy(h_C_size,d_C_size,sizeof(int),cudaMemcpyDeviceToHost);

        for(int i=0;i<*h_C_size;i++){
            for(int j=0;j<N;j++){
                printf("%d ",h_index[i*N+j]);
            }
            printf("%d\n",h_C[i]);
        }
    
    }

    
    printf("%d %d",totalWordCount,blocks);


    //kernel invocation




    //end



}