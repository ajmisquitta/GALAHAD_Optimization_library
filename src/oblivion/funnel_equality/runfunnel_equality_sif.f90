! THIS VERSION: GALAHAD 2.1 - 17/10/2007 AT 12:00 GMT.

!-*-*-*-*-*-*-  G A L A H A D   R U N F U N N E L _ S I F  *-*-*-*-*-*-*-*-

!  Nick Gould, Dominique Orban and Philippe Toint, for GALAHAD productions
!  Copyright reserved
!  October 17th 2007

   PROGRAM RUNFUNNEL_SIF
   USE GALAHAD_USEFUNNELE_double

!  Main program for the SIF interface to FUNNEL, a filter trust-funnel
!  algorithm for nonlinear programming

!  Problem insif characteristics

   INTEGER, PARAMETER :: errout = 6
   INTEGER, PARAMETER :: insif = 55
   CHARACTER ( LEN = 16 ) :: prbdat = 'OUTSDIF.d'
   INTEGER :: iostat

!  Open the data input file

   OPEN( insif, FILE = prbdat, FORM = 'FORMATTED', STATUS = 'OLD',             &
         IOSTAT = iostat )
   IF ( iostat > 0 ) THEN
     WRITE( errout,                                                            &
       "( ' ERROR: could not open file OUTSDIF.d on unit ', I2 )" ) insif
     STOP
   END IF
   REWIND insif

!  Call the SIF interface

   CALL USE_FUNNEL( insif )

!  Close the data input file 

   CLOSE( insif  )
   STOP

!  End of RUNFUNNEL_SIF

   END PROGRAM RUNFUNNEL_SIF
