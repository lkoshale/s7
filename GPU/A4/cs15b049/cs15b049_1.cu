/*
Template code for convolution. CS6023, IITM */
#include<stdio.h>
#include<cuda.h>
#include<math.h>

#define W 1024 // Input DIM
#define OW (W-4) // Output DIM
#define D 8   // Input and Kernel Depth
#define T 5  // Kernel DIM
#define N 128 // Number of kernels


#define TILE_WIDTH 32

void fillMatrix(unsigned char *matrix){

unsigned char (*m)[W][D]=(unsigned char (*)[W][D])matrix;

for(int i=0;i<W;i++){
	for(int j=0;j<W;j++){
		for(int k=0;k<D;k++){
			m[i][j][k]=(i*j+j*k+i*k+i*2+j*3+k*4)%255;
				}
			}
		}
}



void fillKernel(float *kernel){

float (*t)[T][T][D]=(float (*)[T][T][D])kernel;

for(int i=0;i<N;i++){
	for(int j=0;j<T;j++){
		for(int k=0;k<T;k++){
			for(int l=0;l<D;l++){
			t[i][j][k][l]=fmod(-(i+1)*2.1+(j+1)*3.2-(k+1)*4.8+(l+1)*7.1,1.0);
				}
			}
		}
	}
}



void print_matrix_to_file(float *m){

	const char *fname = "assignment4_out";
	FILE *f = fopen(fname, "w");

	float (*mat)[OW][OW]=(float (*)[OW][OW])m;		

	for(unsigned i=0; i < N; i++) {
		for(unsigned j=0; j < OW; j++)
			for(unsigned k=0;k<OW;k++)
				fprintf(f,"%4.4f ", mat[i][j][k]);
		fprintf(f,"\n");
	}
	fclose(f);
}



__global__ void Convolve(unsigned char* mat,float* out,const float*  __restrict__ kern ){

	__shared__ unsigned char M[TILE_WIDTH+4][TILE_WIDTH+4][D];

	unsigned char (*matrix)[W][D]=(unsigned char (*)[W][D])mat;
	float (*kernel)[T][T][D]=(float (*)[T][T][D])kern;
	

	int k_idx = blockIdx.z;

	int tx = threadIdx.x;
	int ty = threadIdx.y;
	int x = blockIdx.x*blockDim.x + tx;
	int y = blockIdx.y*blockDim.y + ty;


	//compute out[x,y]
	if(x < OW && y< OW ){
		//load input in shared var
		for(int i=0;i<D;i++)
			M[tx+2][ty+2][i]= matrix[x+2][y+2][i];
		
		//load corner and edges
		if( tx == 0 ){
			for(int i=0;i<D;i++){
				M[tx][ty+2][i] =  matrix[x][y+2][i];
				M[tx+1][ty+2][i] = matrix[x+1][y+2][i];
			}
		}

		if(ty==0){
			for(int i=0;i<D;i++){
				M[tx+2][ty][i] =  matrix[x+2][y][i];
				M[tx+2][ty+1][i] = matrix[x+2][y+1][i];
			}
		}

		if(tx==TILE_WIDTH-1){
			for(int i=0;i<D;i++){
				M[tx+3][ty+2][i] =  matrix[x+3][y+2][i];
				M[tx+4][ty+2][i] = matrix[x+4][y+2][i];
			}
		}

		if(ty== TILE_WIDTH - 1){
			for(int i=0;i<D;i++){
				M[tx+2][ty+3][i] =  matrix[x+2][y+3][i];
				M[tx+2][ty+4][i] = matrix[x+2][y+4][i];
			}
		}

		if(tx==0 && ty==0){
			for(int i=0;i<D;i++){
				M[tx][ty][i] =  matrix[x][y][i];
				M[tx+1][ty][i] = matrix[x+1][y][i];
				M[tx][ty+1][i] = matrix[x][y+1][i];
				M[tx+1][ty+1][i]= matrix[x+1][y+1][i];
			}
		}

		if(tx==0 && ty==TILE_WIDTH-1){
			for(int i=0;i<D;i++){
				M[tx][ty+3][i] =  matrix[x][y+3][i];
				M[tx+1][ty+3][i] = matrix[x+1][y+3][i];
				M[tx][ty+4][i] = matrix[x][y+4][i];
				M[tx+1][ty+4][i]= matrix[x+1][y+4][i];
			}
		}

		if(tx==TILE_WIDTH-1 && ty==0){
			for(int i=0;i<D;i++){
				M[tx+3][ty][i] =  matrix[x+3][y][i];
				M[tx+4][ty][i] = matrix[x+4][y][i];
				M[tx+3][ty+1][i] = matrix[x+3][y+1][i];
				M[tx+4][ty+1][i]= matrix[x+4][y+1][i];
			}
		}

		if(tx==TILE_WIDTH-1 && ty==TILE_WIDTH-1){
			for(int i=0;i<D;i++){
				M[tx+3][ty+3][i] =  matrix[x+3][y+3][i];
				M[tx+4][ty+3][i] = matrix[x+4][y+3][i];
				M[tx+3][ty+4][i] = matrix[x+3][y+4][i];
				M[tx+4][ty+4][i]= matrix[x+4][y+4][i];
			}
		}

	}else{
		for(int i=0;i<D;i++)
			M[tx][ty][i]= matrix[x][y][i];
	}


	__syncthreads();

	//compute each output val

	if(x<OW && y<OW){
		float val=0;
		for(int r=0;r< T;r++){
			for(int c=0;c< T;c++){
				for(int i=0;i<D;i++){
					val+= kernel[k_idx][r][c][i] * M[tx+r][ty+c][i];
				}
			}
		}

		out[ (k_idx*OW*OW)+(x*OW)+y]=val;
	}

	
	//get kernel and apply for your number dot product

}


int main()
{

	unsigned char *matrix=(unsigned char*)malloc(sizeof(unsigned char)*W*W*D);
	float *kernel=(float*)malloc(sizeof(float)*T*T*D*N);
	float *output=(float *)malloc(sizeof(float)*N*OW*OW);


	fillMatrix(matrix);
	fillKernel(kernel);


	unsigned char *Dmatrix;cudaMalloc(&Dmatrix,sizeof(unsigned char)*W*W*D);
	float *Dkernel;cudaMalloc(&Dkernel,sizeof(float)*N*T*T*D);
	float *Doutput;cudaMalloc(&Doutput,sizeof(float)*N*OW*OW);

	cudaMemcpy(Dmatrix, matrix, sizeof(unsigned char)*W*W*D,cudaMemcpyHostToDevice);
	cudaMemcpy(Dkernel, kernel, sizeof(float)*T*T*D*N,cudaMemcpyHostToDevice);


	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	cudaEventRecord(start,0);

	//Make your cuda kernel call
	dim3 threads_per_block(TILE_WIDTH,TILE_WIDTH);


	int blocks = ( OW + TILE_WIDTH -1)/TILE_WIDTH;
	int block_dim = blocks*blocks; 
	dim3 blocks_per_grid(blocks,blocks,N);

	Convolve<<<blocks_per_grid,threads_per_block>>>(Dmatrix,Doutput,Dkernel);


	cudaDeviceSynchronize();


	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("%f\n",milliseconds);


	cudaMemcpy(output, Doutput, sizeof(float)*N*OW*OW,cudaMemcpyDeviceToHost);

	//Use print_matrix_to_file function only 
	print_matrix_to_file(output);

}
