! THIS VERSION: GALAHAD 4.1 - 2022-09-2 AT 16:20 GMT.

!-*-*-*-*-*-*-*-  G A L A H A D _  B L L S    C   I N T E R F A C E  -*-*-*-*-*-

!  Copyright reserved, Gould/Orban/Toint, for GALAHAD productions
!  Principal authors: Jaroslav Fowkes & Nick Gould

!  History -
!    originally released GALAHAD Version 4.0. February 21st 2022

!  For full documentation, see
!   http://galahad.rl.ac.uk/galahad-www/specs.html

  MODULE GALAHAD_BLLS_double_ciface
    USE iso_c_binding
    USE GALAHAD_common_ciface
    USE GALAHAD_BLLS_double, ONLY:                                             &
        f_blls_control_type         => BLLS_control_type,                      &
        f_blls_time_type            => BLLS_time_type,                         &
        f_blls_inform_type          => BLLS_inform_type,                       &
        f_blls_full_data_type       => BLLS_full_data_type,                    &
        f_blls_initialize           => BLLS_initialize,                        &
        f_blls_read_specfile        => BLLS_read_specfile,                     &
        f_blls_import               => BLLS_import,                            &
        f_blls_import_without_a     => BLLS_import_without_a,                  &
        f_blls_reset_control        => BLLS_reset_control,                     &
        f_blls_solve_given_a        => BLLS_solve_given_a,                     &
        f_blls_solve_reverse_a_prod => BLLS_solve_reverse_a_prod,              &
        f_blls_information          => BLLS_information,                       &
        f_blls_terminate            => BLLS_terminate

    USE GALAHAD_USERDATA_double, ONLY:                                         &
        f_galahad_userdata_type => GALAHAD_userdata_type

    USE GALAHAD_SBLS_double_ciface, ONLY:                                      &
        sbls_inform_type,                                                      &
        sbls_control_type,                                                     &
        copy_sbls_inform_in   => copy_inform_in,                               &
        copy_sbls_inform_out  => copy_inform_out,                              &
        copy_sbls_control_in  => copy_control_in,                              &
        copy_sbls_control_out => copy_control_out

    USE GALAHAD_CONVERT_double_ciface, ONLY:                                   &
        convert_inform_type,                                                   &
        convert_control_type,                                                  &
        copy_convert_inform_in   => copy_inform_in,                            &
        copy_convert_inform_out  => copy_inform_out,                           &
        copy_convert_control_in  => copy_control_in,                           &
        copy_convert_control_out => copy_control_out

    IMPLICIT NONE

!--------------------
!   P r e c i s i o n
!--------------------

    INTEGER, PARAMETER :: wp = C_DOUBLE ! double precision
    INTEGER, PARAMETER :: sp = C_FLOAT  ! single precision

