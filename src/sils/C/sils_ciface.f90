! THIS VERSION: GALAHAD 3.3 - 29/11/2021 AT 13:00 GMT.

!-*-*-*-*-*-*-*-  G A L A H A D _  S I L S    C   I N T E R F A C E  -*-*-*-*-*-

!  Copyright reserved, Gould/Orban/Toint, for GALAHAD productions
!  Principal authors: Jaroslav Fowkes & Nick Gould

!  History -
!    originally released GALAHAD Version 3.3. November 29th 2021

!  For full documentation, see
!   http://galahad.rl.ac.uk/galahad-www/specs.html

  MODULE GALAHAD_SILS_double_ciface
    USE iso_c_binding
    USE GALAHAD_common_ciface
    USE GALAHAD_SILS_double, ONLY: &
        f_sils_control => SILS_control, &
        f_sils_ainfo => SILS_ainfo, &
        f_sils_finfo => SILS_finfo, &
        f_sils_sinfo => SILS_sinfo, &
        f_sils_full_data_type => SILS_full_data_type, &
        f_sils_initialize => SILS_initialize, &
        f_sils_reset_control => SILS_reset_control, &
        f_sils_information => SILS_information, &
        f_sils_finalize => SILS_finalize

    IMPLICIT NONE

!--------------------
!   P r e c i s i o n
!--------------------

    INTEGER, PARAMETER :: wp = C_DOUBLE ! double precision
    INTEGER, PARAMETER :: sp = C_FLOAT  ! single precision

!-------------------------------------------------
!  D e r i v e d   t y p e   d e f i n i t i o n s
!-------------------------------------------------

    TYPE, BIND( C ) :: sils_control
      LOGICAL ( KIND = C_BOOL ) :: f_indexing
      INTEGER ( KIND = C_INT ) :: ICNTL( 30 )
      INTEGER ( KIND = C_INT ) :: lp
      INTEGER ( KIND = C_INT ) :: wp
      INTEGER ( KIND = C_INT ) :: mp
      INTEGER ( KIND = C_INT ) :: sp
      INTEGER ( KIND = C_INT ) :: ldiag
      INTEGER ( KIND = C_INT ) :: la
      INTEGER ( KIND = C_INT ) :: liw
      INTEGER ( KIND = C_INT ) :: maxla
      INTEGER ( KIND = C_INT ) :: maxliw
      INTEGER ( KIND = C_INT ) :: pivoting
      INTEGER ( KIND = C_INT ) :: nemin
      INTEGER ( KIND = C_INT ) :: factorblocking
      INTEGER ( KIND = C_INT ) :: solveblocking
      INTEGER ( KIND = C_INT ) :: thresh
      INTEGER ( KIND = C_INT ) :: ordering
      INTEGER ( KIND = C_INT ) :: scaling
      REAL ( KIND = wp ) :: CNTL( 5 )
      REAL ( KIND = wp ) :: multiplier
      REAL ( KIND = wp ) :: reduce
      REAL ( KIND = wp ) :: u
      REAL ( KIND = wp ) :: static_tolerance
      REAL ( KIND = wp ) :: static_level
      REAL ( KIND = wp ) :: tolerance
      REAL ( KIND = wp ) :: convergence
    END TYPE sils_control

    TYPE, BIND( C ) :: SILS_ainfo
      INTEGER ( KIND = C_INT ) :: flag
      INTEGER ( KIND = C_INT ) :: more
      INTEGER ( KIND = C_INT ) :: nsteps
      INTEGER ( KIND = C_INT ) :: nrltot
      INTEGER ( KIND = C_INT ) :: nirtot
      INTEGER ( KIND = C_INT ) :: nrlnec
      INTEGER ( KIND = C_INT ) :: nirnec
      INTEGER ( KIND = C_INT ) :: nrladu
      INTEGER ( KIND = C_INT ) :: niradu
      INTEGER ( KIND = C_INT ) :: ncmpa
      INTEGER ( KIND = C_INT ) :: oor
      INTEGER ( KIND = C_INT ) :: dup
      INTEGER ( KIND = C_INT ) :: maxfrt
      INTEGER ( KIND = C_INT ) :: stat
      INTEGER ( KIND = C_INT ) :: faulty
      REAL ( KIND = wp ) :: opsa
      REAL ( KIND = wp ) :: opse
    END TYPE SILS_ainfo

    TYPE, BIND( C ) :: SILS_finfo
      INTEGER ( KIND = C_INT ) :: flag
      INTEGER ( KIND = C_INT ) :: more
      INTEGER ( KIND = C_INT ) :: maxfrt
      INTEGER ( KIND = C_INT ) :: nebdu
      INTEGER ( KIND = C_INT ) :: nrlbdu
      INTEGER ( KIND = C_INT ) :: nirbdu
      INTEGER ( KIND = C_INT ) :: nrltot
      INTEGER ( KIND = C_INT ) :: nirtot
      INTEGER ( KIND = C_INT ) :: nrlnec
      INTEGER ( KIND = C_INT ) :: nirnec
      INTEGER ( KIND = C_INT ) :: ncmpbr
      INTEGER ( KIND = C_INT ) :: ncmpbi
      INTEGER ( KIND = C_INT ) :: ntwo
      INTEGER ( KIND = C_INT ) :: neig
      INTEGER ( KIND = C_INT ) :: delay
      INTEGER ( KIND = C_INT ) :: signc
      INTEGER ( KIND = C_INT ) :: static
      INTEGER ( KIND = C_INT ) :: modstep
      INTEGER ( KIND = C_INT ) :: rank
      INTEGER ( KIND = C_INT ) :: stat
      INTEGER ( KIND = C_INT ) :: faulty
      INTEGER ( KIND = C_INT ) :: step
      REAL ( KIND = wp ) :: opsa
      REAL ( KIND = wp ) :: opse
      REAL ( KIND = wp ) :: opsb
      REAL ( KIND = wp ) :: maxchange
      REAL ( KIND = wp ) :: smin
      REAL ( KIND = wp ) :: smax
    END TYPE SILS_finfo

    TYPE, BIND( C ) :: SILS_sinfo
      INTEGER ( KIND = C_INT ) :: flag
      INTEGER ( KIND = C_INT ) :: stat
      REAL ( KIND = wp ) :: cond
      REAL ( KIND = wp ) :: cond2
      REAL ( KIND = wp ) :: berr
      REAL ( KIND = wp ) :: berr2
      REAL ( KIND = wp ) :: error
    END TYPE SILS_sinfo

