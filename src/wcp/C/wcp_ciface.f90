! THIS VERSION: GALAHAD 4.1 - 2022-11-21 AT 12:30 GMT.

!-*-*-*-*-*-*-*-  G A L A H A D _  W C P    C   I N T E R F A C E  -*-*-*-*-*-

!  Copyright reserved, Gould/Orban/Toint, for GALAHAD productions
!  Principal authors: Jaroslav Fowkes & Nick Gould

!  History -
!    originally released GALAHAD Version 4.0. January 13th 2022

!  For full documentation, see
!   http://galahad.rl.ac.uk/galahad-www/specs.html

  MODULE GALAHAD_WCP_double_ciface
    USE iso_c_binding
    USE GALAHAD_common_ciface
    USE GALAHAD_WCP_double, ONLY:                                              &
        f_wcp_control_type   => WCP_control_type,                              &
        f_wcp_time_type      => WCP_time_type,                                 &
        f_wcp_inform_type    => WCP_inform_type,                               &
        f_wcp_full_data_type => WCP_full_data_type,                            &
        f_wcp_initialize     => WCP_initialize,                                &
        f_wcp_read_specfile  => WCP_read_specfile,                             &
        f_wcp_import         => WCP_import,                                    &
        f_wcp_reset_control  => WCP_reset_control,                             &
        f_wcp_find_wcp       => WCP_find_wcp,                                  &
        f_wcp_information    => WCP_information,                               &
        f_wcp_terminate      => WCP_terminate

    USE GALAHAD_FDC_double_ciface, ONLY:                                       &
        fdc_inform_type,                                                       &
        fdc_control_type,                                                      &
        copy_fdc_inform_in  => copy_inform_in,                                 &
        copy_fdc_inform_out  => copy_inform_out,                               &
        copy_fdc_control_in  => copy_control_in,                               &
        copy_fdc_control_out => copy_control_out

    USE GALAHAD_SBLS_double_ciface, ONLY:                                      &
        sbls_inform_type,                                                      &
        sbls_control_type,                                                     &
        copy_sbls_inform_in   => copy_inform_in,                               &
        copy_sbls_inform_out  => copy_inform_out,                              &
        copy_sbls_control_in  => copy_control_in,                              &
        copy_sbls_control_out => copy_control_out

    IMPLICIT NONE

!--------------------
!   P r e c i s i o n
!--------------------

    INTEGER, PARAMETER :: wp = C_DOUBLE ! double precision
    INTEGER, PARAMETER :: sp = C_FLOAT  ! single precision

