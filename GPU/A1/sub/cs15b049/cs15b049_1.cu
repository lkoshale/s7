#include <stdio.h>

int main(){

    int num_device;
    cudaGetDeviceCount(&num_device);
    
    for(int i=0;i<num_device;i++){
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop,i);

        FILE* fptr = fopen("cs15b049_1_out.txt","w");

        fprintf(fptr,"%d\n",prop.localL1CacheSupported);
        fprintf(fptr,"%d\n",prop.globalL1CacheSupported);
        fprintf(fptr,"%d\n",prop.l2CacheSize);
        fprintf(fptr,"%d\n",prop.maxThreadsPerBlock);
        fprintf(fptr,"%d\n",prop.regsPerBlock);
        fprintf(fptr,"%d\n",prop.regsPerMultiprocessor);
        fprintf(fptr,"%d\n",prop.warpSize);
        fprintf(fptr,"%zu\n",prop.totalGlobalMem);

    }

    return 0;
}