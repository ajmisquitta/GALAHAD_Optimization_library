! THIS VERSION: GALAHAD 3.3 - 08/10/2021 AT 09:45 GMT.
   PROGRAM GALAHAD_LQR_test_deck
   USE GALAHAD_LQR_DOUBLE                            ! double precision version
   IMPLICIT NONE
   INTEGER, PARAMETER :: wp = KIND( 1.0D+0 ) ! set precision
   INTEGER, PARAMETER :: n = 100                  ! problem dimension
   INTEGER :: i, nn, pass
   REAL ( KIND = wp ) :: f, radius
   REAL ( KIND = wp ), DIMENSION( n ) :: X, C
   TYPE ( LQR_data_type ) :: data
   TYPE ( LQR_control_type ) :: control        
   TYPE ( LQR_inform_type ) :: inform

!  ==============
!  Normal entries
!  ==============

   WRITE( 6, "( /, ' ===== normal exits ===== ' )" )

   WRITE( 6, "( /, ' =-=-= convex cases =-=-= ', / )" )

   radius = 10000.0_wp
   C = 1.0_wp
   DO pass = 1, 4
     CALL LQR_initialize( data, control, inform ) ! Initialize control params
     control%error = 23 ; control%out = 23 ; control%print_level = 10
     SELECT CASE ( pass )
     CASE ( 2, 4 ) 
       control%unitm = .FALSE.
     CASE ( 3 ) 
       radius = 10.0_wp
     END SELECT
     DO                                     !  Iteration to find the minimizer
       CALL LQR_solve( n, radius, f, X, C, data, control, inform )
       SELECT CASE( inform%status )  ! Branch as a result of inform%status
       CASE( 2 )                  ! Form the preconditioned gradient
         data%U( : n ) = data%R( : n ) ! Preconditioner is identity
       CASE ( 3 )                 ! Form the matrix-vector product
         data%Y( 1 ) = 2.0_wp * data%Q( 1 ) - data%Q( 2 )
         DO i = 2, n - 1
           data%Y( i ) = -data%Q( i - 1 ) +2.0_wp * data%Q( i ) -data%Q( i + 1 )
         END DO
         data%Y( n ) = - data%Q( n - 1 ) + 2.0_wp * data%Q( n )
       CASE ( 0, - 17 )  !  Successful return
         WRITE( 6, "( I6, ' iterations. Solution and Lagrange multiplier = ',  &
        &    2ES12.4 )" ) inform%iter, f, inform%multiplier
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       CASE DEFAULT      !  Error returns
         WRITE( 6, "( ' LQR_solve exit status = ', I6 ) " ) inform%status
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       END SELECT
     END DO
   END DO

   WRITE( 6, "( /, ' =-= non-convex cases =-= ', / )" )

   radius = 10.0_wp
   DO pass = 1, 2
     CALL LQR_initialize( data, control, inform ) ! Initialize control params
     control%error = 23 ; control%out = 23 ; control%print_level = 10
     SELECT CASE ( pass )
     CASE ( 2 ) 
       control%unitm = .FALSE.
     END SELECT
     DO                                     !  Iteration to find the minimizer
       CALL LQR_solve( n, radius, f, X, C, data, control, inform )
       SELECT CASE( inform%status )  ! Branch as a result of inform%status
       CASE( 2 )                  ! Form the preconditioned gradient
         data%U( : n ) = data%R( : n ) ! Preconditioner is identity
       CASE ( 3 )                 ! Form the matrix-vector product
         data%Y( 1 ) = - 2.0_wp * data%Q( 1 ) + data%Q( 2 )
         DO i = 2, n - 1
           data%Y( i ) = data%Q( i - 1 ) - 2.0_wp * data%Q( i ) +data%Q( i + 1 )
         END DO
         data%Y( n ) = data%Q( n - 1 ) - 2.0_wp * data%Q( n )
       CASE ( 0, - 17 )  !  Successful return
         WRITE( 6, "( I6, ' iterations. Solution and Lagrange multiplier = ',  &
        &    2ES12.4 )" ) inform%iter, f, inform%multiplier
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       CASE DEFAULT      !  Error returns
         WRITE( 6, "( ' LQR_solve exit status = ', I6 ) " ) inform%status
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       END SELECT
     END DO
   END DO

!  =============
!  Error entries
!  =============

   WRITE( 6, "( /, ' ==== error exits ====== ', / )" )

! Initialize control parameters

   DO pass = 1, 5
     radius = 10.0_wp
     CALL LQR_initialize( data, control, inform )
     control%error = 23 ; control%out = 23 ; control%print_level = 10
     nn = n
     IF ( pass == 1 ) nn = 0
     IF ( pass == 2 ) radius = - 1.0_wp
     IF ( pass == 3 ) control%unitm = .FALSE.
     IF ( pass == 4 ) control%itmax = 0
     IF ( pass == 5 ) control%itmax_beyond_boundary = 2
     DO                                     !  Iteration to find the minimizer
       CALL LQR_solve( nn, radius, f, X, C, data, control, inform )
       SELECT CASE( inform%status )  ! Branch as a result of inform%status
       CASE( 2 )                  ! Form the preconditioned gradient
         data%U( : n ) = - data%R( : n ) ! Preconditioner is - identity
       CASE ( 3 )                 ! Form the matrix-vector product
         data%Y( 1 ) = - 2.0_wp * data%Q( 1 ) + data%Q( 2 )
         DO i = 2, n - 1
           data%Y( i ) = data%Q( i - 1 ) - 2.0_wp * data%Q( i ) +data%Q( i + 1 )
         END DO
         data%Y( n ) = data%Q( n - 1 ) - 2.0_wp * data%Q( n )
       CASE ( 0, - 17 )  !  Successful return
         WRITE( 6, "( I6, ' iterations. Solution and Lagrange multiplier = ',  &
        &    2ES12.4 )" ) inform%iter, f, inform%multiplier
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       CASE DEFAULT      !  Error returns
         WRITE( 6, "( ' LQR_solve exit status = ', I6 ) " ) inform%status
         CALL LQR_terminate( data, control, inform ) ! delete internal workspace
         EXIT
       END SELECT
     END DO
   END DO
   CLOSE( unit = 23 )

!  STOP
   END PROGRAM GALAHAD_LQR_test_deck