!-------------------------------------------------
!  D e r i v e d   t y p e   d e f i n i t i o n s
!-------------------------------------------------

    TYPE, BIND( C ) :: blls_control_type
      LOGICAL ( KIND = C_BOOL ) :: f_indexing
      INTEGER ( KIND = C_INT ) :: error
      INTEGER ( KIND = C_INT ) :: out
      INTEGER ( KIND = C_INT ) :: print_level
      INTEGER ( KIND = C_INT ) :: start_print
      INTEGER ( KIND = C_INT ) :: stop_print
      INTEGER ( KIND = C_INT ) :: print_gap
      INTEGER ( KIND = C_INT ) :: maxit
      INTEGER ( KIND = C_INT ) :: cold_start
      INTEGER ( KIND = C_INT ) :: preconditioner
      INTEGER ( KIND = C_INT ) :: ratio_cg_vs_sd
      INTEGER ( KIND = C_INT ) :: change_max
      INTEGER ( KIND = C_INT ) :: cg_maxit
      INTEGER ( KIND = C_INT ) :: arcsearch_max_steps
      INTEGER ( KIND = C_INT ) :: sif_file_device
      REAL ( KIND = wp ) :: weight
      REAL ( KIND = wp ) :: infinity
      REAL ( KIND = wp ) :: stop_d
      REAL ( KIND = wp ) :: identical_bounds_tol
      REAL ( KIND = wp ) :: stop_cg_relative
      REAL ( KIND = wp ) :: stop_cg_absolute
      REAL ( KIND = wp ) :: alpha_max
      REAL ( KIND = wp ) :: alpha_initial
      REAL ( KIND = wp ) :: alpha_reduction
      REAL ( KIND = wp ) :: arcsearch_acceptance_tol
      REAL ( KIND = wp ) :: stabilisation_weight
      REAL ( KIND = wp ) :: cpu_time_limit
      LOGICAL ( KIND = C_BOOL ) :: direct_subproblem_solve
      LOGICAL ( KIND = C_BOOL ) :: exact_arc_search
      LOGICAL ( KIND = C_BOOL ) :: advance
      LOGICAL ( KIND = C_BOOL ) :: space_critical
      LOGICAL ( KIND = C_BOOL ) :: deallocate_error_fatal
      LOGICAL ( KIND = C_BOOL ) :: generate_sif_file
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 31 ) :: sif_file_name
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 31 ) :: prefix
      TYPE ( sbls_control_type ) :: sbls_control
      TYPE ( convert_control_type ) :: convert_control
    END TYPE blls_control_type

    TYPE, BIND( C ) :: blls_time_type
      REAL ( KIND = sp ) :: total
      REAL ( KIND = sp ) :: analyse
      REAL ( KIND = sp ) :: factorize
      REAL ( KIND = sp ) :: solve
    END TYPE blls_time_type

    TYPE, BIND( C ) :: blls_inform_type
      INTEGER ( KIND = C_INT ) :: status
      INTEGER ( KIND = C_INT ) :: alloc_status
      INTEGER ( KIND = C_INT ) :: factorization_status
      INTEGER ( KIND = C_INT ) :: iter
      INTEGER ( KIND = C_INT ) :: cg_iter
      REAL ( KIND = wp ) :: obj
      REAL ( KIND = wp ) :: norm_pg
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 81 ) :: bad_alloc
      TYPE ( blls_time_type ) :: time
      TYPE ( sbls_inform_type ) :: sbls_inform
      TYPE ( convert_inform_type ) :: convert_inform
    END TYPE blls_inform_type

!----------------------
!   I n t e r f a c e s
!----------------------

    ABSTRACT INTERFACE
      FUNCTION eval_prec( n, v, p, userdata ) RESULT( status ) BIND( C )
        USE iso_c_binding
        IMPORT :: wp
        INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n
        REAL ( KIND = wp ), DIMENSION( n ), INTENT( IN ) :: v
        REAL ( KIND = wp ), DIMENSION( n ), INTENT( OUT ) :: p
        TYPE ( C_PTR ), INTENT( IN ), VALUE :: userdata
        INTEGER ( KIND = C_INT ) :: status
      END FUNCTION eval_prec
    END INTERFACE

!----------------------
!   P r o c e d u r e s
!----------------------

  CONTAINS