!-------------------------------------------------
!  D e r i v e d   t y p e   d e f i n i t i o n s
!-------------------------------------------------

    TYPE, BIND( C ) :: wcp_control_type
      LOGICAL ( KIND = C_BOOL ) :: f_indexing
      INTEGER ( KIND = C_INT ) :: error
      INTEGER ( KIND = C_INT ) :: out
      INTEGER ( KIND = C_INT ) :: print_level
      INTEGER ( KIND = C_INT ) :: start_print
      INTEGER ( KIND = C_INT ) :: stop_print
      INTEGER ( KIND = C_INT ) :: maxit
      INTEGER ( KIND = C_INT ) :: initial_point
      INTEGER ( KIND = C_INT ) :: factor
      INTEGER ( KIND = C_INT ) :: max_col
      INTEGER ( KIND = C_INT ) :: indmin
      INTEGER ( KIND = C_INT ) :: valmin
      INTEGER ( KIND = C_INT ) :: itref_max
      INTEGER ( KIND = C_INT ) :: infeas_max
      INTEGER ( KIND = C_INT ) :: perturbation_strategy
      INTEGER ( KIND = C_INT ) :: restore_problem
      REAL ( KIND = wp ) :: infinity
      REAL ( KIND = wp ) :: stop_p
      REAL ( KIND = wp ) :: stop_d
      REAL ( KIND = wp ) :: stop_c
      REAL ( KIND = wp ) :: prfeas
      REAL ( KIND = wp ) :: dufeas
      REAL ( KIND = wp ) :: mu_target
      REAL ( KIND = wp ) :: mu_accept_fraction
      REAL ( KIND = wp ) :: mu_increase_factor
      REAL ( KIND = wp ) :: required_infeas_reduction
      REAL ( KIND = wp ) :: implicit_tol
      REAL ( KIND = wp ) :: pivot_tol
      REAL ( KIND = wp ) :: pivot_tol_for_dependencies
      REAL ( KIND = wp ) :: zero_pivot
      REAL ( KIND = wp ) :: perturb_start
      REAL ( KIND = wp ) :: alpha_scale
      REAL ( KIND = wp ) :: identical_bounds_tol
      REAL ( KIND = wp ) :: reduce_perturb_factor
      REAL ( KIND = wp ) :: reduce_perturb_multiplier
      REAL ( KIND = wp ) :: insufficiently_feasible
      REAL ( KIND = wp ) :: perturbation_small
      REAL ( KIND = wp ) :: cpu_time_limit
      REAL ( KIND = wp ) :: clock_time_limit
      LOGICAL ( KIND = C_BOOL ) :: remove_dependencies
      LOGICAL ( KIND = C_BOOL ) :: treat_zero_bounds_as_general
      LOGICAL ( KIND = C_BOOL ) :: just_feasible
      LOGICAL ( KIND = C_BOOL ) :: balance_initial_complementarity
      LOGICAL ( KIND = C_BOOL ) :: use_corrector
      LOGICAL ( KIND = C_BOOL ) :: space_critical
      LOGICAL ( KIND = C_BOOL ) :: deallocate_error_fatal
      LOGICAL ( KIND = C_BOOL ) :: record_x_status
      LOGICAL ( KIND = C_BOOL ) :: record_c_status
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 31 ) :: prefix
      TYPE ( fdc_control_type ) :: fdc_control
      TYPE ( sbls_control_type ) :: sbls_control
    END TYPE wcp_control_type

    TYPE, BIND( C ) :: wcp_time_type
      REAL ( KIND = wp ) :: total
      REAL ( KIND = wp ) :: preprocess
      REAL ( KIND = wp ) :: find_dependent
      REAL ( KIND = wp ) :: analyse
      REAL ( KIND = wp ) :: factorize
      REAL ( KIND = wp ) :: solve
      REAL ( KIND = wp ) :: clock_total
      REAL ( KIND = wp ) :: clock_preprocess
      REAL ( KIND = wp ) :: clock_find_dependent
      REAL ( KIND = wp ) :: clock_analyse
      REAL ( KIND = wp ) :: clock_factorize
      REAL ( KIND = wp ) :: clock_solve
    END TYPE wcp_time_type

    TYPE, BIND( C ) :: wcp_inform_type
      INTEGER ( KIND = C_INT ) :: status
      INTEGER ( KIND = C_INT ) :: alloc_status
      CHARACTER ( KIND = C_CHAR ), DIMENSION( 81 ) :: bad_alloc
      INTEGER ( KIND = C_INT ) :: iter
      INTEGER ( KIND = C_INT ) :: factorization_status
      INTEGER ( KIND = C_INT64_T ) :: factorization_integer
      INTEGER ( KIND = C_INT64_T ) :: factorization_real
      INTEGER ( KIND = C_INT ) :: nfacts
      INTEGER ( KIND = C_INT ) :: c_implicit
      INTEGER ( KIND = C_INT ) :: x_implicit
      INTEGER ( KIND = C_INT ) :: y_implicit
      INTEGER ( KIND = C_INT ) :: z_implicit
      REAL ( KIND = wp ) :: obj
      REAL ( KIND = wp ) :: mu_final_target_max
      REAL ( KIND = wp ) :: non_negligible_pivot
      LOGICAL ( KIND = C_BOOL ) :: feasible
      TYPE ( wcp_time_type ) :: time
      TYPE ( fdc_inform_type ) :: fdc_inform
      TYPE ( sbls_inform_type ) :: sbls_inform
    END TYPE wcp_inform_type

!----------------------
!   P r o c e d u r e s
!----------------------

  CONTAINS

