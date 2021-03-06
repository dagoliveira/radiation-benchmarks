#include "hotspot.h"
#include "kernel_hotspot.h"

int iterations, devType;
//char *kernel_file;
char *input_temp, *input_power, *output;

double mysecond()
{
   struct timeval tp;
   struct timezone tzp;
   int i = gettimeofday(&tp,&tzp);
   return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

void writeoutput(float *vect, int grid_rows, int grid_cols, char *file){

	int i,j, index=0;
	FILE *fp;
	char str[STR_SIZE];

	if( (fp = fopen(file, "w" )) == 0 )
          printf( "The file was not opened\n" );


	for (i=0; i < grid_rows; i++) 
	 for (j=0; j < grid_cols; j++)
	 {

		 sprintf(str, "%f\n", vect[i*grid_cols+j]);
		 fputs(str,fp);
		 index++;
	 }
		
      fclose(fp);	
}

void readinput(float *vect, int grid_rows, int grid_cols, char *file){

  	int i,j;
	FILE *fp;
	char str[STR_SIZE];
	float val;

	if( (fp  = fopen(file, "r" )) ==0 )
            printf( "The file was not opened\n" );


	for (i=0; i <= grid_rows-1; i++) 
	 for (j=0; j <= grid_cols-1; j++)
	 {
		char *res = fgets(str, STR_SIZE, fp);
		if(res == NULL)
			fatal("Error reading input");
		if (feof(fp))
			fatal("not enough lines in file");
		//if ((sscanf(str, "%d%f", &index, &val) != 2) || (index != ((i-1)*(grid_cols-2)+j-1)))
		if ((sscanf(str, "%f", &val) != 1))
			fatal("invalid file format");
		vect[i*grid_cols+j] = val;
	}

	fclose(fp);	

}


/*
   compute N time steps
*/
long long int flops=0;

int compute_tran_temp(cl_mem MatrixPower, cl_mem MatrixTemp[2], int col, int row, \
                      int total_iterations, int num_iterations, int blockCols, int blockRows, int borderCols, int borderRows)
{

    float grid_height = chip_height / row;
    float grid_width = chip_width / col;

    float Cap = FACTOR_CHIP * SPEC_HEAT_SI * t_chip * grid_width * grid_height;
    float Rx = grid_width / (2.0 * K_SI * t_chip * grid_height);
    float Ry = grid_height / (2.0 * K_SI * t_chip * grid_width);
    float Rz = t_chip / (K_SI * grid_height * grid_width);

    float max_slope = MAX_PD / (FACTOR_CHIP * t_chip * SPEC_HEAT_SI);
    float step = PRECISION / max_slope;
    int t;

    int src = 0, dst = 1;

    cl_int error;

    // Determine GPU work group grid
    size_t global_work_size[2];
    global_work_size[0] = BLOCK_SIZE * blockCols;
    global_work_size[1] = BLOCK_SIZE * blockRows;
    size_t local_work_size[2];
    local_work_size[0] = BLOCK_SIZE;
    local_work_size[1] = BLOCK_SIZE;


    long long start_time = get_time_helper();

    for (t = 0; t < total_iterations; t += num_iterations) {

        // Specify kernel arguments
        int iter = MIN(num_iterations, total_iterations - t);
        clSetKernelArg(kernel, 0, sizeof(int), (void *) &iter);
        clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *) &MatrixPower);
        clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *) &MatrixTemp[src]);
        clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *) &MatrixTemp[dst]);
        clSetKernelArg(kernel, 4, sizeof(int), (void *) &col);
        clSetKernelArg(kernel, 5, sizeof(int), (void *) &row);
        clSetKernelArg(kernel, 6, sizeof(int), (void *) &borderCols);
        clSetKernelArg(kernel, 7, sizeof(int), (void *) &borderRows);
        clSetKernelArg(kernel, 8, sizeof(float), (void *) &Cap);
        clSetKernelArg(kernel, 9, sizeof(float), (void *) &Rx);
        clSetKernelArg(kernel, 10, sizeof(float), (void *) &Ry);
        clSetKernelArg(kernel, 11, sizeof(float), (void *) &Rz);
        clSetKernelArg(kernel, 12, sizeof(float), (void *) &step);

        // Launch kernel
        error = clEnqueueNDRangeKernel(command_queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
        if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

        // Flush the queue
        error = clFlush(command_queue);
        if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

        // Swap input and output GPU matrices
        src = 1 - src;
        dst = 1 - dst;
// Daniel: Rough approximation I think
flops += col * row * iter * 15;
    }

    // Wait for all operations to finish
    error = clFinish(command_queue);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    long long end_time = get_time_helper();
    long long total_time = (end_time - start_time);
    printf("\nKernel time: %.3f seconds\n", ((float) total_time) / (1000*1000));

    return src;
}

