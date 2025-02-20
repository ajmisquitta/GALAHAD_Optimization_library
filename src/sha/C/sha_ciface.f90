! THIS VERSION: GALAHAD 4.0 - 2022-01-28 AT 17:01 GMT.

!-*-*-*-*-*-*-*-  G A L A H A D _  S H A    C   I N T E R F A C E  -*-*-*-*-*-

!  Copyright reserved, Gould/Orban/Toint, for GALAHAD productions
!  Principal authors: Jaroslav Fowkes & Nick Gould

!  History -
!    originally released GALAHAD Version 4.0. January 28th 2022

!  For full documentation, see
!   http://galahad.rl.ac.uk/galahad-www/specs.html

  MODULE GALAHAD_SHA_double_ciface
    USE iso_c_binding
    USE GALAHAD_common_ciface
    USE GALAHAD_SHA_double, ONLY:                                              &
        f_sha_control_type   => SHA_control_type,                              &
        f_sha_inform_type    => SHA_inform_type,                               &
        f_sha_full_data_type => SHA_full_data_type,                            &
        f_sha_initialize     => SHA_initialize,                                &
        f_sha_read_specfile  => SHA_read_specfile,                             &
!       f_sha_import         => SHA_import,                                    &
!       f_sha_reset_control  => SHA_reset_control,                             &
!       f_sha_information    => SHA_information,                               &
        f_sha_terminate      => SHA_terminate

    IMPLICIT NONE

!--------------------
!   P r e c i s i o n
!--------------------

    INTEGER, PARAMETER :: wp = C_DOUBLE ! double precision
    INTEGER, PARAMETER :: sp = C_FLOAT  ! single precision

!-------------------------------------------------
!  D e r i v e d   t y p e   d e f i n i t i o n s
!-------------------------------------------------

    TYPE, BIND( C ) :: sha_control_type
      LOGICAL ( KIND = C_BOOL ) :: f_indexing
      INTEGER ( KIND = C_INT ) :: error
      INTEGER ( KIND = C_INT ) :: out
      INTEGER ( KIND = C_INT ) :: print_level
      INTEGER ( KIND = C_INT ) :: approximation_algorithm
      INTEGER ( KIND = C_INT ) :: dense_linear_solver
      INTEGER ( KIND = C_INT ) :: max_sparse_degree
      LOGICAL ( KIND = C_BOOL ) :: space_critical
      LOGICAL ( KIND = C_BOOL ) :: deallocate_error_fatal
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 31 ) :: prefix
    END TYPE sha_control_type

    TYPE, BIND( C ) :: sha_inform_type
      INTEGER ( KIND = C_INT ) :: status
      INTEGER ( KIND = C_INT ) :: alloc_status
      INTEGER ( KIND = C_INT ) :: max_degree
      INTEGER ( KIND = C_INT ) :: differences_needed
      INTEGER ( KIND = C_INT ) :: max_reduced_degree
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 81 ) :: bad_alloc
    END TYPE sha_inform_type

!----------------------
!   P r o c e d u r e s
!----------------------

  CONTAINS

!  copy C control parameters to fortran

    SUBROUTINE copy_control_in( ccontrol, fcontrol, f_indexing ) 
    TYPE ( sha_control_type ), INTENT( IN ) :: ccontrol
    TYPE ( f_sha_control_type ), INTENT( OUT ) :: fcontrol
    LOGICAL, optional, INTENT( OUT ) :: f_indexing
    INTEGER :: i
    
    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) f_indexing = ccontrol%f_indexing

    ! Integers
    fcontrol%error = ccontrol%error
    fcontrol%out = ccontrol%out
    fcontrol%print_level = ccontrol%print_level
    fcontrol%approximation_algorithm = ccontrol%approximation_algorithm
    fcontrol%dense_linear_solver = ccontrol%dense_linear_solver
    fcontrol%max_sparse_degree = ccontrol%max_sparse_degree

    ! Logicals
    fcontrol%space_critical = ccontrol%space_critical
    fcontrol%deallocate_error_fatal = ccontrol%deallocate_error_fatal

    ! Strings
    DO i = 1, LEN( fcontrol%prefix )
      IF ( ccontrol%prefix( i ) == C_NULL_CHAR ) EXIT
      fcontrol%prefix( i : i ) = ccontrol%prefix( i )
    END DO
    RETURN

    END SUBROUTINE copy_control_in

