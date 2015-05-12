#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <string>

//#include "./log_helper.h"

#include "cuda.h"
#include "cublas.h"
//#include "cublas_v2.h"

#define MATRIX_PATH "/home/carol/TestGPU/GenerateGoldMatrix/Double_"

#define BLOCK_SIZE 32

#ifndef ITERACTIONS
#define ITERACTIONS 100000000000000000
#endif

#undef min
#define min( x, y ) ( (x) < (y) ? (x) : (y) )
#undef max
#define max( x, y ) ( (x) > (y) ? (x) : (y) )

int k=0; // N will be received on runtime

using namespace std;

string gold_matrix_path, a_matrix_path, b_matrix_path;

double *A;
double *B;
double *d_A;
double *d_B;
double *d_C;

   int lda, ldb, ldc;

double *GOLD;


FILE* f_A;
FILE* f_B;
FILE* f_GOLD;

FILE* file;
FILE* log_file;
FILE* timefile;

void UpdateTimestamp(){
	time_t timestamp = time(NULL);
	char time_s[50];
	sprintf(time_s, "%d", int(timestamp));

	char string[100] = "echo ";
	strcat(string, time_s);
	strcat(string, " > /home/carol/TestGPU/timestamp.txt");
	system(string);

//	printf("\n%s\n", string);
}


void log_error_detail(char* err)
{printf(err);
return;}

void end_log_file(){return;}

void GetDevice(){

    cudaDeviceProp prop;
    cudaError_t teste;
    int count=0;
    teste = cudaGetDeviceCount(&count);
	printf("\nGet Device Test: %s\n", cudaGetErrorString(teste));
    for (int i=0; i< count; i++) {
        cudaGetDeviceProperties( &prop, i );
        printf( "Name: %s\n", prop.name );
    }
    int *ndevice; int dev = 0;
    ndevice = &dev;
    cudaGetDevice(ndevice);
    
    cudaSetDevice(0);
        cudaGetDeviceProperties( &prop, 0 );
	printf("\ndevice: %d %s", *ndevice, prop.name);

}

