MODULE DEF

INTEGER, PARAMETER	:: POP_MAX=20,MAX_GEN=100,UNK=2,CROM_LEN=10,STR_LEN=20	!STR LEN= UNK*CHROM LENGTH
							                 !UNK= NO OF UNKNOWNS/VARIABLE	
REAL, PARAMETER :: PCROSS=0.8, PMUTE=1.0/20 	 !PMUTE=1/UNKNOWNS*STRING_LENGHT

TYPE CHROMOSOME
 INTEGER	:: CHROM(20)   !=STRING LENGTH	!CHROM TO HAVE THE GENOTYPE IN BINARY FORM
 INTEGER	:: INTEGERS(UNK)				!INTEGER() STORE INTERGER EQ.VALUE OF CHROM 
 REAL		:: UNKNOWN(UNK),FIT				!UNKNOWN() STORE DECIMAL EQ. VALUE OF CHROM EACH VAR
END TYPE CHROMOSOME

END MODULE DEF

!*******************************************************************************
PROGRAM GA
 USE DEF
 IMPLICIT NONE

 TYPE(CHROMOSOME)		:: POP_CURR(POP_MAX),POP_NEW(POP_MAX)
 TYPE(CHROMOSOME)		:: MATE1,MATE2,NEW_INDIVIDUALS(2),FITTEST,ELITE

 REAL 	 :: VAR_RANGE(UNK,2)	!VARIABLE RANGE DEFINED FOR 'UNK' NO OF VARIABLES E.G. X,Y,Z=3
 REAL	 :: FIT_MEAN,FIT_SUM,RND
 INTEGER :: GENERATION,I,J

PRINT*, 'ENTER THE MIN, MAX RANGE FOR',UNK, 'NO OF UNKNOWNS'
READ*, ((VAR_RANGE(I,J),J=1,2),I=1,UNK)							!OK

CALL INI_POP(POP_CURR)				!OK	!FOR INITIALIZING FIRST GENERATION
CALL FIND_INTEGER(POP_CURR)										!OK
CALL FIND_UNKNOWNS(POP_CURR)		!OK	!RETURNS THE VALUE OF VARIABLE IN DECIMAL FORM
CALL FIND_FITNESS(POP_CURR)			!OK	!CHECKING FOR THE FITNESS

 ELITE%FIT=10E20

CALL STATISTICS(POP_CURR)			!OK
PAUSE
 !CALL PRINT_GENERATION(POP_CURR)
!CALL SCALING()

CALL RANDOM_SEED()

DO GENERATION=2,MAX_GEN
  PRINT*, 'GENERATION NO=', GENERATION
  DO I=1,POP_MAX-1,2
    CALL SELECTION(MATE1,FIT_SUM)
    CALL SELECTION(MATE2,FIT_SUM)

    CALL RANDOM_NUMBER(RND)
    IF (RND<=PCROSS)THEN
      PRINT*, "CROSSOVER PERFORMED"
      CALL CROSSOVER(MATE1,MATE2,NEW_INDIVIDUALS)
      POP_NEW(I)=NEW_INDIVIDUALS(1)
      POP_NEW(I+1)=NEW_INDIVIDUALS(2)
      ELSE
      PRINT*, "NO CROSSOVER"
        POP_NEW(I)=MATE1
        POP_NEW(I+1)=MATE2
		!CALL N0_CROSSOVER(MATE1,MATE2,NEW_INDIVIDUAL)
    END IF
  END DO
  !----------------------------
  PRINT*, 'AFTER CROSSOVER OPERATION'
  DO J=1,POP_MAX
  PRINT*, J,'CHROM= '
  PRINT 100, POP_CURR(J)%CHROM,POP_CURR(J)%FIT 
  END DO
  100 FORMAT (20I2,F8.3)
  !---------------------------

  CALL MUTATION(POP_NEW)
  
  !----------------------------
  PRINT*, 'AFTER MUTAION OPERATION'
  DO J=1,POP_MAX
  PRINT*, J,'CHROM= '
  PRINT 100, POP_CURR(J)%CHROM,POP_CURR(J)%FIT 
  END DO
  !---------------------------
 
! CALL REPLACE						!*************NOTE TO EDIT***********
  
  CALL FIND_INTEGER(POP_NEW)
  CALL FIND_UNKNOWNS(POP_NEW)
  CALL FIND_FITNESS(POP_NEW)
  CALL STATISTICS(POP_NEW)
  CALL PRINT_GENERATION(POP_NEW)

  PAUSE
END DO

!  PRINT*, 'ELITE ONE IS', ELITE%UNKNOWN, ELITE%FIT