!  copy C control parameters to fortran

    SUBROUTINE copy_control_in( ccontrol, fcontrol, f_indexing ) 
    TYPE ( blls_control_type ), INTENT( IN ) :: ccontrol
    TYPE ( f_blls_control_type ), INTENT( OUT ) :: fcontrol
    LOGICAL, optional, INTENT( OUT ) :: f_indexing
    INTEGER :: i
    
    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) f_indexing = ccontrol%f_indexing

    ! Integers
    fcontrol%error = ccontrol%error
    fcontrol%out = ccontrol%out
    fcontrol%print_level = ccontrol%print_level
    fcontrol%start_print = ccontrol%start_print
    fcontrol%stop_print = ccontrol%stop_print
    fcontrol%print_gap = ccontrol%print_gap
    fcontrol%maxit = ccontrol%maxit
    fcontrol%cold_start = ccontrol%cold_start
    fcontrol%preconditioner = ccontrol%preconditioner
    fcontrol%ratio_cg_vs_sd = ccontrol%ratio_cg_vs_sd
    fcontrol%change_max = ccontrol%change_max
    fcontrol%cg_maxit = ccontrol%cg_maxit
    fcontrol%arcsearch_max_steps = ccontrol%arcsearch_max_steps
    fcontrol%sif_file_device = ccontrol%sif_file_device

    ! Reals
    fcontrol%weight = ccontrol%weight
    fcontrol%infinity = ccontrol%infinity
    fcontrol%stop_d = ccontrol%stop_d
    fcontrol%identical_bounds_tol = ccontrol%identical_bounds_tol
    fcontrol%stop_cg_relative = ccontrol%stop_cg_relative
    fcontrol%stop_cg_absolute = ccontrol%stop_cg_absolute
    fcontrol%alpha_max = ccontrol%alpha_max
    fcontrol%alpha_initial = ccontrol%alpha_initial
    fcontrol%alpha_reduction = ccontrol%alpha_reduction
    fcontrol%arcsearch_acceptance_tol = ccontrol%arcsearch_acceptance_tol
    fcontrol%stabilisation_weight = ccontrol%stabilisation_weight
    fcontrol%cpu_time_limit = ccontrol%cpu_time_limit

    ! Logicals
    fcontrol%direct_subproblem_solve = ccontrol%direct_subproblem_solve
    fcontrol%exact_arc_search = ccontrol%exact_arc_search
    fcontrol%advance = ccontrol%advance
    fcontrol%space_critical = ccontrol%space_critical
    fcontrol%deallocate_error_fatal = ccontrol%deallocate_error_fatal
    fcontrol%generate_sif_file = ccontrol%generate_sif_file

    ! Derived types
    CALL copy_sbls_control_in( ccontrol%sbls_control, fcontrol%sbls_control )
    CALL copy_convert_control_in( ccontrol%convert_control,                    &
                                  fcontrol%convert_control )

    ! Strings
    DO i = 1, LEN( fcontrol%sif_file_name )
      IF ( ccontrol%sif_file_name( i ) == C_NULL_CHAR ) EXIT
      fcontrol%sif_file_name( i : i ) = ccontrol%sif_file_name( i )
    END DO
    DO i = 1, LEN( fcontrol%prefix )
      IF ( ccontrol%prefix( i ) == C_NULL_CHAR ) EXIT
      fcontrol%prefix( i : i ) = ccontrol%prefix( i )
    END DO
    RETURN

    END SUBROUTINE copy_control_in

