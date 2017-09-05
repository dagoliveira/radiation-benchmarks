#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <omp.h>

#ifdef LOGS
#include "../../include/log_helper.h"
#endif

#define REC_LENGTH 49	// size of a record in db
#define REC_WINDOW 10	// number of records to read at a time
#define LATITUDE_POS 28	// location of latitude coordinates in input record
#define OPEN 1000000	// initial value of nearest neighbors

struct neighbor {
    char entry[REC_LENGTH];
    double dist;
};


int compare_neighbor(struct neighbor n1, struct neighbor n2) {
    if (strcmp(n1.entry,n2.entry) != 0)
        return 1;
    if(n1.dist != n2.dist)
        return 1;
    return 0;
}

/**
* This program finds the k-nearest neighbors
* Usage:	./nn <filelist obs: all records in one single file> <num> <target latitude> <target longitude> <gold filename> <#num-of-records-to-read> <#iterations>
*			filelist: File with the filenames to the records
*			num: Number of nearest neighbors to find
*			target lat: Latitude coordinate for distance calculations
*			target long: Longitude coordinate for distance calculations
* The filelist and data are generated by hurricane_gen.c
* REC_WINDOW has been arbitrarily assigned; A larger value would allow more work for the threads
*/
int main(int argc, char* argv[]) {
    FILE   *flist,*fp;
    int    i=0,j=0, k=0, rec_count=0, done=0;
    //char   sandbox[REC_LENGTH * REC_WINDOW], *rec_iter,*rec_iter2, dbname[64];
    char   *sandbox, *rec_iter,*rec_iter2, dbname[64];
    struct neighbor *neighbors = NULL;
    struct neighbor *neighbors_gold = NULL;
    float target_lat, target_long, tmp_lat=0, tmp_long=0;
    char * gold_filename;
    long num_records;
    long loop_iterations=1;

    if(argc < 8) {
        fprintf(stderr, "Invalid set of arguments:\n");
        fprintf(stderr, "%s <filelist obs: all records in one single file> <num> <target latitude> <target longitude> <gold filename> <#num-of-records-to-read> <#iterations>\n",argv[0]);
        exit(-1);
    }


    k = atoi(argv[2]);
    target_lat = atof(argv[3]);
    target_long = atof(argv[4]);
    gold_filename = argv[5];
    num_records = atoi(argv[6]);
    loop_iterations = atoi(argv[7]);

    sandbox = (char *)malloc(sizeof(char)*REC_LENGTH*num_records);
    neighbors = malloc(k*sizeof(struct neighbor));
    neighbors_gold = malloc(k*sizeof(struct neighbor));

    if(neighbors == NULL) {
        fprintf(stderr, "no room for neighbors\n");
        exit(0);
    }

#ifdef LOGS
    set_iter_interval_print(10);
    char test_info[200];
    snprintf(test_info, 200, "filename:%s k:%d latitude:%f longitude:%f records:%d", argv[1], k,target_lat,target_long,num_records);
    start_log_file("openmpNN", test_info);
#endif


    /**** main processing ****/
    flist = fopen(argv[1], "r");
    if(!flist) {
        printf("error opening flist\n");
        exit(1);
    }
    if(fscanf(flist, "%s\n", dbname) != 1) {
        fprintf(stderr, "error reading filelist\n");
        exit(0);
    }

    fp = fopen(dbname, "r");
    if(!fp) {
        printf("error opening flist\n");
        exit(1);
    }

    rec_count = fread(sandbox, REC_LENGTH, num_records, fp);
    fclose(fp);
    fclose(flist);

    /******* read gold **********/
    FILE *file;
    if( (file = fopen(gold_filename, "rb" )) == 0 )
        printf( "The GOLD file was not opened\n" );
    char t[200];
    for( j = 0 ; j < k ; j++ ) {
        fread(&neighbors_gold[j], sizeof(struct neighbor), 1, file);
    }
    fclose(file);



    float *z;
    //z  = (float *) malloc(REC_WINDOW * sizeof(float));
    z  = (float *) malloc(num_records * sizeof(float));


    int loop;
    for(loop=0; loop<loop_iterations; loop++) {
    	for( j = 0 ; j < k ; j++ ) { //Initialize list of nearest neighbors to very large dist
        	neighbors[j].dist = OPEN;
	    }

#ifdef LOGS
        start_iteration();
#endif
        #pragma omp parallel for shared (z, target_lat, target_long) private(i,rec_iter)
        for (i = 0; i < rec_count; i++) {
            rec_iter = sandbox+(i * REC_LENGTH + LATITUDE_POS - 1);
            float tmp_lat = atof(rec_iter);
            float tmp_long = atof(rec_iter+5);
            z[i] = sqrt(( (tmp_lat-target_lat) * (tmp_lat-target_lat) )+( (tmp_long-target_long) * (tmp_long-target_long) ));
        }
        #pragma omp barrier
        // end of Lingjie Zhang's modification


        for( i = 0 ; i < rec_count ; i++ ) {
            float max_dist = -1;
            int max_idx = 0;
            // find a neighbor with greatest dist and take his spot if allowed!
            for( j = 0 ; j < k ; j++ ) {
                if( neighbors[j].dist > max_dist ) {
                    max_dist = neighbors[j].dist;
                    max_idx = j;
                }
            }
            // compare each record with max value to find the nearest neighbor
            if( z[i] < neighbors[max_idx].dist ) {
                sandbox[(i+1)*REC_LENGTH-1] = '\0';
                strcpy(neighbors[max_idx].entry, sandbox +i*REC_LENGTH);
                neighbors[max_idx].dist = z[i];
            }
        }

#ifdef LOGS
        end_iteration();
#endif


        int errors =0;
        for( j = 0 ; j < k ; j++ ) {
            if( !(neighbors[j].dist == OPEN) ) {
                if(compare_neighbor(neighbors[j], neighbors_gold[j])) {
                    errors++;
                    fprintf(stdout, "OUTP: %s --> %f\n", neighbors[j].entry, neighbors[j].dist);
                    fprintf(stdout, "GOLD: %s --> %f\n", neighbors_gold[j].entry, neighbors_gold[j].dist);
#ifdef LOGS
                    log_error_detail(error_detail);
#endif
                }
            }
        }

#ifdef LOGS
        log_error_count(errors);
#endif
        if(errors > 0) {
            printf("Errors: %d\n",errors);

            flist = fopen(argv[1], "r");
            if(!flist) {
                printf("error opening flist\n");
                exit(1);
            }
            if(fscanf(flist, "%s\n", dbname) != 1) {
                fprintf(stderr, "error reading filelist\n");
                exit(0);
            }

            fp = fopen(dbname, "r");
            if(!fp) {
                printf("error opening flist\n");
                exit(1);
            }

            rec_count = fread(sandbox, REC_LENGTH, num_records, fp);
            fclose(fp);
            fclose(flist);

            /******* read gold **********/
            if( (file = fopen(gold_filename, "rb" )) == 0 )
                printf( "The GOLD file was not opened\n" );
            char t[200];
            for( j = 0 ; j < k ; j++ ) {
                fread(&neighbors_gold[j], sizeof(struct neighbor), 1, file);
            }
            fclose(file);
        } else {
            printf(".");
        }
    }

#ifdef LOGS
    end_log_file();
#endif

    return 0;
}