!***************************************************************  
CONTAINS
!*************************************************************
SUBROUTINE INI_POP(POP)
 IMPLICIT NONE
  REAL		 :: RND
  INTEGER 	 :: I,BIT
  TYPE(CHROMOSOME),INTENT(INOUT) :: POP(POP_MAX)

  CALL RANDOM_SEED()
  DO I=1,POP_MAX
    DO BIT=1,STR_LEN
      CALL RANDOM_NUMBER(RND)
      IF (RND>.5) THEN
        POP(I)%CHROM(BIT)=1
        ELSE
        POP(I)%CHROM(BIT)=0
      END IF
    END DO
  !----------------------------
  PRINT*, I,'CHROM= '
  PRINT 50, POP_CURR(I)%CHROM
  50 FORMAT (20I2)
  !---------------------------
  END DO
END SUBROUTINE INI_POP
!**************************************************************

 SUBROUTINE SELECTION(MATE,FIT_SUM)
 IMPLICIT NONE
 REAL,INTENT(IN)	:: FIT_SUM
 TYPE(CHROMOSOME) 	:: MATE
 INTEGER 	:: INDIVIDUAL
 REAL		:: SUM,RND,ROULETTE_WHEEL

 SUM=0
 INDIVIDUAL=0
 CALL RANDOM_SEED()
 CALL RANDOM_NUMBER(RND)
 ROULETTE_WHEEL=RND*FIT_SUM
! PRINT*, 'ROULETTE WHEEL SELECT= ',ROULETTE_WHEEL
 
 DO 
   INDIVIDUAL=INDIVIDUAL+1
   IF (INDIVIDUAL==POP_MAX )THEN
      MATE=POP_CURR(INDIVIDUAL)
   EXIT
   END IF   
   
   SUM=SUM+POP_CURR(INDIVIDUAL)%FIT
   IF(SUM>=ROULETTE_WHEEL) THEN
	 MATE=POP_CURR(INDIVIDUAL)
   END IF
 END DO 
 
 END SUBROUTINE SELECTION
 !*************************************************************

SUBROUTINE CROSSOVER(MATE1,MATE2,NEW_INDIVIDUALS)
 IMPLICIT NONE
 TYPE(CHROMOSOME),INTENT(INOUT)	:: MATE1, MATE2
 TYPE(CHROMOSOME),INTENT(INOUT)	:: NEW_INDIVIDUALS(2)
 
 INTEGER	::	CROSS_SITE,BIT
 REAL		::	RND
 
 CALL RANDOM_SEED()
 CALL RANDOM_NUMBER(RND)
 CROSS_SITE= INT(((STR_LEN-1)*RND)+1)
!PRINT*, 'CROSS SITE=' , CROSS_SITE

 DO BIT=1,CROSS_SITE
   NEW_INDIVIDUALS(1)%CHROM(BIT) = MATE1%CHROM(BIT)
   NEW_INDIVIDUALS(2)%CHROM(BIT) = MATE2%CHROM(BIT)
   END DO

 DO BIT=CROSS_SITE+1, STR_LEN
   NEW_INDIVIDUALS(1)%CHROM(BIT)=MATE2%CHROM(BIT)
   NEW_INDIVIDUALS(2)%CHROM(BIT)=MATE1%CHROM(BIT)
   END DO
 END SUBROUTINE CROSSOVER
 !**************************************************************

 !SUBROUTINE NOCROSSOVER(MATE1,MATE2,NEW_INDIVIDUAL)
 !END SUBROUTINE NOCROSSOVER
 !**************************************************************

 SUBROUTINE MUTATION(POP)
 IMPLICIT NONE
 INTEGER 	:: I,BIT
 REAL		:: RND
 TYPE(CHROMOSOME)	:: POP(POP_MAX)

 CALL RANDOM_SEED()
 
 DO I=1,POP_MAX
   DO BIT=1,STR_LEN
	 CALL RANDOM_NUMBER(RND)
     IF (RND<=PMUTE) THEN					!MUTATION OCCURS
       IF(POP_NEW(I)%CHROM(BIT)==1)THEN
 		 POP_NEW(I)%CHROM(BIT)=0
         ELSE
         POP_NEW(I)%CHROM(BIT)=1
         END IF
       END IF
     END DO
   END DO
 
 END SUBROUTINE MUTATION
 !***************************************************************

 SUBROUTINE FIND_UNKNOWNS(POP)
 IMPLICIT NONE
 TYPE(CHROMOSOME),INTENT(INOUT)	:: POP(POP_MAX)
 INTEGER ::	I,J
 REAL	::	R1, R2
 
 DO I=1,POP_MAX
   DO J=1,UNK
     R1=VAR_RANGE(J,1)
     R2=VAR_RANGE(J,2)
     POP(I)%UNKNOWN(J)= R1 + (R2-R1)* POP(I)%INTEGERS(J)/(2**CROM_LEN-1)
     END DO
   PRINT*, I,' UNKNOWN DEC. VAL= ',POP(I)%UNKNOWN
   END DO
 
 END SUBROUTINE FIND_UNKNOWNS
 !***************************************************************

