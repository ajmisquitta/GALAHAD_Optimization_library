/* dpstf.c */
/* Full test for the DPS C interface using Fortran sparse matrix indexing */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "galahad_dps.h"

int main(void) {

    // Derived types
    void *data;
    struct dps_control_type control;
    struct dps_inform_type inform;

    // Set problem data
    int n = 3; // dimension of H
    int m = 1; // dimension of A
    int H_ne = 4; // number of elements of H
    int H_dense_ne = 6; // number of elements of H
    int H_row[] = {1, 2, 3, 3}; // row indices, NB lower triangle
    int H_col[] = {1, 2, 3, 1};
    int H_ptr[] = {1, 2, 3, 5};
    double H_val[] = {1.0, 2.0, 3.0, 4.0};
    double H_dense[] = {1.0, 0.0, 2.0, 4.0, 0.0, 3.0};
    double f = 0.96;
    double radius = 1.0;
    double half_radius = 0.5;
    double c[] = {0.0, 2.0, 0.0};

    char st;
    int status;
    double x[n];

    printf(" Fortran sparse matrix indexing\n\n");

    printf(" basic tests of storage formats\n\n");

    for( int storage_type=1; storage_type <= 3; storage_type++){

    // Initialize DPS
      dps_initialize( &data, &control, &status );

    // Set user-defined control options
      control.f_indexing = true; // fortran sparse matrix indexing

      switch(storage_type){
        case 1: // sparse co-ordinate storage
            st = 'C';
            // import the control parameters and structural data
            dps_import( &control, &data, &status, n,
                       "coordinate", H_ne, H_row, H_col, NULL );
            // solve the problem
            dps_solve_tr_problem( &data, &status, n, H_ne, H_val, 
                                  c, f, radius, x );
            break;
        case 2: // sparse by rows
            st = 'R';
            // import the control parameters and structural data
            dps_import( &control, &data, &status, n,
                        "sparse_by_rows", H_ne, NULL, H_col, H_ptr );
            dps_solve_tr_problem( &data, &status, n, H_ne, H_val,
                                  c, f, radius, x );
            break;
        case 3: // dense
            st = 'D';
            // import the control parameters and structural data
            dps_import( &control, &data, &status, n,
                        "dense", H_ne, NULL, NULL, NULL );
            dps_solve_tr_problem( &data, &status, n, H_dense_ne, H_dense,
                                  c, f, radius, x );
            break;
        }

      dps_information( &data, &inform, &status );
      printf("format %c: DPS_solve_problem exit status   = %1i, f = %.2f\n",
             st, inform.status, inform.obj );

      switch(storage_type){
        case 1: // sparse co-ordinate storage
            st = 'C';
            // solve the problem
            dps_resolve_tr_problem( &data, &status, n, 
                                    c, f, half_radius, x );
            break;
        case 2: // sparse by rows
            st = 'R';
            dps_resolve_tr_problem( &data, &status, n,
                                    c, f, half_radius, x );
            break;
        case 3: // dense
            st = 'D';
            dps_resolve_tr_problem( &data, &status, n,
                                    c, f, half_radius, x );
            break;
        }

      dps_information( &data, &inform, &status );
      printf("format %c: DPS_resolve_problem exit status = %1i, f = %.2f\n",
             st, inform.status, inform.obj );
      //printf("x: ");
      //for( int i = 0; i < n+m; i++) printf("%f ", x[i]);

      // Delete internal workspace
      dps_terminate( &data, &control, &inform );
   }
}

