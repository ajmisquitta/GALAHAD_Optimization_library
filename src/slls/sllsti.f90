! THIS VERSION: GALAHAD 4.1 - 2022-05-26 AT 07:15 GMT
   PROGRAM GALAHAD_SLLS_interface_test
   USE GALAHAD_SLLS_double                      ! double precision version
   USE GALAHAD_SYMBOLS
   IMPLICIT NONE
   INTEGER, PARAMETER :: wp = KIND( 1.0D+0 )    ! set precision
   REAL ( KIND = wp ), PARAMETER :: infinity = 10.0_wp ** 20
   TYPE ( SLLS_control_type ) :: control
   TYPE ( SLLS_inform_type ) :: inform
   TYPE ( SLLS_full_data_type ) :: data
   INTEGER :: n, m, A_ne, A_dense_ne, eval_status
   INTEGER :: i, j, l, nm, mask, data_storage_type, status
   INTEGER, DIMENSION( 0 ) :: null
   REAL ( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: X, Z, B, C, G
   INTEGER, ALLOCATABLE, DIMENSION( : ) :: A_row, A_col, A_ptr
   REAL ( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: A_val, A_dense
   INTEGER, ALLOCATABLE, DIMENSION( : ) :: A_by_col_row, A_by_col_ptr
   REAL ( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: A_by_col_val
   REAL ( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: A_by_col_dense
   INTEGER, ALLOCATABLE, DIMENSION( : ) :: X_stat
   INTEGER :: nz_in_start, nz_in_end, nz_out_end
   INTEGER, ALLOCATABLE, DIMENSION( : ) :: nz_in, nz_out
   REAL ( KIND = wp ), ALLOCATABLE, DIMENSION( : ) :: V, P
   CHARACTER ( len = 3 ) :: st
   TYPE ( GALAHAD_userdata_type ) :: userdata

! set up problem data for min || A x - b || with
!   A = (  I  )  and b = (   e   )
!       ( e^T )          ( n + 1 )

   n = 10 ; m = n + 1 ; A_ne = 2 * n ; A_dense_ne = m * n
   ALLOCATE( X( n ), Z( n ), G( n ), B( m ), C( m ), X_stat( n ) )
   B( : m ) = 1.0_wp ! observations
   DO i = 1, n
     B( i ) = REAL( i, KIND = wp )
   END DO
   B( m ) = REAL( n + 1, KIND = wp )

!  set up A stored by rows

   ALLOCATE( A_val( A_ne ), A_row( A_ne ), A_col( A_ne ), A_ptr( m + 1 ) )
   l = 0
   DO i = 1, n
     l = l + 1 ; A_ptr( i ) = l
     A_row( l ) = i ; A_col( l ) = i ; A_val( l ) = 1.0_wp
   END DO
   A_ptr( m ) = l + 1
   DO i = 1, n
     l = l + 1
     A_row( l ) = m ; A_col( l ) = i ; A_val( l ) = 1.0_wp
   END DO
   A_ptr( m + 1 ) = l + 1
   l = 0
   ALLOCATE( A_dense( A_dense_ne ) )
   DO i = 1, n
     DO j = 1, n
       l = l + 1
       IF ( i == j ) THEN
         A_dense( l ) = 1.0_wp
       ELSE
         A_dense( l ) = 0.0_wp
       END IF
     END DO
   END DO
   A_dense( l + 1 : l + n ) = 1.0_wp

!  set up A stored by columns

   ALLOCATE( A_by_col_val( A_ne ), A_by_col_row( A_ne ), A_by_col_ptr( n + 1 ) )
   l = 0
   DO i = 1, n
     l = l + 1 ; A_by_col_ptr( i ) = l
     A_by_col_row( l ) = i ; A_by_col_val( l ) = 1.0_wp
     l = l + 1
     A_by_col_row( l ) = m ; A_by_col_val( l ) = 1.0_wp
   END DO
   A_by_col_ptr( n + 1 ) = l + 1
   l = 0
   ALLOCATE( A_by_col_dense( A_dense_ne ) )
   DO i = 1, n
     DO j = 1, n
       l = l + 1
       IF ( i == j ) THEN
         A_by_col_dense( l ) = 1.0_wp
       ELSE
         A_by_col_dense( l ) = 0.0_wp
       END IF
     END DO
     l = l + 1
     A_by_col_dense( l ) = 1.0_wp
   END DO

! problem data complete

!  =====================================
!  basic test of various storage formats
!  =====================================

   WRITE( 6, "( /, ' basic tests of Jacobian storage formats', / )" )

   DO data_storage_type = 1, 5
     CALL SLLS_initialize( data, control, inform )
     X = 0.0_wp ; Z = 0.0_wp ! start from zero
     SELECT CASE ( data_storage_type )
     CASE ( 1 ) ! sparse co-ordinate storage
       st = ' CO'
       CALL SLLS_import( control, data, status, n, m, 'coordinate',            &
                         A_ne, A_row, A_col, null )
       CALL SLLS_solve_given_a( data, userdata, status, A_val, B,              &
                                X, Z, C, G, X_stat )
!      WRITE( 6, "( ' x = ', 5ES12.4, /, 5X, 5ES12.4 )" ) X
     CASE ( 2 ) ! sparse by rows
        st = ' SR'
        CALL SLLS_import( control, data, status, n, m, 'sparse_by_rows',       &
                          A_ne, null, A_col, A_ptr )
       CALL SLLS_solve_given_a( data, userdata, status, A_val, B,              &
                                X, Z, C, G, X_stat )
     CASE ( 3 ) ! dense_by_rows
       st = ' DR'
       CALL SLLS_import( control, data, status, n, m, 'dense_by_rows',         &
                                  A_ne, null, null, null )
       CALL SLLS_solve_given_a( data, userdata, status, A_dense, B,            &
                                X, Z, C, G, X_stat )
     CASE ( 4 ) ! sparse by cols
       st = ' SC'
       CALL SLLS_import( control, data, status, n, m, 'sparse_by_columns',     &
                                  A_ne, A_by_col_row, null, A_by_col_ptr )
       CALL SLLS_solve_given_a( data, userdata, status, A_by_col_val, B,       &
                                X, Z, C, G, X_stat )
     CASE ( 5 ) ! dense_by_cols
       st = ' DC'
       CALL SLLS_import( control, data, status, n, m, 'dense_by_columns',      &
                         A_ne, null, null, null )
       CALL SLLS_solve_given_a( data, userdata, status, A_by_col_dense, B,     &
                                X, Z, C, G, X_stat )
     END SELECT
     CALL SLLS_information( data, inform, status )
     IF ( inform%status == 0 ) THEN
       WRITE( 6, "( A3, ':', I6, ' iterations. Optimal objective value = ',    &
     &    F6.2, ' status = ', I0 )" ) st, inform%iter, inform%obj, inform%status
     ELSE
       WRITE( 6, "( A3, ': SLLS_solve exit status = ', I0 ) " ) st,inform%status
     END IF
     CALL SLLS_terminate( data, control, inform )  ! delete internal workspace
   END DO
   DEALLOCATE( A_val, A_row, A_col, A_ptr, A_dense )
   DEALLOCATE( A_by_col_val, A_by_col_row, A_by_col_ptr, A_by_col_dense )

   WRITE( 6, "( /, ' test of reverse-communication interface', / )" )

   nm = MAX( n, m )
   ALLOCATE( nz_in( nm ), nz_out( m ), V( nm ), P( nm ) )
   CALL SLLS_initialize( data, control, inform )
   X = 0.0_wp ; Z = 0.0_wp ! start from zero
   st = ' RC'
!  control%print_level = 1
!  control%maxit = 5
   CALL SLLS_import_without_a( control, data, status, n, m )
   status = 1
   DO
     CALL SLLS_solve_reverse_a_prod( data, status, eval_status, B,             &
                                     X, Z, C, G, X_stat, V, P,                 &
                                     nz_in, nz_in_start, nz_in_end,            &
                                     nz_out, nz_out_end )
!    write(6, "( ' status = ', I0 )" ) status
     SELECT CASE( status )
     CASE ( : 0 )
       EXIT
     CASE ( 2 ) ! Av
       P( : n ) = V( : n )
       P( m ) = SUM( V( : n ) )
       eval_status = 0
     CASE ( 3 ) ! A^T v
       P( : n ) = V( : n ) + V( m )
       eval_status = 0
     CASE ( 4 ) ! A v using sparse v
       P( : m ) = 0.0_wp
       DO l = nz_in_start, nz_in_end
         i = nz_in( l )
         P( i ) = V( i )
         P( m ) = P( m ) + V( i )
       END DO
       eval_status = 0
     CASE ( 5 ) ! sparse A v using sparse v
       nz_out_end = 0
       mask = 0
       DO l = nz_in_start, nz_in_end
         i = nz_in( l )
         nz_out_end = nz_out_end + 1
         nz_out( nz_out_end ) = i
         P( i ) = V( i )
         IF ( mask == 0 ) THEN
           mask = 1
           nz_out_end = nz_out_end + 1
           nz_out( nz_out_end ) = m
           P( m ) = V( i )
         ELSE
           P( m ) = P( m ) + V( i )
         END IF
       END DO
       eval_status = 0
     CASE ( 6 ) ! sparse A^T v
       DO l = nz_in_start, nz_in_end
         i = nz_in( l )
         P( i ) = V( i ) + V( m )
       END DO
       eval_status = 0
     END SELECT
   END DO
   CALL SLLS_information( data, inform, status )
   IF ( inform%status == 0 ) THEN
     WRITE( 6, "( A3, ':', I6, ' iterations. Optimal objective value = ',    &
   &    F6.2, ' status = ', I0 )" ) st, inform%iter, inform%obj, inform%status
   ELSE
     WRITE( 6, "( A3, ': SLLS_solve exit status = ', I0 ) " ) st, inform%status
   END IF
   CALL SLLS_terminate( data, control, inform )  ! delete internal workspace
   DEALLOCATE( B, X, Z, C, G, X_stat, NZ_in, NZ_out, V, P )
   END PROGRAM GALAHAD_SLLS_interface_test