!  copy fortran control parameters to C

    SUBROUTINE copy_control_out( fcontrol, ccontrol, f_indexing ) 
    TYPE ( f_blls_control_type ), INTENT( IN ) :: fcontrol
    TYPE ( blls_control_type ), INTENT( OUT ) :: ccontrol
    LOGICAL, OPTIONAL, INTENT( IN ) :: f_indexing
    INTEGER :: i, l
    
    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) ccontrol%f_indexing = f_indexing

    ! Integers
    ccontrol%error = fcontrol%error
    ccontrol%out = fcontrol%out
    ccontrol%print_level = fcontrol%print_level
    ccontrol%start_print = fcontrol%start_print
    ccontrol%stop_print = fcontrol%stop_print
    ccontrol%print_gap = fcontrol%print_gap
    ccontrol%maxit = fcontrol%maxit
    ccontrol%cold_start = fcontrol%cold_start
    ccontrol%preconditioner = fcontrol%preconditioner
    ccontrol%ratio_cg_vs_sd = fcontrol%ratio_cg_vs_sd
    ccontrol%change_max = fcontrol%change_max
    ccontrol%cg_maxit = fcontrol%cg_maxit
    ccontrol%arcsearch_max_steps = fcontrol%arcsearch_max_steps
    ccontrol%sif_file_device = fcontrol%sif_file_device

    ! Reals
    ccontrol%weight = fcontrol%weight
    ccontrol%infinity = fcontrol%infinity
    ccontrol%stop_d = fcontrol%stop_d
    ccontrol%identical_bounds_tol = fcontrol%identical_bounds_tol
    ccontrol%stop_cg_relative = fcontrol%stop_cg_relative
    ccontrol%stop_cg_absolute = fcontrol%stop_cg_absolute
    ccontrol%alpha_max = fcontrol%alpha_max
    ccontrol%alpha_initial = fcontrol%alpha_initial
    ccontrol%alpha_reduction = fcontrol%alpha_reduction
    ccontrol%arcsearch_acceptance_tol = fcontrol%arcsearch_acceptance_tol
    ccontrol%stabilisation_weight = fcontrol%stabilisation_weight
    ccontrol%cpu_time_limit = fcontrol%cpu_time_limit

    ! Logicals
    ccontrol%direct_subproblem_solve = fcontrol%direct_subproblem_solve
    ccontrol%exact_arc_search = fcontrol%exact_arc_search
    ccontrol%advance = fcontrol%advance
    ccontrol%space_critical = fcontrol%space_critical
    ccontrol%deallocate_error_fatal = fcontrol%deallocate_error_fatal
    ccontrol%generate_sif_file = fcontrol%generate_sif_file

    ! Derived types
    CALL copy_sbls_control_out( fcontrol%sbls_control, ccontrol%sbls_control )
    CALL copy_convert_control_out( fcontrol%convert_control,                   &
                                   ccontrol%convert_control )

    ! Strings
    l = LEN( fcontrol%sif_file_name )
    DO i = 1, l
      ccontrol%sif_file_name( i ) = fcontrol%sif_file_name( i : i )
    END DO
    ccontrol%sif_file_name( l + 1 ) = C_NULL_CHAR
    l = LEN( fcontrol%prefix )
    DO i = 1, l
      ccontrol%prefix( i ) = fcontrol%prefix( i : i )
    END DO
    ccontrol%prefix( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_control_out

!  copy C time parameters to fortran

    SUBROUTINE copy_time_in( ctime, ftime ) 
    TYPE ( blls_time_type ), INTENT( IN ) :: ctime
    TYPE ( f_blls_time_type ), INTENT( OUT ) :: ftime

    ! Reals
    ftime%total = ctime%total
    ftime%analyse = ctime%analyse
    ftime%factorize = ctime%factorize
    ftime%solve = ctime%solve
    RETURN

    END SUBROUTINE copy_time_in

!  copy fortran time parameters to C

    SUBROUTINE copy_time_out( ftime, ctime ) 
    TYPE ( f_blls_time_type ), INTENT( IN ) :: ftime
    TYPE ( blls_time_type ), INTENT( OUT ) :: ctime

    ! Reals
    ctime%total = ftime%total
    ctime%analyse = ftime%analyse
    ctime%factorize = ftime%factorize
    ctime%solve = ftime%solve
    RETURN

    END SUBROUTINE copy_time_out

!  copy C inform parameters to fortran

    SUBROUTINE copy_inform_in( cinform, finform ) 
    TYPE ( blls_inform_type ), INTENT( IN ) :: cinform
    TYPE ( f_blls_inform_type ), INTENT( OUT ) :: finform
    INTEGER :: i

    ! Integers
    finform%status = cinform%status
    finform%alloc_status = cinform%alloc_status
    finform%factorization_status = cinform%factorization_status
    finform%iter = cinform%iter
    finform%cg_iter = cinform%cg_iter

    ! Reals
    finform%obj = cinform%obj
    finform%norm_pg = cinform%norm_pg

    ! Derived types
    CALL copy_time_in( cinform%time, finform%time )
    CALL copy_sbls_inform_in( cinform%sbls_inform, finform%sbls_inform )
    CALL copy_convert_inform_in( cinform%convert_inform,                       &
                                 finform%convert_inform )

    ! Strings
    DO i = 1, LEN( finform%bad_alloc )
      IF ( cinform%bad_alloc( i ) == C_NULL_CHAR ) EXIT
      finform%bad_alloc( i : i ) = cinform%bad_alloc( i )
    END DO
    RETURN

    END SUBROUTINE copy_inform_in

!  copy fortran inform parameters to C

    SUBROUTINE copy_inform_out( finform, cinform ) 
    TYPE ( f_blls_inform_type ), INTENT( IN ) :: finform
    TYPE ( blls_inform_type ), INTENT( OUT ) :: cinform
    INTEGER :: i, l

    ! Integers
    cinform%status = finform%status
    cinform%alloc_status = finform%alloc_status
    cinform%factorization_status = finform%factorization_status
    cinform%iter = finform%iter
    cinform%cg_iter = finform%cg_iter

    ! Reals
    cinform%obj = finform%obj
    cinform%norm_pg = finform%norm_pg

    ! Derived types
    CALL copy_time_out( finform%time, cinform%time )
    CALL copy_sbls_inform_out( finform%sbls_inform, cinform%sbls_inform )
    CALL copy_convert_inform_out( finform%convert_inform,                      &
                                  cinform%convert_inform )

    ! Strings
    l = LEN( finform%bad_alloc )
    DO i = 1, l
      cinform%bad_alloc( i ) = finform%bad_alloc( i : i )
    END DO
    cinform%bad_alloc( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_inform_out

  END MODULE GALAHAD_BLLS_double_ciface

!  --------------------------------------
!  C interface to fortran blls_initialize
!  --------------------------------------

  SUBROUTINE blls_initialize( cdata, ccontrol, status ) BIND( C ) 
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( C_PTR ), INTENT( OUT ) :: cdata ! data is a black-box
  TYPE ( blls_control_type ), INTENT( OUT ) :: ccontrol

!  local variables

  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  TYPE ( f_blls_control_type ) :: fcontrol
  TYPE ( f_blls_inform_type ) :: finform
  LOGICAL :: f_indexing 

!  allocate fdata

  ALLOCATE( fdata ); cdata = C_LOC( fdata )

!  initialize required fortran types

  CALL f_blls_initialize( fdata, fcontrol, finform )
  status = finform%status

!  C sparse matrix indexing by default

  f_indexing = .FALSE.
  fdata%f_indexing = f_indexing

!  copy control out 

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE blls_initialize

!  -----------------------------------------
!  C interface to fortran blls_read_specfile
!  -----------------------------------------

  SUBROUTINE blls_read_specfile( ccontrol, cspecfile ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( blls_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( IN ), VALUE :: cspecfile

!  local variables

  TYPE ( f_blls_control_type ) :: fcontrol
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

  CALL f_blls_read_specfile( fcontrol, device )

!  close specfile

  CLOSE( device )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE blls_read_specfile

!  ----------------------------------
!  C interface to fortran blls_inport
!  ----------------------------------

  SUBROUTINE blls_import( ccontrol, cdata, status, n, m,                       &
                          catype, ane, arow, acol, aptr ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( blls_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m, ane
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( ane ), OPTIONAL :: arow
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( ane ), OPTIONAL :: acol
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( m + 1 ), OPTIONAL :: aptr
  TYPE ( C_PTR ), INTENT( IN ), VALUE :: catype

!  local variables

  CHARACTER ( KIND = C_CHAR, LEN = opt_strlen( catype ) ) :: fatype
  TYPE ( f_blls_control_type ) :: fcontrol
  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control and inform in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  convert C string to Fortran string

   fatype = cstr_to_fchar( catype )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

!  import the problem data into the required BLLS structure

  CALL f_blls_import( fcontrol, fdata, status, n, m,                           &
                      fatype, ane, arow, acol, aptr )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE blls_import

!  --------------------------------------------
!  C interface to fortran blls_inport_without_a
!  --------------------------------------------

  SUBROUTINE blls_import_without_a( ccontrol, cdata, status, n, m ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( blls_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m

!  local variables

  TYPE ( f_blls_control_type ) :: fcontrol
  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control and inform in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

  CALL f_blls_import_without_a( fcontrol, fdata, status, n, m )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE blls_import_without_a

!  -----------------------------------------
!  C interface to fortran blls_reset_control
!  -----------------------------------------

  SUBROUTINE blls_reset_control( ccontrol, cdata, status ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( blls_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata

!  local variables

  TYPE ( f_blls_control_type ) :: fcontrol
  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

!  import the control parameters into the required structure

  CALL f_BLLS_reset_control( fcontrol, fdata, status )
  RETURN

  END SUBROUTINE blls_reset_control

!  -----------------------------------------
!  C interface to fortran blls_solve_given_a
!  -----------------------------------------

  SUBROUTINE blls_solve_given_a( cdata, cuserdata, status, n, m, ane, aval,    &
                                 b, xl, xu, x, z, c, g, xstat,                 &
                                 ceval_prec ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( C_PTR ), INTENT( INOUT ) :: cuserdata
  INTEGER ( KIND = C_INT ), INTENT( INOUT ) :: status
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m, ane
  REAL ( KIND = wp ), DIMENSION( ane ), INTENT( IN ) :: aval
  REAL ( KIND = wp ), DIMENSION( m ), INTENT( IN ) :: b
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( IN ) :: xl, xu
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( INOUT ) :: x, z
  REAL ( KIND = wp ), DIMENSION( m ), INTENT( OUT ) :: c
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( OUT ) :: g
  INTEGER, INTENT( OUT ), DIMENSION( n ) :: xstat
  TYPE ( C_FUNPTR ), INTENT( IN ), VALUE :: ceval_prec

!  local variables

  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  PROCEDURE( eval_prec ), POINTER :: feval_prec

!  ignore Fortran userdata type (not interoperable)

! TYPE ( f_galahad_userdata_type ), POINTER :: fuserdata => NULL( )
  TYPE ( f_galahad_userdata_type ) :: fuserdata

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  associate procedure pointers

  IF ( C_ASSOCIATED( ceval_prec ) ) THEN 
    CALL C_F_PROCPOINTER( ceval_prec, feval_prec )
  ELSE
    NULLIFY( feval_prec )
  END IF

!  solve the bound-constrained least-squares problem

  CALL f_blls_solve_given_a( fdata, fuserdata, status, aval, b, xl, xu,        &
                             x, z, c, g, xstat, wrap_eval_prec )

  RETURN

!  wrappers

  CONTAINS

!  eval_PREC wrapper

    SUBROUTINE wrap_eval_prec( status, userdata, v, p )
    INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
    TYPE ( f_galahad_userdata_type ), INTENT( INOUT ) :: userdata
    REAL ( KIND = wp ), DIMENSION( : ), INTENT( IN ) :: v
    REAL ( KIND = wp ), DIMENSION( : ), INTENT( OUT ) :: p

!  call C interoperable eval_prec

    status = feval_prec( n, v, p, cuserdata )
    RETURN

    END SUBROUTINE wrap_eval_prec

  END SUBROUTINE blls_solve_given_a

!  ------------------------------------------------
!  C interface to fortran blls_solve_reverse_a_prod
!  ------------------------------------------------

  SUBROUTINE blls_solve_reverse_a_prod( cdata, status, eval_status, n, m, b,   &
                                        xl, xu, x, z, c, g, xstat, v, p,       &
                                        nz_v, nz_v_start, nz_v_end,         &
                                        nz_p, nz_p_end ) BIND( C )
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  INTEGER ( KIND = C_INT ), INTENT( INOUT ) :: status, eval_status
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m
  REAL ( KIND = wp ), DIMENSION( m ), INTENT( IN ) :: b
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( IN ) :: xl, xu
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( INOUT ) :: x, z
  REAL ( KIND = wp ), DIMENSION( m ), INTENT( OUT ) :: c
  REAL ( KIND = wp ), DIMENSION( n ), INTENT( OUT ) :: g
  INTEGER ( KIND = C_INT ), INTENT( OUT ), DIMENSION( n ) :: xstat
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: nz_p_end
  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: nz_v_start, nz_v_end
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( m ) :: nz_p
  INTEGER ( KIND = C_INT ), INTENT( OUT ), DIMENSION( MAX( n, m ) ) :: nz_v
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( MAX( n, m ) ) :: p
  REAL ( KIND = wp ), INTENT( OUT ), DIMENSION( MAX( n, m ) ) :: v

!  local variables

  TYPE ( f_blls_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  is fortran-style 1-based indexing used?

  f_indexing = fdata%f_indexing

!  solve the bound-constrained least-squares problem by reverse communication

!if (status == 4 ) write(6,"( ' P ', /, ( 5ES12.4 ) )" ) P(:m)
  IF ( f_indexing ) THEN
    CALL f_blls_solve_reverse_a_prod( fdata, status, eval_status, b, xl, xu,   &
                                      x, z, c, g, xstat, v, p,                 &
                                      nz_v, nz_v_start, nz_v_end,              &
                                      nz_p, nz_p_end )
  ELSE
    CALL f_blls_solve_reverse_a_prod( fdata, status, eval_status, b, xl, xu,   &
                                      x, z, c, g, xstat, v, p,                 &
                                      nz_v, nz_v_start, nz_v_end,              &
                                      nz_p( : nz_p_end ) + 1, nz_p_end )
    IF ( status == 4 .OR. status == 5 .OR. status == 6 ) then
      nz_v( nz_v_start : nz_v_end ) = nz_v( nz_v_start : nz_v_end ) - 1
    END IF 
  END IF 

  RETURN

  END SUBROUTINE blls_solve_reverse_a_prod

!  ---------------------------------------
!  C interface to fortran blls_information
!  ---------------------------------------

  SUBROUTINE blls_information( cdata, cinform, status ) BIND( C ) 
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( blls_inform_type ), INTENT( INOUT ) :: cinform
  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status

!  local variables

  TYPE ( f_blls_full_data_type ), pointer :: fdata
  TYPE ( f_blls_inform_type ) :: finform

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  obtain BLLS solution information

  CALL f_blls_information( fdata, finform, status )

!  copy inform out

  CALL copy_inform_out( finform, cinform )
  RETURN

  END SUBROUTINE blls_information

!  -------------------------------------
!  C interface to fortran blls_terminate
!  -------------------------------------

  SUBROUTINE blls_terminate( cdata, ccontrol, cinform ) BIND( C ) 
  USE GALAHAD_BLLS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( blls_control_type ), INTENT( IN ) :: ccontrol
  TYPE ( blls_inform_type ), INTENT( INOUT ) :: cinform

!  local variables

  TYPE ( f_blls_full_data_type ), pointer :: fdata
  TYPE ( f_blls_control_type ) :: fcontrol
  TYPE ( f_blls_inform_type ) :: finform
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  copy inform in

  CALL copy_inform_in( cinform, finform )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  deallocate workspace

  CALL f_blls_terminate( fdata, fcontrol, finform )

!  copy inform out

  CALL copy_inform_out( finform, cinform )

!  deallocate data

  DEALLOCATE( fdata ); cdata = C_NULL_PTR 
  RETURN

  END SUBROUTINE blls_terminate