SUBROUTINE FIND_INTEGER(POP)
 IMPLICIT NONE
 TYPE(CHROMOSOME),INTENT(INOUT)	:: POP(POP_MAX)
 INTEGER 		:: I,J,PWR(CROM_LEN),TEMP(CROM_LEN), LWR,UPR
 
 DO I=CROM_LEN,1,-1
 PWR(I)=2**(I-1)
 END DO

 DO I=1, POP_MAX
    DO J=1,UNK
      LWR=((J-1)*CROM_LEN+1)
      UPR=(J*CROM_LEN)
      TEMP=POP(I)%CHROM(LWR:UPR)
      TEMP=TEMP*PWR
      POP(I)%INTEGERS(J)= SUM(TEMP)
    END DO 
    PRINT*,I,' INTEGER VALUE OF CHROM= ',POP(I)%INTEGERS
 END DO 
    
 END SUBROUTINE FIND_INTEGER
!******************************************************************

SUBROUTINE FIND_FITNESS(POP)
IMPLICIT NONE

TYPE(CHROMOSOME),INTENT(INOUT)	:: POP(POP_MAX)
INTEGER	:: I
REAL	:: TEMP(UNK)
 
  DO I=1,POP_MAX
    TEMP= POP(I)%UNKNOWN**2
    POP(I)%FIT= SUM(TEMP)													!D'JONG func (GENERELIZED)
	!POP(I)%FIT=100*((POP(I)%UNKNOWN(1)-POP(I)%UNKNOWN(1)**2)**2)+(1-POP(I)%UNKNOWN(1))**2		!ROSENBROCK FUNCTION (NOT GENERELIZED)
    
	!PI=4*ATAN(1.)																		!RASGRIN FUNCTION (GENERELIZED)
	!POP(I)%FIT=10 + SUM(POP%UNKNOWN(I)**2)-10*COS(2*PI*POP%UNKNOWN(I))
    PRINT*, I,' FITNESS=', POP(I)%FIT
  END DO
END SUBROUTINE FIND_FITNESS
!*****************************************************************

SUBROUTINE STATISTICS(POP)
IMPLICIT NONE
TYPE(CHROMOSOME),INTENT(INOUT)	::	POP(POP_MAX)
REAL  	:: MAX_FIT
INTEGER	:: I

MAX_FIT=10e10
DO I=1,POP_MAX
  IF(POP(I)%FIT<MAX_FIT) THEN
    MAX_FIT=POP(I)%FIT
    FITTEST=POP(I)
    END IF
  END DO

IF(ELITE%FIT>FITTEST%FIT)THEN
  ELITE=FITTEST  
END IF

CALL ELITISM()
FIT_SUM=0

DO I=1,POP_MAX
FIT_SUM=FIT_SUM+(POP(I)%FIT)			!******CHECK THIS STEP**********
END DO 

FIT_MEAN=FIT_SUM/POP_MAX
 PRINT*, 'MAX FITNESS=',MAX_FIT
 PRINT*, 'SUM OF FITNESS = ', FIT_SUM
 PRINT*,'FITTEST INDIVIDUAL IS= ',FITTEST%UNKNOWN, FITTEST%FIT 
 
END SUBROUTINE STATISTICS
!********************************************************************

SUBROUTINE ELITISM()
IMPLICIT NONE
INTEGER	:: I
REAL	:: RND
CALL RANDOM_SEED()
CALL RANDOM_NUMBER(RND)

IF (FITTEST%FIT>ELITE%FIT)THEN
  I=INT(POP_MAX*RND+1)
  POP_NEW(I)=ELITE
  FITTEST=ELITE
  END IF
END SUBROUTINE ELITISM
!*****************************************************************

SUBROUTINE PRINT_GENERATION(POP)
IMPLICIT NONE
TYPE(CHROMOSOME)	:: POP(POP_MAX)
INTEGER 			::	I

OPEN(2900, FILE='OUTPUT.DAT')
WRITE(2900,*) 'GENERATION=',GENERATION, 'FITTEST=',FITTEST%UNKNOWN,'FITNESS=',FITTEST%FIT
WRITE(2900,10) 'INDIVIDUAL','CHROMOSOME','UNKNOWNS','FIT'
DO I=1,POP_MAX
  WRITE(2900,20)I, POP(I)%CHROM, POP(I)%UNKNOWN, POP(I)%FIT
END DO
10 FORMAT(A12,A20,A20,A10)
20 FORMAT(I12,20I1,2F10.3,F10.3)
END SUBROUTINE PRINT_GENERATION
!******************************************************************

END PROGRAM GA