!----------------------
!   P r o c e d u r e s
!----------------------

  CONTAINS

!  copy C control parameters to fortran

    SUBROUTINE copy_control_in( ccontrol, fcontrol, f_indexing )
    TYPE ( sils_control ), INTENT( IN ) :: ccontrol
    TYPE ( f_sils_control ), INTENT( OUT ) :: fcontrol
    LOGICAL, optional, INTENT( OUT ) :: f_indexing

    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) f_indexing = ccontrol%f_indexing

    ! Integers
    fcontrol%ICNTL = ccontrol%ICNTL
    fcontrol%lp = ccontrol%lp
    fcontrol%wp = ccontrol%wp
    fcontrol%mp = ccontrol%mp
    fcontrol%sp = ccontrol%sp
    fcontrol%ldiag = ccontrol%ldiag
    fcontrol%la = ccontrol%la
    fcontrol%liw = ccontrol%liw
    fcontrol%maxla = ccontrol%maxla
    fcontrol%maxliw = ccontrol%maxliw
    fcontrol%pivoting = ccontrol%pivoting
    fcontrol%nemin = ccontrol%nemin
    fcontrol%factorblocking = ccontrol%factorblocking
    fcontrol%solveblocking = ccontrol%solveblocking
    fcontrol%thresh = ccontrol%thresh
    fcontrol%ordering = ccontrol%ordering
    fcontrol%scaling = ccontrol%scaling

    ! Reals
    fcontrol%CNTL = ccontrol%CNTL
    fcontrol%multiplier = ccontrol%multiplier
    fcontrol%reduce = ccontrol%reduce
    fcontrol%u = ccontrol%u
    fcontrol%static_tolerance = ccontrol%static_tolerance
    fcontrol%static_level = ccontrol%static_level
    fcontrol%tolerance = ccontrol%tolerance
    fcontrol%convergence = ccontrol%convergence
    RETURN

    END SUBROUTINE copy_control_in

