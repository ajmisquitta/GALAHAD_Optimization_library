#include <fintrf.h>

!  THIS VERSION: GALAHAD 4.0 - 2022-03-16 AT 09:30 GMT.

! *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
!
!                 MEX INTERFACE TO GALAHAD_BGO
!
! *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
!
!  find an approximate bound-constrained global minimizer of a differentiable 
!  objective function f(x) of n real variables x using a multi-start 
!  trust-region method. Advantage may be taken of sparsity in the Hessian 
!  of f(x)
!
!  Simple usage -
!
!  to find the minimizer
!   [ x, inform ]
!    = galahad_bgo( x_l, x_u, x_0, eval_f, eval_g, eval_h, eval_hprod, ...
!                   pattern_h, control )
!   [ x, inform ]
!    = galahad_bgo( x_l, x_u, x_0, eval_f, eval_g, eval_h, eval_hprod, ...
!                   control )
!   [ x, inform ]
!    = galahad_bgo( x_l, x_u, x_0, eval_f, eval_g, eval_h, eval_hprod, ...
!                   pattern_h )
!   [ x, inform ]
!    = galahad_bgo( x_l, x_u, x_0, eval_f, eval_g, eval_h, eval_hprod )
!
!  Sophisticated usage -
!
!  to initialize data and control structures prior to solution
!   [ control ]
!    = galahad_bgo( 'initial' )
!
!  to solve the problem using existing data structures
!   [ x, inform ]
!    = galahad_bgo( 'existing', x_l, x_u, x_0, eval_f, eval_g, eval_h, ...
!                   eval_hprod, pattern_h, control )
!   [ x, inform ]
!    = galahad_bgo( 'existing', x_l, x_u, x_0, eval_f, eval_g, eval_h, ...
!                   eval_hprod, control )
!   [ x, inform ]
!    = galahad_bgo( 'existing', x_l, x_u, x_0, eval_f, eval_g, eval_h, ...
!                   eval_hprod, pattern_h )
!   [ x, inform ]
!    = galahad_bgo( 'existing', x_l, x_u, x_0, eval_f, eval_g, eval_h, ...
!                   eval_hprod )
!
!  to remove data structures after solution
!   galahad_bgo( 'final' )
!
!  Usual Input -
!       x_l: the finite n-vector x_l.
!       x_u: the finite n-vector x_u.
!       x_0: an initial estimate of the minimizer
!    eval_f: a user-provided subroutine named eval_f.m for which
!              [f,status] = eval_f(x)
!            returns the value of objective function f at x.
!            status should be set to 0 if the evaluation succeeds,
!            and a non-zero value if the evaluation fails.
!    eval_g: a user-provided subroutine named eval_g.m for which
!              [g,status] = eval_g(x)
!            returns the vector of gradients of objective function
!            f at x; g(i) contains the derivative df/dx_i at x.
!            status should be set to 0 if the evaluation succeeds,
!            and a non-zero value if the evaluation fails.
!    eval_h: a user-provided subroutine named eval_h.m for which
!              [h_val,status] = eval_h(x)
!            returns a vector of values of the Hessian of objective
!            function f at x (if required). If H is dense, the
!            i*(i-1)/2+j-th conponent of h_val should contain the
!            derivative d^2f/dx_i dx_j at x, 1<=j<=i<=n. If H is sparse,
!            the k-th component of h_val contains the derivative
!            d^2f/dx_i dx_j for which i=pattern_h(k,1) and j=pattern_h(k,2),
!            see below. status should be set to 0 if the evaluation
!            succeeds, and a non-zero value if the evaluation fails.
!    eval_hprod: a user-provided subroutine named eval_hprod.m for which
!              [u,status] = eval_hprod(x,u,v)
!            returns a vector of values of the sum u + H(x) v of the vector u
!            and the product of the Hessian H(x) of objective function f at x 
!            (if required) times the vector v as u
!
!  Optional Input -
!   pattern_h: an integer matrix of size (nz,2) for which
!              pattern_h(k,1) and pattern_h(k,2) give the row and
!              column indices of the entries in the *lower-triangular*
!              part (i.e., pattern_h(k,1) >= pattern_h(k,2)) of
!              the Hessian for k=1:nz. This allows users to specify the
!              Hessian as a sparse matrix. If pattern_h is not present,
!              the matrix will be presumed to be dense.
!     control: a structure containing control parameters.
!              The components are of the form control.value, where
!              value is the name of the corresponding component of
!              the derived type BGO_control_type as described in
!              the manual for the fortran 90 package GALAHAD_BGO.
!              See: http://galahad.rl.ac.uk/galahad-www/doc/bgo.pdf
!
!  Usual Output -
!          x: a first-order criticl point that is usually a local minimizer.
!
!  Optional Output -
!    control: see above. Returned values are the defaults
!     inform: a structure containing information parameters
!             The components are of the form inform.value, where
!             value is the name of the corresponding component of the
!             derived type BGO_inform_type as described in the manual
!             for the fortran 90 package GALAHAD_BGO. The components
!             of inform.time, inform.PSLS_inform, inform.GLTR_inform,
!             inform.TRS_inform, inform.LMS_inform and
!             inform.SHA_inform are themselves structures, holding the
!             components of the derived types BGO_time_type,
!             PSLS_inform_type, GLTR_inform_type, TRS_inform_type,
!             LMS_inform_type, and SHA_inform_type, respectively.
!             See: http://galahad.rl.ac.uk/galahad-www/doc/bgo.pdf
!
! *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