!  copy C control parameters to fortran

    SUBROUTINE copy_control_in( ccontrol, fcontrol, f_indexing )
    TYPE ( wcp_control_type ), INTENT( IN ) :: ccontrol
    TYPE ( f_wcp_control_type ), INTENT( OUT ) :: fcontrol
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
    fcontrol%maxit = ccontrol%maxit
    fcontrol%initial_point = ccontrol%initial_point
    fcontrol%factor = ccontrol%factor
    fcontrol%max_col = ccontrol%max_col
    fcontrol%indmin = ccontrol%indmin
    fcontrol%valmin = ccontrol%valmin
    fcontrol%itref_max = ccontrol%itref_max
    fcontrol%infeas_max = ccontrol%infeas_max
    fcontrol%perturbation_strategy = ccontrol%perturbation_strategy
    fcontrol%restore_problem = ccontrol%restore_problem

    ! Reals
    fcontrol%infinity = ccontrol%infinity
    fcontrol%stop_p = ccontrol%stop_p
    fcontrol%stop_d = ccontrol%stop_d
    fcontrol%stop_c = ccontrol%stop_c
    fcontrol%prfeas = ccontrol%prfeas
    fcontrol%dufeas = ccontrol%dufeas
    fcontrol%mu_target = ccontrol%mu_target
    fcontrol%mu_accept_fraction = ccontrol%mu_accept_fraction
    fcontrol%mu_increase_factor = ccontrol%mu_increase_factor
    fcontrol%required_infeas_reduction = ccontrol%required_infeas_reduction
    fcontrol%implicit_tol = ccontrol%implicit_tol
    fcontrol%pivot_tol = ccontrol%pivot_tol
    fcontrol%pivot_tol_for_dependencies = ccontrol%pivot_tol_for_dependencies
    fcontrol%zero_pivot = ccontrol%zero_pivot
    fcontrol%perturb_start = ccontrol%perturb_start
    fcontrol%alpha_scale = ccontrol%alpha_scale
    fcontrol%identical_bounds_tol = ccontrol%identical_bounds_tol
    fcontrol%reduce_perturb_factor = ccontrol%reduce_perturb_factor
    fcontrol%reduce_perturb_multiplier = ccontrol%reduce_perturb_multiplier
    fcontrol%insufficiently_feasible = ccontrol%insufficiently_feasible
    fcontrol%perturbation_small = ccontrol%perturbation_small
    fcontrol%cpu_time_limit = ccontrol%cpu_time_limit
    fcontrol%clock_time_limit = ccontrol%clock_time_limit

    ! Logicals
    fcontrol%remove_dependencies = ccontrol%remove_dependencies
    fcontrol%treat_zero_bounds_as_general                                      &
      = ccontrol%treat_zero_bounds_as_general
    fcontrol%just_feasible = ccontrol%just_feasible
    fcontrol%balance_initial_complementarity                                   &
      = ccontrol%balance_initial_complementarity
    fcontrol%use_corrector = ccontrol%use_corrector
    fcontrol%space_critical = ccontrol%space_critical
    fcontrol%deallocate_error_fatal = ccontrol%deallocate_error_fatal
    fcontrol%record_x_status = ccontrol%record_x_status
    fcontrol%record_c_status = ccontrol%record_c_status

    ! Derived types
    CALL copy_fdc_control_in( ccontrol%fdc_control, fcontrol%fdc_control )
    CALL copy_sbls_control_in( ccontrol%sbls_control, fcontrol%sbls_control )

    ! Strings
    DO i = 1, LEN( fcontrol%prefix )
      IF ( ccontrol%prefix( i ) == C_NULL_CHAR ) EXIT
      fcontrol%prefix( i : i ) = ccontrol%prefix( i )
    END DO
    RETURN

    END SUBROUTINE copy_control_in