double mysecond()
{
   struct timeval tp;
   struct timezone tzp;
   int i = gettimeofday(&tp,&tzp);
   return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

void ReadMatrixFromFile(){	
	
	int i;
	int j;
	double temp=0;
	double time = mysecond();
printf("open...");
	f_A = fopen(a_matrix_path.c_str(),"rb");
	f_B = fopen(b_matrix_path.c_str(),"rb");
	f_GOLD = fopen(gold_matrix_path.c_str(),"rb");
printf("read...");
	for(i=0; i<k; i++)
	{
		fread (&A[ lda * i ], sizeof(double)*k, 1, f_A);
		fread (&B[ lda * i ], sizeof(double)*k, 1, f_B);
		fread (&GOLD[ lda * i ], sizeof(double)*k, 1, f_GOLD);
		//for(j=0; j<n; j++){
//
//			A[i + lda * j] = 0.0;
//			B[j + ldb * i] = 0.0;
//
//			GOLD[i + ldc * j] = 0.0; 
//
//			fread(&A[i + lda * j],sizeof(double), 1, f_A);
//			fread(&B[j + ldb * i],sizeof(double), 1, f_B);
//			fread(&GOLD[i + ldc * j],sizeof(double), 1, f_GOLD);
//			
//		}
	}	printf("\n");
	for (i=0; i<k; i++)
	{ 
		for (j=0; (j<k)&&(j<i); j++)
		{
			temp = GOLD [i + ldc * j];
			GOLD [i + ldc * j] = GOLD [j + ldc * i];
			GOLD [j + ldc * i] = temp;
		}
	}
printf("ok in %f\n", mysecond() - time);

//A[45] = 5.5;
	fclose(f_A);
	fclose(f_B);
	fclose(f_GOLD);
}

__device__ int kerrors;

__global__ void GoldChkKernel (double *gk, double *ck, int n)//, int *kerrors)
{
	//ck[4] = 4.5;
	int tx = blockIdx.x * BLOCK_SIZE + threadIdx.x;                                                      
	int ty = blockIdx.y * BLOCK_SIZE + threadIdx.y; 
	if ((fabs((gk[ty*n+tx]-ck[ty*n+tx])/gk[ty*n+tx]) > 0.0000000001)||(fabs((gk[ty*n+tx]-ck[ty*n+tx])/ck[ty*n+tx]) > 0.0000000001))
//	if (gk[ty*n + tx]!=ck[ty*n + tx])
		atomicAdd(&kerrors, 1);//kerrors++;

}



int main( int argc, char* argv[] )
{

	
	cudaError_t malloc_mem1;
	cudaError_t malloc_a;
	const char *erro_malloc;

	int ea=0; //wrong integers in the current loop
	int t_ea=0; //total number of wrong integers

	double total_time = 0.0;

	const double alpha = 1.0;
	const double beta = 1.0;

	char transa = 't', transb = 't';
	int i, j, loop2;

	int kernel_errors=0;
	int zero = 0;


	int sizea, sizeb, sizec;

	////////////////////////////////////////////////////
	////////////////////GET PARAM///////////////////////
	if (argc!=2) {
		printf ("Enter the required input. (1024/2048/4096/8192)\n");
		exit (-1);
	}
	k = atoi (argv[1]);
	if (((k%32)!=0)||(k<0)){
		printf ("Enter a valid input. (k=%i)\n", k);
		exit (-1);
	}
	string matrix_size_str(argv[1]);

	a_matrix_path = MATRIX_PATH;
	b_matrix_path = MATRIX_PATH;
	gold_matrix_path = MATRIX_PATH;
	a_matrix_path += "A_8192.matrix";
	b_matrix_path += "B_8192.matrix";
	gold_matrix_path += "GOLD_" + matrix_size_str + ".matrix";

	//////////BLOCK and GRID size///////////////////////
	int gridsize = k/BLOCK_SIZE < 1 ? 1 : k/BLOCK_SIZE;
	int blocksize = k/BLOCK_SIZE < 1 ? k : BLOCK_SIZE;
	dim3 dimBlock(blocksize,blocksize);
	dim3 dimGrid(gridsize,gridsize);
	////////////////////////////////////////////////////


	char test_info[90];
	snprintf(test_info, 90, "size:%d", k);
	////start_log_file("cudaGEMM", test_info);


	lda = max( 1, k + 16 );
	sizea = lda * k;
	ldb = max( 1, k + 16 );
	sizeb = ldb * k;
	ldc = max( 1, k + 16 );
	sizec = ldc * k;

	A = ( double* ) malloc( sizea * sizeof( double ) );
	B = ( double* ) malloc( sizeb * sizeof( double ) );

	GOLD = ( double* ) malloc( sizec * sizeof( double ) );

	kernel_errors=0;
	
	GetDevice();
	
	ReadMatrixFromFile();

	//A[72] = 7.2;

	printf( "cublasDGEMM\n" );

   
	for(loop2=0; loop2<ITERACTIONS; loop2++)
	{


		malloc_a = cudaMalloc( ( void** ) &d_A, sizea * sizeof( double ) );
		erro_malloc = cudaGetErrorString(malloc_a);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error a"); end_log_file(); return 1;} //mem allocate failure

		malloc_a = cudaMalloc( ( void** ) &d_B, sizea * sizeof( double ) );
		erro_malloc = cudaGetErrorString(malloc_a);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error b"); end_log_file(); return 1;} //mem allocate failure

		malloc_a = cudaMalloc( ( void** ) &d_C, sizea * sizeof( double ) );
		erro_malloc = cudaGetErrorString(malloc_a);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error c"); end_log_file(); return 1;} //mem allocate failure


		malloc_mem1 = cudaMemcpy( d_C, A, sizeb * sizeof( double ), cudaMemcpyHostToDevice ); // ZERA C
		erro_malloc = cudaGetErrorString(malloc_mem1);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error mem load c "); end_log_file(); return 1;}
	
		malloc_mem1 = cudaMemcpy( d_A, A, sizeb * sizeof( double ), cudaMemcpyHostToDevice ); // PUSH A
		erro_malloc = cudaGetErrorString(malloc_mem1);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error mem load a "); end_log_file(); return 1;}

		malloc_mem1 = cudaMemcpy( d_B, B, sizeb * sizeof( double ), cudaMemcpyHostToDevice ); // PUSH B
		erro_malloc = cudaGetErrorString(malloc_mem1);
		if(strcmp(erro_malloc, "no error") != 0) {log_error_detail("error mem load b "); end_log_file(); return 1;}

		kernel_errors=0;
		//cublasHandle_t blashandle;
		//cublasCreate(&blashandle);
	
		printf("cublasDgemm... k=%d transa=%c transb=%c lda=%d ldb=%d ldc=%d\n", k, transa, transb, lda, ldb, ldc);
		////start_iteration();
		//cublasDgemm( blashandle, (cublasOperation_t)transa, (cublasOperation_t)transb,
		cublasDgemm( (cublasOperation_t)transa, (cublasOperation_t)transb,
			   k, k, k,
			   alpha,
			   d_A, lda,
			   d_B, ldb,
			   beta,
			   d_C, ldc );
		printf("\nend\n");
		cudaDeviceSynchronize();
		////end_iteration();

		malloc_mem1 = cudaMemcpy(d_A, GOLD, sizea * sizeof( double ), cudaMemcpyHostToDevice );
		erro_malloc = cudaGetErrorString(malloc_mem1);
		if(strcmp(erro_malloc, "no error") != 0) {printf("error mem load a %s", erro_malloc); fprintf(file, "error mem load a %s", erro_malloc); return 1;}

		cudaMemcpyToSymbol(kerrors, &zero, sizeof(int));

		GoldChkKernel<<<dimGrid,dimBlock>>>(d_A, d_C, ldc);


		cudaMemcpyFromSymbol(&kernel_errors, kerrors, sizeof(unsigned int));
	
	 
		/////////////UPDATE TIMESTAMP///////////////////
	//	UpdateTimestamp();
		////////////////////////////////////////////////
		
		////log_error_count(kernel_errors);

		if (kernel_errors!=0)
		{

			printf("\n kernel error: %d\n", kernel_errors);

			malloc_mem1 = cudaMemcpy(A, d_C, sizec * sizeof( double ), cudaMemcpyDeviceToHost);
			erro_malloc = cudaGetErrorString(malloc_mem1);
			if(strcmp(erro_malloc, "no error") != 0)
				{printf("error mem load a %s", erro_malloc); fprintf(file, "error mem load a %s", erro_malloc); return 1;}
			char error_detail[150];

			for(i=0; (i<k) && (ea < 500); i++)
			{
				for(j=0; (j<k) && (ea < 500); j++)
				{
					if ((fabs((A[i+ldc*j]-GOLD[i+ldc*j])/A[i+ldc*j]) > 0.0000000001)||(fabs((A[i+ldc*j]-GOLD[i+ldc*j])/GOLD[i+ldc*j]) > 0.0000000001))
					{
						snprintf(error_detail, 150, "p: [%d, %d], r: %1.16e, e: %1.16e", i, j, A[i + ldc * j], GOLD[i + ldc * j]);
						////log_error_detail(error_detail);
						//ea++;			
						//fprintf(file, "\n p: [%d, %d], r: %1.16e, e: %1.16e, error: %d\n", i, j, A[i + ldc * j], GOLD[i + ldc * j], t_ea);
										
					}
				}
			}

				ReadMatrixFromFile();	
		}



		if(kernel_errors > 0 || (loop2 % 10 == 0))
		{
			printf("\ntest number: %d", loop2);
		}
		else
		{
			printf(".");
		}



		cudaFree( d_A );
		cudaFree( d_B );
		cudaFree( d_C );
	}

	free( A );
	free( B );

	end_log_file();

	return 0;
}