!  copy fortran control parameters to C

    SUBROUTINE copy_control_out( fcontrol, ccontrol, f_indexing )
    TYPE ( f_sils_control ), INTENT( IN ) :: fcontrol
    TYPE ( sils_control ), INTENT( OUT ) :: ccontrol
    LOGICAL, OPTIONAL, INTENT( IN ) :: f_indexing

    ! C or Fortran sparse matrix indexing
    IF ( PRESENT( f_indexing ) ) ccontrol%f_indexing = f_indexing

    ! Integers
    ccontrol%ICNTL = fcontrol%ICNTL
    ccontrol%lp = fcontrol%lp
    ccontrol%wp = fcontrol%wp
    ccontrol%mp = fcontrol%mp
    ccontrol%sp = fcontrol%sp
    ccontrol%ldiag = fcontrol%ldiag
    ccontrol%la = fcontrol%la
    ccontrol%liw = fcontrol%liw
    ccontrol%maxla = fcontrol%maxla
    ccontrol%maxliw = fcontrol%maxliw
    ccontrol%pivoting = fcontrol%pivoting
    ccontrol%nemin = fcontrol%nemin
    ccontrol%factorblocking = fcontrol%factorblocking
    ccontrol%solveblocking = fcontrol%solveblocking
    ccontrol%thresh = fcontrol%thresh
    ccontrol%ordering = fcontrol%ordering
    ccontrol%scaling = fcontrol%scaling

    ! Reals
    ccontrol%CNTL = fcontrol%CNTL
    ccontrol%multiplier = fcontrol%multiplier
    ccontrol%reduce = fcontrol%reduce
    ccontrol%u = fcontrol%u
    ccontrol%static_tolerance = fcontrol%static_tolerance
    ccontrol%static_level = fcontrol%static_level
    ccontrol%tolerance = fcontrol%tolerance
    ccontrol%convergence = fcontrol%convergence
    RETURN

    END SUBROUTINE copy_control_out

!  copy C ainfo parameters to fortran

    SUBROUTINE copy_ainfo_in( cainfo, fainfo )
    TYPE ( sils_ainfo ), INTENT( IN ) :: cainfo
    TYPE ( f_sils_ainfo ), INTENT( OUT ) :: fainfo

    ! Integers
    fainfo%flag = cainfo%flag
    fainfo%more = cainfo%more
    fainfo%nsteps = cainfo%nsteps
    fainfo%nrltot = cainfo%nrltot
    fainfo%nirtot = cainfo%nirtot
    fainfo%nrlnec = cainfo%nrlnec
    fainfo%nirnec = cainfo%nirnec
    fainfo%nrladu = cainfo%nrladu
    fainfo%niradu = cainfo%niradu
    fainfo%ncmpa  = cainfo%ncmpa
    fainfo%oor = cainfo%oor
    fainfo%dup = cainfo%dup
    fainfo%maxfrt = cainfo%maxfrt
    fainfo%stat = cainfo%stat
    fainfo%faulty = cainfo%faulty

    ! Reals
    fainfo%opsa = cainfo%opsa
    fainfo%opse = cainfo%opse
    RETURN

    END SUBROUTINE copy_ainfo_in

!  copy fortran ainfo parameters to C

    SUBROUTINE copy_ainfo_out( fainfo, cainfo )
    TYPE ( f_sils_ainfo ), INTENT( IN ) :: fainfo
    TYPE ( sils_ainfo ), INTENT( OUT ) :: cainfo

    ! Integers
    cainfo%flag = fainfo%flag
    cainfo%more = fainfo%more
    cainfo%nsteps = fainfo%nsteps
    cainfo%nrltot = fainfo%nrltot
    cainfo%nirtot = fainfo%nirtot
    cainfo%nrlnec = fainfo%nrlnec
    cainfo%nirnec = fainfo%nirnec
    cainfo%nrladu = fainfo%nrladu
    cainfo%niradu = fainfo%niradu
    cainfo%ncmpa  = fainfo%ncmpa
    cainfo%oor = fainfo%oor
    cainfo%dup = fainfo%dup
    cainfo%maxfrt = fainfo%maxfrt
    cainfo%stat = fainfo%stat
    cainfo%faulty = fainfo%faulty

    ! Reals
    cainfo%opsa = fainfo%opsa
    cainfo%opse = fainfo%opse
    RETURN

    END SUBROUTINE copy_ainfo_out

