/* rqst.c */
/* Full test for the RQS C interface using C sparse matrix indexing */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "galahad_rqs.h"

int main(void) {

    // Derived types
    void *data;
    struct rqs_control_type control;
    struct rqs_inform_type inform;

    // Set problem data
    int n = 3; // dimension of H
    int m = 1; // dimension of A
    int H_ne = 4; // number of elements of H
    int M_ne = 3; // number of elements of M
    int A_ne = 3; // number of elements of A
    int H_dense_ne = 6; // number of elements of H
    int M_dense_ne = 6; // number of elements of M
    int H_row[] = {0, 1, 2, 2}; // row indices, NB lower triangle
    int H_col[] = {0, 1, 2, 0};
    int H_ptr[] = {0, 1, 2, 4};
    int M_row[] = {0, 1, 2}; // row indices, NB lower triangle
    int M_col[] = {0, 1, 2};
    int M_ptr[] = {0, 1, 2, 3};
    int A_row[] = {0, 0, 0} ;
    int A_col[] = {0, 1, 2};
    int A_ptr[] = {0, 3};
    double H_val[] = {1.0, 2.0, 3.0, 4.0};
    double M_val[] = {1.0, 2.0, 1.0};
    double A_val[] = {1.0, 1.0, 1.0};
    double H_dense[] = {1.0, 0.0, 2.0, 4.0, 0.0, 3.0};
    double M_dense[] = {1.0, 0.0, 2.0, 0.0, 0.0, 1.0};
    double H_diag[] = {1.0, 0.0, 2.0};
    double M_diag[] = {1.0, 2.0, 1.0};
    double f = 0.96;
    double power = 3.0;
    double weight = 1.0;
    double c[] = {0.0, 2.0, 0.0};

    char st;
    int status;
    double x[n];
    char ma[3];

    printf(" C sparse matrix indexing\n\n");

    printf(" basic tests of storage formats\n\n");

    for( int a_is=0; a_is <= 1; a_is++){ // add a linear constraint?
      for( int m_is=0; m_is <= 1; m_is++){ // include a scaling matrix?

        if (a_is == 1 && m_is == 1 ) {
          strcpy(ma, "MA");
        }
        else if (a_is == 1) {
          strcpy(ma, "A ");
        }
        else if (m_is == 1) {
          strcpy(ma, "M ");
        }
        else {
          strcpy(ma, "  ");
        }

        for( int storage_type=1; storage_type <= 4; storage_type++){

          // Initialize RQS
          rqs_initialize( &data, &control, &status );

          // Set user-defined control options
          control.f_indexing = false; // C sparse matrix indexing

          switch(storage_type){
              case 1: // sparse co-ordinate storage
                  st = 'C';
                  // import the control parameters and structural data
                  rqs_import( &control, &data, &status, n,
                             "coordinate", H_ne, H_row, H_col, NULL );
                  if (m_is == 1) {
                    rqs_import_m( &data, &status, n,
                                  "coordinate", M_ne, M_row, M_col, NULL );
                  }
                  if (a_is == 1) {
                    rqs_import_a( &data, &status, m,
                                  "coordinate", A_ne, A_row, A_col, NULL );
                  }
                  // solve the problem
                  if (a_is == 1 && m_is == 1 ) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       M_ne, M_val, m, A_ne, A_val, NULL );
                  }
                  else if (a_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       0, NULL, m, A_ne, A_val, NULL );
                  }
                  else if (m_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       M_ne, M_val, 0, 0, NULL, NULL );
                  }
                  else {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       0, NULL, 0, 0, NULL, NULL );
                  }
                  break;
              printf(" case %1i break\n", storage_type );
              case 2: // sparse by rows
                  st = 'R';
                  // import the control parameters and structural data
                  rqs_import( &control, &data, &status, n,
                              "sparse_by_rows", H_ne, NULL, H_col, H_ptr );
                  if (m_is == 1) {
                    rqs_import_m( &data, &status, n,
                                  "sparse_by_rows", M_ne, NULL, M_col, M_ptr );
                  }
                  if (a_is == 1) {
                    rqs_import_a( &data, &status, m,
                                 "sparse_by_rows", A_ne, NULL, A_col, A_ptr );
                  }
                  // solve the problem
                  if (a_is == 1 && m_is == 1 ) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       M_ne, M_val, m, A_ne, A_val, NULL );
                  }
                  else if (a_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       0, NULL, m, A_ne, A_val, NULL );
                  }
                  else if (m_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       M_ne, M_val, 0, 0, NULL, NULL );
                  }
                  else {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, H_ne, H_val, x,
                                       0, NULL, 0, 0, NULL, NULL );
                  }
                  break;
              case 3: // dense
                  st = 'D';
                  // import the control parameters and structural data
                  rqs_import( &control, &data, &status, n,
                              "dense", H_ne, NULL, NULL, NULL );
                  if (m_is == 1) {
                    rqs_import_m( &data, &status, n,
                                 "dense", M_ne, NULL, NULL, NULL );
                  }
                  if (a_is == 1) {
                    rqs_import_a( &data, &status, m,
                                 "dense", A_ne, NULL, NULL, NULL );
                  }
                  // solve the problem
                  if (a_is == 1 && m_is == 1 ) {
                    rqs_solve_problem( &data, &status, n, power, weight, 
                                       f, c, H_dense_ne, H_dense, x,
                                       M_dense_ne, M_dense, m, A_ne, A_val, 
                                       NULL );
                  }
                  else if (a_is == 1) {
                    rqs_solve_problem( &data, &status, n, power, weight, 
                                       f, c, H_dense_ne, H_dense, x,
                                       0, NULL, m, A_ne, A_val, NULL );
                  }
                  else if (m_is == 1) {
                    rqs_solve_problem( &data, &status, n, power, weight, 
                                       f, c, H_dense_ne, H_dense, x,
                                       M_dense_ne, M_dense, 0, 0, NULL, NULL );
                  }
                  else {
                    rqs_solve_problem( &data, &status, n, power, weight, 
                                       f, c, H_dense_ne, H_dense, x,
                                       0, NULL, 0, 0, NULL, NULL );
                  }
                  break;
              case 4: // diagonal
                  st = 'L';
                  // import the control parameters and structural data
                  rqs_import( &control, &data, &status, n,
                              "diagonal", H_ne, NULL, NULL, NULL );
                  if (m_is == 1) {
                    rqs_import_m( &data, &status, n,
                                 "diagonal", M_ne, NULL, NULL, NULL );
                  }
                  if (a_is == 1) {
                    rqs_import_a( &data, &status, m,
                                 "dense", A_ne, NULL, NULL, NULL );
                  }
                  // solve the problem
                  if (a_is == 1 && m_is == 1 ) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, n, H_diag, x,
                                       n, M_diag, m, A_ne, A_val, NULL );
                  }
                  else if (a_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, n, H_diag, x,
                                       0, NULL, m, A_ne, A_val, NULL );
                  }
                  else if (m_is == 1) {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, n, H_diag, x,
                                       n, M_diag, 0, 0, NULL, NULL );
                  }
                  else {
                    rqs_solve_problem( &data, &status, n, 
                                       power, weight, f, c, n, H_diag, x,
                                       0, NULL, 0, 0, NULL, NULL );
                  }
                  break;
              }

          rqs_information( &data, &inform, &status );

          printf("format %c%s: RQS_solve_problem exit status = %1i, f = %.2f\n",
                 st, ma, inform.status, inform.obj_regularized );
          //printf("x: ");
          //for( int i = 0; i < n+m; i++) printf("%f ", x[i]);

          // Delete internal workspace
          rqs_terminate( &data, &control, &inform );
       }
     }
   }
}