usage(){
        printf("Usage: hotspot_gen <sim_iter> <input_size> <cl_device_tipe> <input_temp_file> <input_power_file> <output_gold_file>\n");
        printf("  cl_device_types\n");
        printf("    Default: %d\n",CL_DEVICE_TYPE_DEFAULT);
        printf("    CPU: %d\n",CL_DEVICE_TYPE_CPU);
        printf("    GPU: %d\n",CL_DEVICE_TYPE_GPU);
        printf("    ACCELERATOR: %d\n",CL_DEVICE_TYPE_ACCELERATOR);
        printf("    ALL: %d\n",CL_DEVICE_TYPE_ALL);
}

int main(int argc, char** argv) {
	double kernel_time=0;
    int grid_rows,grid_cols = 0;

    if(argc == 7) {
        iterations = atoi(argv[1]);
	grid_rows = atoi(argv[2]);
        devType = atoi(argv[3]);
        //kernel_file = argv[4];
        input_temp = argv[4];
        input_power = argv[5];
        output = argv[6];
    } else {
        usage();
        exit(1);
    }
    grid_cols = grid_rows;
    printf("WG size of kernel = %d X %d\n", BLOCK_SIZE, BLOCK_SIZE);

    cl_int error;
    cl_uint num_platforms;

    // Get the number of platforms
    error = clGetPlatformIDs(0, NULL, &num_platforms);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    // Get the list of platforms
    cl_platform_id* platforms = (cl_platform_id *) malloc(sizeof(cl_platform_id) * num_platforms);
    error = clGetPlatformIDs(num_platforms, platforms, NULL);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    // Print the chosen platform (if there are multiple platforms, choose the first one)
    cl_platform_id platform = platforms[0];
    char pbuf[100];
    error = clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, sizeof(pbuf), pbuf, NULL);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    printf("Platform: %s\n", pbuf);

    // Create a GPU context
    cl_context_properties context_properties[3] = { CL_CONTEXT_PLATFORM, (cl_context_properties) platform, 0};
    context = clCreateContextFromType(context_properties, devType, NULL, NULL, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    // Get and print the chosen device (if there are multiple devices, choose the first one)
    size_t devices_size;
    error = clGetContextInfo(context, CL_CONTEXT_DEVICES, 0, NULL, &devices_size);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    cl_device_id *devices = (cl_device_id *) malloc(devices_size);
    error = clGetContextInfo(context, CL_CONTEXT_DEVICES, devices_size, devices, NULL);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    device = devices[0];
    error = clGetDeviceInfo(device, CL_DEVICE_NAME, sizeof(pbuf), pbuf, NULL);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    printf("Device: %s\n", pbuf);

    // Create a command queue
    command_queue = clCreateCommandQueue(context, device, 0, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);



    int size;
    float *FilesavingTemp,*FilesavingPower; //,*MatrixOut;

    int pyramid_height = 1;
    int total_iterations= iterations;


    size=grid_rows*grid_cols;

    // --------------- pyramid parameters ---------------
    int borderCols = (pyramid_height)*EXPAND_RATE/2;
    int borderRows = (pyramid_height)*EXPAND_RATE/2;
    int smallBlockCol = BLOCK_SIZE-(pyramid_height)*EXPAND_RATE;
    int smallBlockRow = BLOCK_SIZE-(pyramid_height)*EXPAND_RATE;
    int blockCols = grid_cols/smallBlockCol+((grid_cols%smallBlockCol==0)?0:1);
    int blockRows = grid_rows/smallBlockRow+((grid_rows%smallBlockRow==0)?0:1);

    FilesavingTemp = (float *) malloc(size*sizeof(float));
    FilesavingPower = (float *) malloc(size*sizeof(float));
    // MatrixOut = (float *) calloc (size, sizeof(float));

    if( !FilesavingPower || !FilesavingTemp) // || !MatrixOut)
        fatal("unable to allocate memory");

    // Read input data from disk
    readinput(FilesavingTemp, grid_rows, grid_cols, input_temp);
    readinput(FilesavingPower, grid_rows, grid_cols, input_power);

    // Load kernel source from file
    //const char *source = load_kernel_source(kernel_file);
    size_t sourceSize = strlen(kernel_hotspot_ocl);

    // Compile the kernel
    cl_program program = clCreateProgramWithSource(context, 1, &kernel_hotspot_ocl, &sourceSize, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    char clOptions[110];
    //  sprintf(clOptions,"-I../../src");
    sprintf(clOptions," ");
#ifdef BLOCK_SIZE
    sprintf(clOptions + strlen(clOptions), " -DBLOCK_SIZE=%d", BLOCK_SIZE);
#endif

    // Create an executable from the kernel
    error = clBuildProgram(program, 1, &device, clOptions, NULL, NULL);
    // Show compiler warnings/errors
    static char log[65536];
    memset(log, 0, sizeof(log));
    clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, sizeof(log)-1, log, NULL);
    if (strstr(log,"warning:") || strstr(log, "error:")) printf("<<<<\n%s\n>>>>\n", log);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    kernel = clCreateKernel(program, "hotspot", &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);


    long long start_time = get_time_helper();

    // Create two temperature matrices and copy the temperature input data
    cl_mem MatrixTemp[2];
    // Create input memory buffers on device
    MatrixTemp[0] = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR, sizeof(float) * size, FilesavingTemp, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);
    MatrixTemp[1] = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_ALLOC_HOST_PTR, sizeof(float) * size, NULL, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    // Copy the power input data
    cl_mem MatrixPower = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_USE_HOST_PTR, sizeof(float) * size, FilesavingPower, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