!  copy fortran control parameters to C

    SUBROUTINE copy_control_out( fcontrol, ccontrol, f_indexing ) 
    TYPE ( f_sha_control_type ), INTENT( IN ) :: fcontrol
    TYPE ( sha_control_type ), INTENT( OUT ) :: ccontrol
    LOGICAL, OPTIONAL, INTENT( IN ) :: f_indexing
    INTEGER :: i, l
    
    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) ccontrol%f_indexing = f_indexing

    ! Integers
    ccontrol%error = fcontrol%error
    ccontrol%out = fcontrol%out
    ccontrol%print_level = fcontrol%print_level
    ccontrol%approximation_algorithm = fcontrol%approximation_algorithm
    ccontrol%dense_linear_solver = fcontrol%dense_linear_solver
    ccontrol%max_sparse_degree = fcontrol%max_sparse_degree

    ! Logicals
    ccontrol%space_critical = fcontrol%space_critical
    ccontrol%deallocate_error_fatal = fcontrol%deallocate_error_fatal

    ! Strings
    l = LEN( fcontrol%prefix )
    DO i = 1, l
      ccontrol%prefix( i ) = fcontrol%prefix( i : i )
    END DO
    ccontrol%prefix( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_control_out

!  copy C inform parameters to fortran

    SUBROUTINE copy_inform_in( cinform, finform ) 
    TYPE ( sha_inform_type ), INTENT( IN ) :: cinform
    TYPE ( f_sha_inform_type ), INTENT( OUT ) :: finform
    INTEGER :: i

    ! Integers
    finform%status = cinform%status
    finform%alloc_status = cinform%alloc_status
    finform%max_degree = cinform%max_degree
    finform%differences_needed = cinform%differences_needed
    finform%max_reduced_degree = cinform%max_reduced_degree

    ! Strings
    DO i = 1, LEN( finform%bad_alloc )
      IF ( cinform%bad_alloc( i ) == C_NULL_CHAR ) EXIT
      finform%bad_alloc( i : i ) = cinform%bad_alloc( i )
    END DO
    RETURN

    END SUBROUTINE copy_inform_in

!  copy fortran inform parameters to C

    SUBROUTINE copy_inform_out( finform, cinform ) 
    TYPE ( f_sha_inform_type ), INTENT( IN ) :: finform
    TYPE ( sha_inform_type ), INTENT( OUT ) :: cinform
    INTEGER :: i, l

    ! Integers
    cinform%status = finform%status
    cinform%alloc_status = finform%alloc_status
    cinform%max_degree = finform%max_degree
    cinform%differences_needed = finform%differences_needed
    cinform%max_reduced_degree = finform%max_reduced_degree

    ! Strings
    l = LEN( finform%bad_alloc )
    DO i = 1, l
      cinform%bad_alloc( i ) = finform%bad_alloc( i : i )
    END DO
    cinform%bad_alloc( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_inform_out

  END MODULE GALAHAD_SHA_double_ciface

!  -------------------------------------
!  C interface to fortran sha_initialize
!  -------------------------------------

  SUBROUTINE sha_initialize( cdata, ccontrol, status ) BIND( C ) 
  USE GALAHAD_SHA_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( C_PTR ), INTENT( OUT ) :: cdata ! data is a black-box
  TYPE ( sha_control_type ), INTENT( OUT ) :: ccontrol

!  local variables

  TYPE ( f_sha_full_data_type ), POINTER :: fdata
  TYPE ( f_sha_control_type ) :: fcontrol
  TYPE ( f_sha_inform_type ) :: finform
  LOGICAL :: f_indexing 

!  allocate fdata

  ALLOCATE( fdata ); cdata = C_LOC( fdata )

!  initialize required fortran types

  CALL f_sha_initialize( fdata, fcontrol, finform )
  status = finform%status

!  C sparse matrix indexing by default

  f_indexing = .FALSE.
  fdata%f_indexing = f_indexing

!  copy control out 

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE sha_initialize

!  ----------------------------------------
!  C interface to fortran sha_read_specfile
!  ----------------------------------------

  SUBROUTINE sha_read_specfile( ccontrol, cspecfile ) BIND( C )
  USE GALAHAD_SHA_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( sha_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( IN ), VALUE :: cspecfile

!  local variables

  TYPE ( f_sha_control_type ) :: fcontrol
  CHARACTER ( KIND = C_CHAR, LEN = strlen( cspecfile ) ) :: fspecfile
  LOGICAL :: f_indexing

!  device unit number for specfile

  INTEGER ( KIND = C_INT ), PARAMETER :: device = 10

!  convert C string to Fortran string

  fspecfile = cstr_to_fchar( cspecfile )

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )
  
!  open specfile for reading

  OPEN( UNIT = device, FILE = fspecfile )
  
!  read control parameters from the specfile

  CALL f_sha_read_specfile( fcontrol, device )

!  close specfile

  CLOSE( device )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE sha_read_specfile

!  ------------------------------------
!  C interface to fortran sha_terminate
!  ------------------------------------

  SUBROUTINE sha_terminate( cdata, ccontrol, cinform ) BIND( C ) 
  USE GALAHAD_SHA_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( sha_control_type ), INTENT( IN ) :: ccontrol
  TYPE ( sha_inform_type ), INTENT( INOUT ) :: cinform

!  local variables

  TYPE ( f_sha_full_data_type ), pointer :: fdata
  TYPE ( f_sha_control_type ) :: fcontrol
  TYPE ( f_sha_inform_type ) :: finform
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  copy inform in

  CALL copy_inform_in( cinform, finform )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  deallocate workspace

  CALL f_sha_terminate( fdata, fcontrol, finform )

!  copy inform out

  CALL copy_inform_out( finform, cinform )

!  deallocate data

  DEALLOCATE( fdata ); cdata = C_NULL_PTR 
  RETURN

  END SUBROUTINE sha_terminate