!  Copyright reserved, Gould/Orban/Toint, for GALAHAD productions
!  Principal author: Nick Gould

!  History -
!   originally released with GALAHAD Version 4.0. March 16th 2022

!  For full documentation, see
!   http://galahad.rl.ac.uk/galahad-www/specs.html

      SUBROUTINE mexFunction( nlhs, plhs, nrhs, prhs )
      USE GALAHAD_MATLAB
!     USE GALAHAD_TRANSFER_MATLAB
      USE GALAHAD_BGO_MATLAB_TYPES
      USE GALAHAD_BGO_double
      USE GALAHAD_USERDATA_double
      IMPLICIT NONE
      INTEGER, PARAMETER :: wp = KIND( 1.0D+0 )

! ------------------------- Do not change -------------------------------

!  Keep the above subroutine, argument, and function declarations for use
!  in all your fortran mex files.
!
      INTEGER * 4 :: nlhs, nrhs
      mwPointer :: plhs( * ), prhs( * )

      INTEGER, PARAMETER :: slen = 30
      LOGICAL :: mxIsChar, mxIsStruct
      mwSize :: mxGetString, mxIsNumeric
      mwPointer :: mxGetPr, mxGetM, mxGetN, mxCreateDoubleMatrix
      INTEGER :: mexCallMATLABWithTrap

      INTEGER ::  mexPrintf
      CHARACTER ( LEN = 200 ) :: str

! -----------------------------------------------------------------------

!  local variables

      INTEGER :: i, info
      INTEGER * 4 :: i4, n, alloc_stat
      INTEGER, PARAMETER :: int4 = KIND( i4 )

      mwSize :: xl_arg, xu_arg
      mwSize :: x0_arg, ef_arg, eg_arg, eh_arg, ep_arg, pat_arg, con_arg, c_arg
      mwSize :: x_arg, i_arg, s_len

      mwPointer :: xl_in, xu_in, xl_pr, xu_pr, v_pr
      mwPointer :: x0_in, pat_in, con_in, x0_pr, pat_pr, p_in, p_pr, u_in, u_pr
      mwPointer :: x_pr, s_in, s_pr, f_in, f_pr, g_in, g_pr, h_in, h_pr
      mwPointer :: input_x( 3 ), output_f( 2 )
      mwPointer :: output_g( 2 ), output_h( 2 ), output_hprod( 2 )
      mwSize :: status
      mwSize :: m_mwsize, n_mwsize

      CHARACTER ( len = 80 ) :: output_unit, filename