!  copy C finfo parameters to fortran

    SUBROUTINE copy_finfo_in( cfinfo, ffinfo )
    TYPE ( sils_finfo ), INTENT( IN ) :: cfinfo
    TYPE ( f_sils_finfo ), INTENT( OUT ) :: ffinfo

    ! Integers
    ffinfo%flag = cfinfo%flag
    ffinfo%more = cfinfo%more
    ffinfo%maxfrt = cfinfo%maxfrt
    ffinfo%nebdu  = cfinfo%nebdu
    ffinfo%nrlbdu = cfinfo%nrlbdu
    ffinfo%nirbdu = cfinfo%nirbdu
    ffinfo%nrltot = cfinfo%nrltot
    ffinfo%nirtot = cfinfo%nirtot
    ffinfo%nrlnec = cfinfo%nrlnec
    ffinfo%nirnec = cfinfo%nirnec
    ffinfo%ncmpbr = cfinfo%ncmpbr
    ffinfo%ncmpbi = cfinfo%ncmpbi
    ffinfo%ntwo = cfinfo%ntwo
    ffinfo%neig = cfinfo%neig
    ffinfo%delay = cfinfo%delay
    ffinfo%signc = cfinfo%signc
    ffinfo%static = cfinfo%static
    ffinfo%modstep = cfinfo%modstep
    ffinfo%rank = cfinfo%rank
    ffinfo%stat = cfinfo%stat
    ffinfo%faulty = cfinfo%faulty
    ffinfo%step = cfinfo%step

    ! Reals
    ffinfo%opsa = cfinfo%opsa
    ffinfo%opse = cfinfo%opse
    ffinfo%opsb = cfinfo%opsb
    ffinfo%maxchange = cfinfo%maxchange
    ffinfo%smin = cfinfo%smin
    ffinfo%smax = cfinfo%smax
    RETURN

    END SUBROUTINE copy_finfo_in

!  copy fortran finfo parameters to C

    SUBROUTINE copy_finfo_out( ffinfo, cfinfo )
    TYPE ( f_sils_finfo ), INTENT( IN ) :: ffinfo
    TYPE ( sils_finfo ), INTENT( OUT ) :: cfinfo

    ! Integers
    cfinfo%flag = ffinfo%flag
    cfinfo%more = ffinfo%more
    cfinfo%maxfrt = ffinfo%maxfrt
    cfinfo%nebdu  = ffinfo%nebdu
    cfinfo%nrlbdu = ffinfo%nrlbdu
    cfinfo%nirbdu = ffinfo%nirbdu
    cfinfo%nrltot = ffinfo%nrltot
    cfinfo%nirtot = ffinfo%nirtot
    cfinfo%nrlnec = ffinfo%nrlnec
    cfinfo%nirnec = ffinfo%nirnec
    cfinfo%ncmpbr = ffinfo%ncmpbr
    cfinfo%ncmpbi = ffinfo%ncmpbi
    cfinfo%ntwo = ffinfo%ntwo
    cfinfo%neig = ffinfo%neig
    cfinfo%delay = ffinfo%delay
    cfinfo%signc = ffinfo%signc
    cfinfo%static = ffinfo%static
    cfinfo%modstep = ffinfo%modstep
    cfinfo%rank = ffinfo%rank
    cfinfo%stat = ffinfo%stat
    cfinfo%faulty = ffinfo%faulty
    cfinfo%step = ffinfo%step

    ! Reals
    cfinfo%opsa = ffinfo%opsa
    cfinfo%opse = ffinfo%opse
    cfinfo%opsb = ffinfo%opsb
    cfinfo%maxchange = ffinfo%maxchange
    cfinfo%smin = ffinfo%smin
    cfinfo%smax = ffinfo%smax
    RETURN

    END SUBROUTINE copy_finfo_out

!  copy C sinfo parameters to fortran

    SUBROUTINE copy_sinfo_in( csinfo, fsinfo )
    TYPE ( sils_sinfo ), INTENT( IN ) :: csinfo
    TYPE ( f_sils_sinfo ), INTENT( OUT ) :: fsinfo

    ! Integers
    fsinfo%flag = csinfo%flag
    fsinfo%stat = csinfo%stat

    ! Reals
    fsinfo%cond = csinfo%cond
    fsinfo%cond2 = csinfo%cond2
    fsinfo%berr = csinfo%berr
    fsinfo%berr2 = csinfo%berr2
    fsinfo%error = csinfo%error
    RETURN

    END SUBROUTINE copy_sinfo_in