flops=0;
kernel_time = mysecond();
    // Perform the computation
    int ret = compute_tran_temp(MatrixPower, MatrixTemp, grid_cols, grid_rows, total_iterations, pyramid_height,
                                blockCols, blockRows, borderCols, borderRows);
kernel_time = mysecond() - kernel_time;
    // Copy final temperature data back
    cl_float *MatrixOut = (cl_float *) clEnqueueMapBuffer(command_queue, MatrixTemp[ret], CL_TRUE, CL_MAP_READ, 0, sizeof(float) * size, 0, NULL, NULL, &error);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    long long end_time = get_time_helper();
    printf("Total time: %.3f seconds\n", ((float) (end_time - start_time)) / (1000*1000));

    // Write final output to output file
    writeoutput(MatrixOut, grid_rows, grid_cols, output);

	/////////// PERF
    double outputpersec = (double)((grid_rows*grid_rows)/kernel_time);
    printf("kernel time: %lf\n",kernel_time);
    printf("SIZE:%d OUTPUT/S:%f FLOPS: %f\n",grid_rows, outputpersec, (double)flops/kernel_time);
	///////////

    error = clEnqueueUnmapMemObject(command_queue, MatrixTemp[ret], (void *) MatrixOut, 0, NULL, NULL);
    if (error != CL_SUCCESS) fatal_CL(error, __LINE__);

    clReleaseMemObject(MatrixTemp[0]);
    clReleaseMemObject(MatrixTemp[1]);
    clReleaseMemObject(MatrixPower);

    clReleaseContext(context);

    return 0;
}
