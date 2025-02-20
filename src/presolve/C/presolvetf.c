/* presolvetf.c */
/* Full test for the PRESOLVE C interface using Fortran sparse matrix indexing */

#include <stdio.h>
#include <math.h>
#include "galahad_presolve.h"

int main(void) {

    // Derived types
    void *data;
    struct presolve_control_type control;
    struct presolve_inform_type inform;

    // Set problem data
    int n = 6; // dimension
    int m = 5; // number of general constraints
    int H_ne = 1; // Hesssian elements
    int H_row[] = {1};   // row indices, NB lower triangle
    int H_col[] = {1};    // column indices, NB lower triangle
    int H_ptr[] = {1, 2, 2, 2, 2, 2, 2}; // row pointers
    double H_val[] = {1.0};   // values
    double g[] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0}; // linear term in the objective
    double f = 1.0;  // constant term in the objective
    int A_ne = 8; // Jacobian elements
    int A_row[] = {3, 3, 3, 4, 4, 5, 5, 5}; // row indices
    int A_col[] = {3, 4, 5, 3, 6, 4, 5, 6}; // column indices
    int A_ptr[] = {1, 1, 1, 4, 6, 9}; // row pointers
    double A_val[] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0}; // values
    double c_l[] = { 0.0, 0.0, 2.0, 1.0, 3.0};   // constraint lower bound
    double c_u[] = {1.0, 1.0, 3.0, 3.0, 3.0};   // constraint upper bound
    double x_l[] = {-3.0, 0.0, 0.0, 0.0, 0.0, 0.0}; // variable lower bound
    double x_u[] = {3.0, 1.0, 1.0, 1.0, 1.0, 1.0}; // variable upper bound

    // Set output storage
    char st;
    int status;

    printf(" Fortran sparse matrix indexing\n\n");

    printf(" basic tests of qp storage formats\n\n");

    for( int d=1; d <= 7; d++){

      int n_trans, m_trans, H_ne_trans, A_ne_trans;

        // Initialize PRESOLVE
        presolve_initialize( &data, &control, &status );

        // Set user-defined control options
        control.f_indexing = true; // Fortran sparse matrix indexing

        switch(d){
            case 1: // sparse co-ordinate storage
                st = 'C';
                presolve_import_problem( &control, &data, &status, n, m,
                           "coordinate", H_ne, H_row, H_col, NULL, H_val, g, f,
                           "coordinate", A_ne, A_row, A_col, NULL, A_val,
                           c_l, c_u, x_l, x_u,
                           &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            printf(" case %1i break\n",d);
            case 2: // sparse by rows
                st = 'R';
                presolve_import_problem( &control, &data, &status, n, m,
                       "sparse_by_rows", H_ne, NULL, H_col, H_ptr, H_val, g, f,
                       "sparse_by_rows", A_ne, NULL, A_col, A_ptr, A_val,
                       c_l, c_u, x_l, x_u,
                       &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            case 3: // dense
                st = 'D';
                int H_dense_ne = n*(n+1)/2; // number of elements of H
                int A_dense_ne = m*n; // number of elements of A
                double H_dense[] = {1.0,
                                    0.0, 0.0,
                                    0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
                double A_dense[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.0, 0.0, 1.0, 1.0, 1.0, 0.0,
                                    0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
                                    0.0, 0.0, 0.0, 1.0, 1.0, 1.0};
                presolve_import_problem( &control, &data, &status, n, m,
                            "dense", H_dense_ne, NULL, NULL, NULL, H_dense, g,
                            f, "dense", A_dense_ne, NULL, NULL, NULL, A_dense,
                            c_l, c_u, x_l, x_u,
                            &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            case 4: // diagonal
                st = 'L';
                presolve_import_problem( &control, &data, &status, n, m,
                            "diagonal", n, NULL, NULL, NULL, H_val, g, f,
                            "sparse_by_rows", A_ne, NULL, A_col, A_ptr, A_val,
                            c_l, c_u, x_l, x_u,
                            &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;

            case 5: // scaled identity
                st = 'S';
                presolve_import_problem( &control, &data, &status, n, m,
                        "scaled_identity", 1, NULL, NULL, NULL, H_val, g, f,
                        "sparse_by_rows", A_ne, NULL, A_col, A_ptr, A_val,
                        c_l, c_u, x_l, x_u,
                        &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            case 6: // identity
                st = 'I';
                presolve_import_problem( &control, &data, &status, n, m,
                            "identity", 0, NULL, NULL, NULL, NULL, g, f,
                            "sparse_by_rows", A_ne, NULL, A_col, A_ptr, A_val,
                            c_l, c_u, x_l, x_u,
                            &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            case 7: // zero
                st = 'Z';
                presolve_import_problem( &control, &data, &status, n, m,
                            "zero", 0, NULL, NULL, NULL, NULL, g, f,
                            "sparse_by_rows", A_ne, NULL, A_col, A_ptr, A_val,
                            c_l, c_u, x_l, x_u,
                            &n_trans, &m_trans, &H_ne_trans, &A_ne_trans );
                break;
            }

        //printf("%c: n, m, h_ne, a_ne = %2i, %2i, %2i, %2i\n",
        //           st, n_trans, m_trans, H_ne_trans, A_ne_trans);
        double f_trans;  // transformed constant term in the objective
        int H_ptr_trans[n_trans+1]; // transformed Hessian row pointers
        int H_col_trans[H_ne_trans]; // transformed Hessian column indices
        double H_val_trans[H_ne_trans]; // transformed Hessian values
        double g_trans[n_trans]; // transformed gradient
        int A_ptr_trans[m_trans+1]; // transformed Jacobian row pointers
        int A_col_trans[A_ne_trans]; // transformed Jacobian column indices
        double A_val_trans[A_ne_trans]; // transformed Jacobian values
        double x_l_trans[n_trans]; // transformed lower variable bounds
        double x_u_trans[n_trans]; // transformed upper variable bounds
        double c_l_trans[m_trans]; // transformed lower constraint bounds
        double c_u_trans[m_trans]; // transformed upper constraint bounds
        double y_l_trans[m_trans]; // transformed lower multiplier bounds
        double y_u_trans[m_trans]; // transformed upper multiplier bounds
        double z_l_trans[n_trans]; // transformed lower dual variable bounds
        double z_u_trans[n_trans]; // transformed upper dual variable bounds

        presolve_transform_problem( &data, &status, n_trans, m_trans,
                               H_ne_trans, H_col_trans, H_ptr_trans,
                               H_val_trans, g_trans, &f_trans, A_ne_trans,
                               A_col_trans, A_ptr_trans, A_val_trans,
                               c_l_trans, c_u_trans, x_l_trans, x_u_trans,
                               y_l_trans, y_u_trans, z_l_trans, z_u_trans );

        double x_trans[n_trans]; // transformed variables
        for( int i = 0; i < n_trans; i++) x_trans[i] = 0.0;
        double c_trans[m_trans]; // transformed constraints
        for( int i = 0; i < m_trans; i++) c_trans[i] = 0.0;
        double y_trans[m_trans]; // transformed Lagrange multipliers
        for( int i = 0; i < m_trans; i++) y_trans[i] = 0.0;
        double z_trans[n_trans]; // transformed dual variables
        for( int i = 0; i < n_trans; i++) z_trans[i] = 0.0;

        double x[n]; // primal variables
        double c[m]; // constraint values
        double y[m]; // Lagrange multipliers
        double z[n]; // dual variables

        //printf("%c: n_trans, m_trans, n, m = %2i, %2i, %2i, %2i\n",
        //           st, n_trans, m_trans, n, m );
        presolve_restore_solution( &data, &status, n_trans, m_trans,
                  x_trans, c_trans, y_trans, z_trans, n, m, x, c, y, z );

        presolve_information( &data, &inform, &status );

        if(inform.status == 0){
            printf("%c:%6i transformations, n, m = %2i, %2i, status = %1i\n",
                   st, inform.nbr_transforms, n_trans, m_trans, inform.status);
        }else{
            printf("%c: PRESOLVE_solve exit status = %1i\n", st, inform.status);
        }
        //printf("x: ");
        //for( int i = 0; i < n; i++) printf("%f ", x[i]);
        //printf("\n");
        //printf("gradient: ");
        //for( int i = 0; i < n; i++) printf("%f ", g[i]);
        //printf("\n");

        // Delete internal workspace
        presolve_terminate( &data, &control, &inform );
    }
}