!  copy fortran sinfo parameters to C

    SUBROUTINE copy_sinfo_out( fsinfo, csinfo )
    TYPE ( f_sils_sinfo ), INTENT( IN ) :: fsinfo
    TYPE ( sils_sinfo ), INTENT( OUT ) :: csinfo

    ! Integers
    csinfo%flag = fsinfo%flag
    csinfo%stat = fsinfo%stat

    ! Reals
    csinfo%cond = fsinfo%cond
    csinfo%cond2 = fsinfo%cond2
    csinfo%berr = fsinfo%berr
    csinfo%berr2 = fsinfo%berr2
    csinfo%error = fsinfo%error
    RETURN

    END SUBROUTINE copy_sinfo_out

  END MODULE GALAHAD_SILS_double_ciface

!  -------------------------------------
!  C interface to fortran sils_initialize
!  -------------------------------------

  SUBROUTINE sils_initialize( cdata, ccontrol ) BIND( C )
  USE GALAHAD_SILS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( OUT ) :: cdata ! data is a black-box
  TYPE ( sils_control ), INTENT( OUT ) :: ccontrol

!  local variables

  TYPE ( f_sils_full_data_type ), POINTER :: fdata
  TYPE ( f_sils_control ) :: fcontrol
  LOGICAL :: f_indexing

!  allocate fdata

  ALLOCATE( fdata ); cdata = C_LOC( fdata )

!  initialize required fortran types

  CALL f_sils_initialize( fdata, fcontrol )

!  C sparse matrix indexing by default

  f_indexing = .FALSE.
  fdata%f_indexing = f_indexing

!  copy control out

  CALL copy_control_out( fcontrol, ccontrol, f_indexing )
  RETURN

  END SUBROUTINE sils_initialize

!  ---------------------------------------
!  C interface to fortran sils_reset_control
!  ----------------------------------------

  SUBROUTINE sils_reset_control( ccontrol, cdata, status ) BIND( C )
  USE GALAHAD_SILS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status
  TYPE ( sils_control ), INTENT( INOUT ) :: ccontrol
  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata

!  local variables

  TYPE ( f_sils_control ) :: fcontrol
  TYPE ( f_sils_full_data_type ), POINTER :: fdata
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  is fortran-style 1-based indexing used?

  fdata%f_indexing = f_indexing

!  import the control parameters into the required structure

  CALL f_SILS_reset_control( fcontrol, fdata, status )
  RETURN

  END SUBROUTINE sils_reset_control

!  --------------------------------------
!  C interface to fortran sils_information
!  --------------------------------------

  SUBROUTINE sils_information( cdata, cainfo, cfinfo, csinfo, status ) BIND( C )
  USE GALAHAD_SILS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( sils_ainfo ), INTENT( INOUT ) :: cainfo
  TYPE ( sils_finfo ), INTENT( INOUT ) :: cfinfo
  TYPE ( sils_sinfo ), INTENT( INOUT ) :: csinfo
  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status

!  local variables

  TYPE ( f_sils_full_data_type ), pointer :: fdata
  TYPE ( f_sils_ainfo ) :: fainfo
  TYPE ( f_sils_finfo ) :: ffinfo
  TYPE ( f_sils_sinfo ) :: fsinfo

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  obtain SILS solution information

  CALL f_sils_information( fdata, fainfo, ffinfo, fsinfo, status )

!  copy infos out

  CALL copy_ainfo_out( fainfo, cainfo )
  CALL copy_finfo_out( ffinfo, cfinfo )
  CALL copy_sinfo_out( fsinfo, csinfo )
  RETURN

  END SUBROUTINE sils_information

!  ------------------------------------
!  C interface to fortran sils_finalize
!  ------------------------------------

  SUBROUTINE sils_finalize( cdata, ccontrol, status ) BIND( C )
  USE GALAHAD_SILS_double_ciface
  IMPLICIT NONE

!  dummy arguments

  TYPE ( C_PTR ), INTENT( INOUT ) :: cdata
  TYPE ( sils_control ), INTENT( IN ) :: ccontrol
  INTEGER ( KIND = C_INT ), INTENT( OUT ) :: status

!  local variables

  TYPE ( f_sils_full_data_type ), pointer :: fdata
  TYPE ( f_sils_control ) :: fcontrol
  LOGICAL :: f_indexing

!  copy control in

  CALL copy_control_in( ccontrol, fcontrol, f_indexing )

!  associate data pointer

  CALL C_F_POINTER( cdata, fdata )

!  deallocate workspace

  CALL f_sils_finalize( fdata, fcontrol, status )

!  deallocate data

  DEALLOCATE( fdata ); cdata = C_NULL_PTR
  RETURN

  END SUBROUTINE sils_finalize