!  copy fortran control parameters to C

    SUBROUTINE copy_control_out( fcontrol, ccontrol, f_indexing )
    TYPE ( f_wcp_control_type ), INTENT( IN ) :: fcontrol
    TYPE ( wcp_control_type ), INTENT( OUT ) :: ccontrol
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
    ccontrol%maxit = fcontrol%maxit
    ccontrol%initial_point = fcontrol%initial_point
    ccontrol%factor = fcontrol%factor
    ccontrol%max_col = fcontrol%max_col
    ccontrol%indmin = fcontrol%indmin
    ccontrol%valmin = fcontrol%valmin
    ccontrol%itref_max = fcontrol%itref_max
    ccontrol%infeas_max = fcontrol%infeas_max
    ccontrol%perturbation_strategy = fcontrol%perturbation_strategy
    ccontrol%restore_problem = fcontrol%restore_problem

    ! Reals
    ccontrol%infinity = fcontrol%infinity
    ccontrol%stop_p = fcontrol%stop_p
    ccontrol%stop_d = fcontrol%stop_d
    ccontrol%stop_c = fcontrol%stop_c
    ccontrol%prfeas = fcontrol%prfeas
    ccontrol%dufeas = fcontrol%dufeas
    ccontrol%mu_target = fcontrol%mu_target
    ccontrol%mu_accept_fraction = fcontrol%mu_accept_fraction
    ccontrol%mu_increase_factor = fcontrol%mu_increase_factor
    ccontrol%required_infeas_reduction = fcontrol%required_infeas_reduction
    ccontrol%implicit_tol = fcontrol%implicit_tol
    ccontrol%pivot_tol = fcontrol%pivot_tol
    ccontrol%pivot_tol_for_dependencies = fcontrol%pivot_tol_for_dependencies
    ccontrol%zero_pivot = fcontrol%zero_pivot
    ccontrol%perturb_start = fcontrol%perturb_start
    ccontrol%alpha_scale = fcontrol%alpha_scale
    ccontrol%identical_bounds_tol = fcontrol%identical_bounds_tol
    ccontrol%reduce_perturb_factor = fcontrol%reduce_perturb_factor
    ccontrol%reduce_perturb_multiplier = fcontrol%reduce_perturb_multiplier
    ccontrol%insufficiently_feasible = fcontrol%insufficiently_feasible
    ccontrol%perturbation_small = fcontrol%perturbation_small
    ccontrol%cpu_time_limit = fcontrol%cpu_time_limit
    ccontrol%clock_time_limit = fcontrol%clock_time_limit

    ! Logicals
    ccontrol%remove_dependencies = fcontrol%remove_dependencies
    ccontrol%treat_zero_bounds_as_general                                      &
      = fcontrol%treat_zero_bounds_as_general
    ccontrol%just_feasible = fcontrol%just_feasible
    ccontrol%balance_initial_complementarity                                   &
      = fcontrol%balance_initial_complementarity
    ccontrol%use_corrector = fcontrol%use_corrector
    ccontrol%space_critical = fcontrol%space_critical
    ccontrol%deallocate_error_fatal = fcontrol%deallocate_error_fatal
    ccontrol%record_x_status = fcontrol%record_x_status
    ccontrol%record_c_status = fcontrol%record_c_status

    ! Derived types
    CALL copy_fdc_control_out( fcontrol%fdc_control, ccontrol%fdc_control )
    CALL copy_sbls_control_out( fcontrol%sbls_control, ccontrol%sbls_control )

    ! Strings
    l = LEN( fcontrol%prefix )
    DO i = 1, l
      ccontrol%prefix( i ) = fcontrol%prefix( i : i )
    END DO
    ccontrol%prefix( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_control_out

!  copy C time parameters to fortran

    SUBROUTINE copy_time_in( ctime, ftime )
    TYPE ( wcp_time_type ), INTENT( IN ) :: ctime
    TYPE ( f_wcp_time_type ), INTENT( OUT ) :: ftime

    ! Reals
    ftime%total = ctime%total
    ftime%preprocess = ctime%preprocess
    ftime%find_dependent = ctime%find_dependent
    ftime%analyse = ctime%analyse
    ftime%factorize = ctime%factorize
    ftime%solve = ctime%solve
    ftime%clock_total = ctime%clock_total
    ftime%clock_preprocess = ctime%clock_preprocess
    ftime%clock_find_dependent = ctime%clock_find_dependent
    ftime%clock_analyse = ctime%clock_analyse
    ftime%clock_factorize = ctime%clock_factorize
    ftime%clock_solve = ctime%clock_solve
    RETURN

    END SUBROUTINE copy_time_in

!  copy fortran time parameters to C

    SUBROUTINE copy_time_out( ftime, ctime )
    TYPE ( f_wcp_time_type ), INTENT( IN ) :: ftime
    TYPE ( wcp_time_type ), INTENT( OUT ) :: ctime

    ! Reals
    ctime%total = ftime%total
    ctime%preprocess = ftime%preprocess
    ctime%find_dependent = ftime%find_dependent
    ctime%analyse = ftime%analyse
    ctime%factorize = ftime%factorize
    ctime%solve = ftime%solve
    ctime%clock_total = ftime%clock_total
    ctime%clock_preprocess = ftime%clock_preprocess
    ctime%clock_find_dependent = ftime%clock_find_dependent
    ctime%clock_analyse = ftime%clock_analyse
    ctime%clock_factorize = ftime%clock_factorize
    ctime%clock_solve = ftime%clock_solve
    RETURN

    END SUBROUTINE copy_time_out

!  copy C inform parameters to fortran

    SUBROUTINE copy_inform_in( cinform, finform )
    TYPE ( wcp_inform_type ), INTENT( IN ) :: cinform
    TYPE ( f_wcp_inform_type ), INTENT( OUT ) :: finform
    INTEGER :: i

    ! Integers
    finform%status = cinform%status
    finform%alloc_status = cinform%alloc_status
    finform%iter = cinform%iter
    finform%factorization_status = cinform%factorization_status
    finform%factorization_integer = cinform%factorization_integer
    finform%factorization_real = cinform%factorization_real
    finform%nfacts = cinform%nfacts
    finform%c_implicit = cinform%c_implicit
    finform%x_implicit = cinform%x_implicit
    finform%y_implicit = cinform%y_implicit
    finform%z_implicit = cinform%z_implicit

    ! Reals
    finform%obj = cinform%obj
    finform%mu_final_target_max = cinform%mu_final_target_max
    finform%non_negligible_pivot = cinform%non_negligible_pivot

    ! Logicals
    finform%feasible = cinform%feasible

    ! Derived types
    CALL copy_time_in( cinform%time, finform%time )
    CALL copy_fdc_inform_in( cinform%fdc_inform, finform%fdc_inform )
    CALL copy_sbls_inform_in( cinform%sbls_inform, finform%sbls_inform )

    ! Strings
    DO i = 1, LEN( finform%bad_alloc )
      IF ( cinform%bad_alloc( i ) == C_NULL_CHAR ) EXIT
      finform%bad_alloc( i : i ) = cinform%bad_alloc( i )
    END DO
    RETURN

    END SUBROUTINE copy_inform_in

!  copy fortran inform parameters to C

    SUBROUTINE copy_inform_out( finform, cinform )
    TYPE ( f_wcp_inform_type ), INTENT( IN ) :: finform
    TYPE ( wcp_inform_type ), INTENT( OUT ) :: cinform
    INTEGER :: i, l

    ! Integers
    cinform%status = finform%status
    cinform%alloc_status = finform%alloc_status
    cinform%iter = finform%iter
    cinform%factorization_status = finform%factorization_status
    cinform%factorization_integer = finform%factorization_integer
    cinform%factorization_real = finform%factorization_real
    cinform%nfacts = finform%nfacts
    cinform%c_implicit = finform%c_implicit
    cinform%x_implicit = finform%x_implicit
    cinform%y_implicit = finform%y_implicit
    cinform%z_implicit = finform%z_implicit

    ! Reals
    cinform%obj = finform%obj
    cinform%mu_final_target_max = finform%mu_final_target_max
    cinform%non_negligible_pivot = finform%non_negligible_pivot

    ! Logicals
    cinform%feasible = finform%feasible

    ! Derived types
    CALL copy_time_out( finform%time, cinform%time )
    CALL copy_fdc_inform_out( finform%fdc_inform, cinform%fdc_inform )
    CALL copy_sbls_inform_out( finform%sbls_inform, cinform%sbls_inform )

    ! Strings
    l = LEN( finform%bad_alloc )
    DO i = 1, l
      cinform%bad_alloc( i ) = finform%bad_alloc( i : i )
    END DO
    cinform%bad_alloc( l + 1 ) = C_NULL_CHAR
    RETURN

    END SUBROUTINE copy_inform_out

  END MODULE GALAHAD_WCP_double_ciface

!  --------------------------------------
!  C interface to fortran wcp_initialize
!  --------------------------------------

  SUBROUTINE wcp_initialize( cdata, ccontrol, status ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( C_PTR ), INTENT( OUT ) :: cdata ! data is a black-box
  TYPE ( wcp_control_type ), INTENT( OUT ) :: ccontrol

!  local variables

  TYPE ( f_wcp_full_data_type ), POINTER :: fdata
  TYPE ( f_wcp_control_type ) :: fcontrol
  TYPE ( f_wcp_inform_type ) :: finform
  LOGICAL :: f_indexing

!  allocate fdata

  ALLOCATE( fdata ); cdata = C_LOC( fdata )

!  initialize required fortran types

  CALL f_wcp_initialize( fdata, fcontrol, finform )
  status = finform%status

!  C sparse matrix indexing by default

  f_indexing = .FALSE.
  fdata%f_indexing = f_indexing

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )

  RETURN

  END SUBROUTINE wcp_initialize

!  -----------------------------------------
!  C interface to fortran wcp_read_specfile
!  -----------------------------------------

  SUBROUTINE wcp_read_specfile( ccontrol, cspecfile ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( wcp_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( IN ), VALUE :: cspecfile

!  local variables

  TYPE ( f_wcp_control_type ) :: fcontrol
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

  CALL f_wcp_read_specfile( fcontrol, device )

!  close specfile

  CLOSE( device )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE wcp_read_specfile

!  ----------------------------------
!  C interface to fortran wcp_inport
!  ----------------------------------

  SUBROUTINE wcp_import( ccontrol, cdata, status, n, m,                        &
                          catype, ane, arow, acol, aptr ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( wcp_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m, ane
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( ane ), OPTIONAL :: arow
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( ane ), OPTIONAL :: acol
  INTEGER ( KIND = C_INT ), INTENT( IN ), DIMENSION( m + 1 ), OPTIONAL :: aptr
  TYPE ( C_PTR ), INTENT( IN ), VALUE :: catype

!  local variables

  CHARACTER ( KIND = C_CHAR, LEN = opt_strlen( catype ) ) :: fatype
  TYPE ( f_wcp_control_type ) :: fcontrol
  TYPE ( f_wcp_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control and inform in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  convert C string to Fortran string

  fatype = cstr_to_fchar( catype )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

!  import the problem data into the required WCP structure

  CALL f_wcp_import( fcontrol, fdata, status, n, m,                            &
                     fatype, ane, arow, acol, aptr )

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE wcp_import

!  -----------------------------------------
!  C interface to fortran wcp_reset_control
!  -----------------------------------------

  SUBROUTINE wcp_reset_control( ccontrol, cdata, status ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( wcp_control_type ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata

!  local variables

  TYPE ( f_wcp_control_type ) :: fcontrol
  TYPE ( f_wcp_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

!  import the control parameters into the required structure

  CALL f_wcp_reset_control( fcontrol, fdata, status )
  RETURN

  END SUBROUTINE wcp_reset_control

!  ------------------------------------
!  C interface to fortran wcp_find_wcp
!  ------------------------------------

  SUBROUTINE wcp_find_wcp( cdata, status, n, m, g, ane, aval, cl, cu, xl, xu,  &
                           x, c, yl, yu, zl, zu, xstat, cstat ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( IN ), VALUE :: n, m, ane
  INTEGER ( KIND = C_INT ), INTENT( INOUT ) :: status
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( ane ) :: aval
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( n ) :: g
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( m ) :: cl, cu
  REAL ( KIND = wp ), INTENT( IN ), DIMENSION( n ) :: xl, xu
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( n ) :: x, zl, zu
  REAL ( KIND = wp ), INTENT( INOUT ), DIMENSION( m ) :: yl, yu
  REAL ( KIND = wp ), INTENT( OUT ), DIMENSION( m ) :: c
  INTEGER ( KIND = C_INT ), INTENT( OUT ), DIMENSION( n ) :: xstat
  INTEGER ( KIND = C_INT ), INTENT( OUT ), DIMENSION( m ) :: cstat
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata

!  local variables

  TYPE ( f_wcp_full_data_type ), POINTER :: fdata

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  solve the qp

  CALL f_wcp_find_wcp( fdata, status, g, aval, cl, cu, xl, xu,                 &
                        x, c, yl, yu, zl, zu, xstat, cstat )
  RETURN

  END SUBROUTINE wcp_find_wcp

!  --------------------------------------
!  C interface to fortran wcp_information
!  --------------------------------------

  SUBROUTINE wcp_information( cdata, cinform, status ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( wcp_inform_type ), INTENT( INOUT ) :: cinform
  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status

!  local variables

  TYPE ( f_wcp_full_data_type ), pointer :: fdata
  TYPE ( f_wcp_inform_type ) :: finform

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  obtain WCP solution information

  CALL f_wcp_information( fdata, finform, status )

!  copy inform out

  CALL copy_inform_out( finform, cinform )
  RETURN

  END SUBROUTINE wcp_information

!  -------------------------------------
!  C interface to fortran wcp_terminate
!  -------------------------------------

  SUBROUTINE wcp_terminate( cdata, ccontrol, cinform ) BIND( C )
  USE GALAHAD_WCP_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( wcp_control_type ), INTENT( IN ) :: ccontrol
  TYPE ( wcp_inform_type ), INTENT( INOUT ) :: cinform

!  local variables

  TYPE ( f_wcp_full_data_type ), pointer :: fdata
  TYPE ( f_wcp_control_type ) :: fcontrol
  TYPE ( f_wcp_inform_type ) :: finform
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  copy inform in

  CALL copy_inform_in( cinform, finform )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  deallocate workspace

  CALL f_wcp_terminate( fdata, fcontrol, finform )

!  copy inform out

  CALL copy_inform_out( finform, cinform )

!  deallocate data

  DEALLOCATE( fdata ); cdata = C_NULL_PTR
  RETURN

  END SUBROUTINE wcp_terminate