!     CHARACTER ( len = 80 ) :: debug = REPEAT( ' ', 80 )
      CHARACTER ( len = 80 ) :: eval_f = REPEAT( ' ', 80 )
      CHARACTER ( len = 80 ) :: eval_g = REPEAT( ' ', 80 )
      CHARACTER ( len = 80 ) :: eval_h = REPEAT( ' ', 80 )
      CHARACTER ( len = 80 ) :: eval_hprod = REPEAT( ' ', 80 )
      LOGICAL :: opened, file_exists, initial_set = .FALSE.
      INTEGER :: iores
      CHARACTER ( len = 8 ) :: mode
      TYPE ( BGO_pointer_type ) :: BGO_pointer
      REAL( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: IW

!  arguments for BGO

      TYPE ( NLPT_problem_type ) :: nlp
      TYPE ( GALAHAD_userdata_type ) :: userdata
      TYPE ( BGO_data_type ), SAVE :: data
      TYPE ( BGO_control_type ), SAVE :: control
      TYPE ( BGO_inform_type ) :: inform

!  Test input/output arguments

      IF ( nrhs < 1 )                                                          &
        CALL mexErrMsgTxt( ' galahad_bgo requires at least 1 input argument' )

!     write(debug,"(I0)") nrhs
!     CALL mexErrMsgTxt( TRIM(debug))
      IF ( mxIsChar( prhs( 1 ) ) ) THEN
        i = mxGetString( prhs( 1 ), mode, 8 )
        IF ( .NOT. ( TRIM( mode ) == 'initial' .OR.                            &
                     TRIM( mode ) == 'final' ) ) THEN
          IF ( nrhs < 5 )                                                      &
            CALL mexErrMsgTxt( ' Too few input arguments to galahad_bgo' )
          xl_arg = 2 ; xu_arg = 3
          x0_arg = 4 ; ef_arg = 5 ; eg_arg = 6 ; eh_arg = 7 ; ep_arg = 8
          IF ( nrhs == 8 ) THEN
            con_arg = - 1 ; pat_arg = - 1
          ELSE IF ( nrhs == 9 ) THEN
            IF ( mxIsStruct( prhs( 9 ) ) ) THEN
              con_arg = 9 ; pat_arg = - 1
            ELSE
              pat_arg = 9 ; con_arg = - 1
            END IF
          ELSE IF ( nrhs == 10 ) THEN
            IF ( mxIsStruct( prhs( 9 ) ) ) THEN
              con_arg = 9 ; pat_arg = 10
            ELSE
              pat_arg = 9 ; con_arg = 10
            END IF
          ELSE
            CALL mexErrMsgTxt( ' Too many input arguments to galahad_bgo' )
          END IF
        END IF
      ELSE
        mode = 'all'

        IF ( nrhs < 4 )                                                        &
          CALL mexErrMsgTxt( ' Too few input arguments to galahad_bgo' )
        xl_arg = 1 ; xu_arg = 2
        x0_arg = 3 ; ef_arg = 4 ; eg_arg = 5 ; eh_arg = 6 ; ep_arg = 7

        IF (  nrhs == 7 ) THEN
          con_arg = - 1 ; pat_arg = - 1
        ELSE IF (  nrhs == 8 ) THEN
          IF ( mxIsStruct( prhs( 8 ) ) ) THEN
            con_arg = 8 ; pat_arg = - 1
          ELSE
            pat_arg = 8 ; con_arg = - 1
          END IF
        ELSE IF (  nrhs == 9 ) THEN
          IF ( mxIsStruct( prhs( 8 ) ) ) THEN
            con_arg = 8 ; pat_arg = 9
          ELSE
            pat_arg = 8 ; con_arg = 9
          END IF
        ELSE
          CALL mexErrMsgTxt( ' Too many input arguments to galahad_bgo' )
        END IF
      END IF

      x_arg = 1
      IF ( nlhs == 1 ) THEN
        i_arg = - 1
      ELSE IF ( nlhs == 2 ) THEN
        i_arg = 2
      ELSE IF ( nlhs > 2 ) THEN
        CALL mexErrMsgTxt( ' galahad_bgo provides at most 2 output arguments' )
      END IF

!  Initialize the internal structures for bgo

      IF ( TRIM( mode ) == 'initial' .OR. TRIM( mode ) == 'all' ) THEN
        initial_set = .TRUE.
        CALL BGO_initialize( data, control, inform )
        IF ( TRIM( mode ) == 'initial' ) THEN
          c_arg = 1
          IF ( nlhs > c_arg )                                                  &
            CALL mexErrMsgTxt( ' too many output arguments required' )

!  if required, return the default control parameters

          IF ( nlhs > 0 )                                                      &
            CALL BGO_matlab_control_get( plhs( c_arg ), control )
          RETURN
        END IF
      END IF

      IF ( .NOT. TRIM( mode ) == 'final' ) THEN

!  check that BGO_initialize has been called

        IF ( .NOT. initial_set )                                               &
          CALL mexErrMsgTxt( ' "initial" must be called first' )

!  find the name of the eval_f routine and ensure it exists

        i = mxGetString( prhs( ef_arg ), eval_f, 80 )
        INQUIRE( file = TRIM( eval_f ) // '.m', exist = file_exists )
        IF ( .NOT. file_exists )                                               &
          CALL mexErrMsgTxt( TRIM( ' function evaluation file ' //             &
                              TRIM( eval_f ) // '.m does not exist' ) )

!  find the name of the eval_g routine and ensure it exists

        i = mxGetString( prhs( eg_arg ), eval_g, 80 )
        INQUIRE( file = TRIM( eval_g) // '.m', exist = file_exists )
        IF ( .NOT. file_exists )                                               &
          CALL mexErrMsgTxt( TRIM( ' gradient evaluation file ' //             &
                              TRIM( eval_g ) // '.m does not exist' ) )

!  find the name of the eval_h routine and ensure it exists

        i = mxGetString( prhs( eh_arg ), eval_h, 80 )
        INQUIRE( file = TRIM( eval_h ) // '.m', exist = file_exists )
        IF ( .NOT. file_exists )                                               &
          CALL mexErrMsgTxt( TRIM( ' Hessian evaluation file ' //              &
                              TRIM( eval_h ) // '.m does not exist' ) )

!  find the name of the eval_h routine and ensure it exists

        i = mxGetString( prhs( ep_arg ), eval_hprod, 80 )
        INQUIRE( file = TRIM( eval_hprod ) // '.m', exist = file_exists )
        IF ( .NOT. file_exists )                                               &
          CALL mexErrMsgTxt( TRIM( ' Hessian product evaluation file ' //      &
                             TRIM( eval_hprod ) // '.m does not exist' ) )

!  If the control argument is present, extract the input control data

        s_len = slen
        IF ( con_arg > 0 ) THEN
          con_in = prhs( con_arg )
          IF ( .NOT. mxIsStruct( con_in ) )                                    &
            CALL mexErrMsgTxt( ' control input argument must be a structure' )
          CALL BGO_matlab_control_set( con_in, control, s_len )
        END IF

!  Open i/o units

        IF ( control%error > 0 ) THEN
          WRITE( output_unit, "( I0 )" ) control%error
          filename = "output_bgo." // TRIM( output_unit )
          OPEN( control%error, FILE = filename, FORM = 'FORMATTED',            &
                STATUS = 'REPLACE', IOSTAT = iores )
        END IF

        IF ( control%out > 0 ) THEN
          INQUIRE( control%out, OPENED = opened )
          IF ( .NOT. opened ) THEN
            WRITE( output_unit, "( I0 )" ) control%out
            filename = "output_bgo." // TRIM( output_unit )
            OPEN( control%out, FILE = filename, FORM = 'FORMATTED',            &
                  STATUS = 'REPLACE', IOSTAT = iores )
          END IF
        END IF

!  Create inform output structure

        CALL BGO_matlab_inform_create( plhs( i_arg ), BGO_pointer )

!  import the problem data

!  find the number of variables

        x0_in = prhs( x0_arg )
        n = INT( mxGetN( x0_in ), KIND = int4 ) ; nlp%n = n

!  allocate space for the solution

        ALLOCATE( nlp%X_l( n ), nlp%X_u( n ), nlp%X( n ), nlp%G( n ),          &
                  STAT = alloc_stat )
        IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' allocation failure ' )

!  set the starting point

        x0_pr = mxGetPr( x0_in )
        CALL MATLAB_copy_from_ptr( x0_pr, nlp%X, n )

!  Input x_l

        xl_in = prhs( xl_arg )
        IF ( mxIsNumeric( xl_in ) == 0 )                                       &
           CALL mexErrMsgTxt( ' There must be a vector x_l ' )
        xl_pr = mxGetPr( xl_in )
        CALL MATLAB_copy_from_ptr( xl_pr, nlp%X_l, nlp%n )
        nlp%X_l = MAX( nlp%X_l, - 10.0_wp * control%infinity )

!  Input x_u

        xu_in = prhs( xu_arg )
        IF ( mxIsNumeric( xu_in ) == 0 )                                       &
           CALL mexErrMsgTxt( ' There must be a vector x_u ' )
        xu_pr = mxGetPr( xu_in )
        CALL MATLAB_copy_from_ptr( xu_pr, nlp%X_u, nlp%n )
        nlp%X_u = MIN( nlp%X_u, 10.0_wp * control%infinity )

!  input the sparsity structure if the Hessian is sparse

        IF ( pat_arg > 0 ) THEN
          pat_in = prhs( pat_arg )
          nlp%H%ne = INT( mxGetM( pat_in ), KIND = int4 )
          IF ( mxIsNumeric( pat_in ) == 0 )                                    &
            CALL mexErrMsgTxt( ' There must be a matrix H ' )

!  copy to a tempoary 1-D real array (the integer version doesn't work!)

          ALLOCATE( IW( nlp%H%ne * 2 ), STAT = alloc_stat )
          IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' allocation failure ' )
          pat_pr = mxGetPr( pat_in )
          CALL MATLAB_copy_from_ptr( pat_pr, IW, nlp%H%ne * 2 )

!  move the sparsity structure into nlp%H

          nlp%H%n = n ; nlp%H%m = n
          CALL SMT_put( nlp%H%type, 'COORDINATE', alloc_stat )
          ALLOCATE( nlp%H%row( nlp%H%ne ), nlp%H%col( nlp%H%ne ),              &
                    STAT = alloc_stat )
          IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' allocation failure ' )
          nlp%H%row( : nlp%H%ne ) = INT( IW( : nlp%H%ne ), KIND = int4 )
          nlp%H%col( : nlp%H%ne ) = INT( IW( nlp%H%ne + 1 : ), KIND = int4 )
          IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' deallocation failure ' )
          ALLOCATE( nlp%H%val( nlp%H%ne ), STAT = alloc_stat )
          IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' allocation failure ' )

!  the Hessian is dense

        ELSE
          nlp%H%ne = INT( ( n * ( n + 1 ) ) / 2, KIND = int4 )
          CALL SMT_put( nlp%H%type, 'DENSE', alloc_stat )
          ALLOCATE( nlp%H%val( nlp%H%ne ), STAT = alloc_stat )
          IF ( alloc_stat /= 0 ) CALL mexErrMsgTxt( ' allocation failure ' )
        END IF

!  set for initial entry

        inform%status = 1
        m_mwsize = 1 ; n_mwsize = n
        input_x( 1 ) = mxCreateDoubleMatrix( m_mwsize, n_mwsize, 0 )
        input_x( 2 ) = mxCreateDoubleMatrix( m_mwsize, n_mwsize, 0 )
        input_x( 3 ) = mxCreateDoubleMatrix( m_mwsize, n_mwsize, 0 )

!  loop to solve problem

!       CALL mexWarnMsgTxt( ' start loop' )
        DO
!        CALL mexWarnMsgTxt( ' enter solve' )
          CALL BGO_solve( nlp, control, inform, data, userdata )
!        CALL mexWarnMsgTxt( ' end solve' )

!  terminal exit from loop

          IF ( inform%status <= 0 ) THEN
!           CALL mexWarnMsgTxt( ' status <= 0' )
            EXIT
          END IF
!         IF ( inform%status == 6 ) CALL mexWarnMsgTxt( ' status = 6' )
!         IF ( inform%status == 7 ) CALL mexWarnMsgTxt( ' status = 7' )
          IF ( inform%status == 23 .OR. inform%status == 25 .OR.               &
               inform%status == 35 .OR. inform%status == 235 ) THEN
          ELSE
!           IF ( inform%status >= 8 ) CALL mexWarnMsgTxt( ' status >= 8' )
          END IF

          x_pr = mxGetPr( input_x( 1 ) )
          CALL MATLAB_copy_to_ptr( nlp%X, x_pr, n )

!  obtain the objective function

          IF ( inform%status == 2 .OR. inform%status == 23 .OR.                &
               inform%status == 25 .OR. inform%status == 235 ) THEN
!           CALL mexWarnMsgTxt( ' 2' )

!  evaluate f(x) in Matlab

            status = mexCallMATLABWithTrap( 2, output_f, 1, input_x, eval_f )

!  check to see that the evaluation succeeded

            s_in = output_f( 2 )
            s_pr = mxGetPr( s_in )
            CALL MATLAB_copy_from_ptr( s_pr, data%eval_status )

!  recover the function value

            IF ( data%eval_status == 0 ) THEN
              f_in = output_f( 1 )
              f_pr = mxGetPr( f_in )
              CALL MATLAB_copy_from_ptr( f_pr, nlp%f )
            END IF
          END IF

!  obtain the gradient

          IF ( inform%status == 3 .OR. inform%status == 23 .OR.                &
               inform%status == 35 .OR. inform%status == 235 ) THEN
!           CALL mexWarnMsgTxt( ' 3' )

!  evaluate g(x) in Matlab

            status = mexCallMATLABWithTrap( 2, output_g, 1, input_x, eval_g )

!  check to see that the evaluation succeeded

            s_in = output_g( 2 )
            s_pr = mxGetPr( s_in )
            CALL MATLAB_copy_from_ptr( s_pr, data%eval_status )

!  recover the gradient value

            IF ( data%eval_status == 0 ) THEN
              g_in = output_g( 1 )
              g_pr = mxGetPr( g_in )
              CALL MATLAB_copy_from_ptr( g_pr, nlp%G, n )
            END IF
          END IF

!  obtain the Hessian

          IF ( inform%status == 4 ) THEN
!           CALL mexWarnMsgTxt( ' 4' )

!  evaluate H(x) in Matlab

            status = mexCallMATLABWithTrap( 2, output_h, 1, input_x, eval_h )

!  check to see that the evaluation succeeded

            s_in = output_h( 2 )
            s_pr = mxGetPr( s_in )
            CALL MATLAB_copy_from_ptr( s_pr, data%eval_status )

!  recover the Hessian value

            IF ( data%eval_status == 0 ) THEN
              h_in = output_h( 1 )
              h_pr = mxGetPr( h_in )
              CALL MATLAB_copy_from_ptr( h_pr, nlp%H%val, nlp%H%ne )
            END IF
          END IF

!  obtain a Hessian-vector product

          IF ( inform%status == 5 .OR. inform%status == 25 .OR.                &
               inform%status == 35 .OR. inform%status == 235 ) THEN
!           CALL mexWarnMsgTxt( ' 5' )

!  evaluate u = u + H(x) v in Matlab

            u_pr = mxGetPr( input_x( 2 ) )
            CALL MATLAB_copy_to_ptr( data%U, u_pr, n )
            v_pr = mxGetPr( input_x( 3 ) )
            CALL MATLAB_copy_to_ptr( data%V, v_pr, n )

!        CALL mexWarnMsgTxt( ' enter hprod' )
            status = mexCallMATLABWithTrap( 2, output_hprod, 3, input_x,      &
                                            eval_hprod )
!        CALL mexWarnMsgTxt( ' exit hprod' )

!  check to see that the evaluation succeeded

            s_in = output_hprod( 2 )
            s_pr = mxGetPr( s_in )
            CALL MATLAB_copy_from_ptr( s_pr, data%eval_status )

!  recover u

            IF ( data%eval_status == 0 ) THEN
              u_in = output_hprod( 1 )
              u_pr = mxGetPr( u_in )
              CALL MATLAB_copy_from_ptr( u_pr, data%U, n )
            END IF
          END IF
        END DO
 
!  Print details to Matlab window

!       IF ( control%error > 0 ) CLOSE( control%error )
!       IF ( control%out > 0 .AND. control%error /= control%out )              &
!         CLOSE( control%out )

        IF ( control%out > 0 ) THEN
          REWIND( control%out, err = 500 )
          DO
            READ( control%out, "( A )", end = 500 ) str
            i = mexPrintf( TRIM( str ) // ACHAR( 10 ) )
          END DO
        END IF
   500  CONTINUE

!  Output solution and the dual

        i4 = 1
        plhs( x_arg ) = MATLAB_create_real( n, i4 )
        x_pr = mxGetPr( plhs( x_arg ) )
        CALL MATLAB_copy_to_ptr( nlp%X, x_pr, n )

!  Record output information

        CALL BGO_matlab_inform_get( inform, BGO_pointer )

!  Check for errors

        IF ( inform%status < 0 )                                               &
          CALL mexErrMsgTxt( ' Call to BGO_solve failed ' )
      END IF

!  all components now set

      IF ( TRIM( mode ) == 'final' .OR. TRIM( mode ) == 'all' ) THEN
        IF ( ALLOCATED( nlp%H%row ) ) DEALLOCATE( nlp%H%row, STAT = info )
        IF ( ALLOCATED( nlp%H%col ) ) DEALLOCATE( nlp%H%col, STAT = info )
        IF ( ALLOCATED( nlp%H%val ) ) DEALLOCATE( nlp%H%val, STAT = info )
        IF ( ALLOCATED( nlp%G ) ) DEALLOCATE( nlp%G, STAT = info )
        IF ( ALLOCATED( nlp%X ) ) DEALLOCATE( nlp%X, STAT = info )
        IF ( ALLOCATED( nlp%X_l ) ) DEALLOCATE( nlp%X_l, STAT = info )
        IF ( ALLOCATED( nlp%X_u ) ) DEALLOCATE( nlp%X_u, STAT = info )
        IF ( ALLOCATED( IW ) ) DEALLOCATE( IW, STAT = alloc_stat )
        CALL BGO_terminate( data, control, inform )
      END IF

!  close any opened io units

      IF ( control%error > 0 ) THEN
        INQUIRE( control%error, OPENED = opened )
        IF ( opened ) CLOSE( control%error )
      END IF

      IF ( control%out > 0 ) THEN
        INQUIRE( control%out, OPENED = opened )
        IF ( opened ) CLOSE( control%out )
      END IF
      RETURN

      END SUBROUTINE mexFunction
