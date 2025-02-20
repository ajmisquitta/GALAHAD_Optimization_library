! THIS VERSION: GALAHAD 4.1 - 2022-11-19 AT 10:30 GMT.
! This file is a modified version of dsimpletest.F from MUMPS 5.5.1, 
! originally released on Tue Jul 12 13:17:24 UTC 2022

   PROGRAM MUMPS_TEST
   USE GALAHAD_MUMPS_TYPES_double
   IMPLICIT NONE
   INTEGER, PARAMETER :: MPI_COMM_WORLD = 0
   INTEGER, PARAMETER :: wp = KIND( 1.0D+0 )
   INTEGER, PARAMETER :: n = 5
   INTEGER, PARAMETER :: ne = 7
   INTEGER, PARAMETER :: neu = 11
   TYPE ( DMUMPS_STRUC ) mumps_par
   INTEGER ierr, j, nnz

!  start an mpi instance, and define a communicator for the package

   CALL MPI_INIT( ierr )
   IF ( ierr < 0 ) THEN
     WRITE( 6, "( ' No MPi available, stopping' )" )
     STOP
   END IF
   mumps_par%COMM = MPI_COMM_WORLD

   DO j = 0, 1  ! loop over unsymmetric and symmetric examples

!  initialize an instance of the package for L U or L D L^T factorization 
!  (sym = 0, with working host)

      mumps_par%JOB = - 1
      mumps_par%SYM = j
      mumps_par%PAR = 1
      CALL DMUMPS( mumps_par )
      IF ( mumps_par%INFOG( 1 ) == - 999 ) THEN
        WRITE( 6, "( ' Mumps not provided, stopping' )" )
        EXIT
      ELSE IF ( mumps_par%INFOG( 1 ) < 0 ) THEN
        WRITE( 6, 10 ) 'Initialize', mumps_par%INFOG( 1 : 2 )
        EXIT
      END IF

!  define problem on the host (processor 0)

      IF ( mumps_par%MYID == 0 ) THEN
        mumps_par%N = n
        IF ( j == 0 ) THEN
          nnz = neu
        ELSE
          nnz = ne
        END IF
        mumps_par%NNZ = nnz
        ALLOCATE( mumps_par%IRN( nnz ), mumps_par%JCN( nnz ),                  &
                  mumps_par%A( nnz ), mumps_par%RHS( n ) )
        IF ( j == 0 ) THEN ! unsymmetric matrix
          mumps_par%IRN ( : nnz ) = (/ 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 5 /)
          mumps_par%JCN ( : nnz ) = (/ 1, 2, 1, 3, 5, 2, 3, 4, 3, 2, 5 /)
          mumps_par%A( : nnz ) = (/ 2.0_wp, 3.0_wp, 3.0_wp, 4.0_wp, 6.0_wp,    &
                            4.0_wp, 1.0_wp, 5.0_wp, 5.0_wp, 6.0_wp, 1.0_wp /)
        ELSE ! symmetric matrix
          mumps_par%IRN ( : nnz ) = (/ 1, 2, 3, 3, 4, 5, 5 /)
          mumps_par%JCN ( : nnz ) = (/ 1, 1, 2, 3, 3, 2, 5 /)
          mumps_par%A( : nnz ) = (/ 2.0_wp, 3.0_wp, 4.0_wp, 1.0_wp,            &
                                    5.0_wp, 6.0_wp, 1.0_wp /)
        END IF
        mumps_par%RHS( : n ) = (/ 8.0_wp, 45.0_wp, 31.0_wp, 15.0_wp, 17.0_wp /)
      END IF

!  call package for analysis

      mumps_par%JOB = 1
      CALL DMUMPS( mumps_par )
      IF ( mumps_par%INFOG( 1 ) < 0 ) THEN
        WRITE( 6, 10 ) 'Analyse', mumps_par%INFOG( 1 : 2 )
        EXIT
      END IF

!  call package for factorization

      mumps_par%JOB = 2
      CALL DMUMPS( mumps_par )
      IF ( mumps_par%INFOG( 1 ) < 0 ) THEN
        WRITE( 6, 10 ) 'Factorize', mumps_par%INFOG( 1 : 2 )
        EXIT
      END IF

!  call package for solution

      mumps_par%JOB = 3
      CALL DMUMPS( mumps_par )
      IF ( mumps_par%INFOG( 1 ) < 0 ) THEN
        WRITE( 6, 10 ) 'Solve', mumps_par%INFOG( 1 : 2 )
        EXIT
      END IF

!  solution has been assembled on the host

      IF ( mumps_par%MYID == 0 )                                               &
        WRITE( 6, "( ' Solution is ', 5ES12.4 )" ) mumps_par%RHS( 1 : n )

!  deallocate user data

      IF ( mumps_par%MYID == 0 )                                               &
        DEALLOCATE( mumps_par%IRN, mumps_par%JCN, mumps_par%A, mumps_par%RHS )

!  destroy the instance (deallocate internal data structures)

      mumps_par%JOB = - 2
      CALL DMUMPS( mumps_par )
      IF ( mumps_par%INFOG( 1 ) < 0 ) THEN
        WRITE( 6, 10 ) 'Terminate', mumps_par%INFOG( 1 : 2 )
        EXIT
      END IF
   END DO

!  terminate the mpi instance

   CALL MPI_FINALIZE( ierr )
   STOP
10 FORMAT( 1X, A, ' error return: mumps_par%infog(1,2) = ', I0, ', ', I0 )
   END PROGRAM MUMPS_TEST
