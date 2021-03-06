!PROGRAM FOR THE SIMULATED ANNEALING

PROGRAM SA
IMPLICIT NONE
REAL		::	T,C,PROB,R
REAL		:: PNEW(2),PCURR(2),PBEST(2), FNEW,FCURR,FBEST, dF
INTEGER 	:: I,N,K
PARAMETER (N=20, C=.95)
T = INI_TEMP()
PNEW=NEW_POINT()		!NEW POINT
PCURR=PNEW			!CURRENT POINT

PBEST=PNEW			!BEST POINT
FBEST=F(PBEST(1),PBEST(2))

CALL RANDOM_SEED()

K=0    
DO WHILE(T>.1)
  FCURR=F(PCURR(1),PCURR(2))
  DO I=1,N
  	PNEW=V_POINT(PNEW(1),PNEW(2))
  	FNEW=F(PNEW(1),PNEW(2))
  	dF=FNEW-FCURR
  	IF (dF<=0) THEN
      PCURR=PNEW
      FCURR=FNEW
      IF (FCURR<FBEST) THEN 
        PBEST=FCURR
      	FBEST=FCURR
      END IF
  	ELSE						! WHEN dF>0
      PROB=exp(-dF/T)			!PROBABILITY 
      CALL RANDOM_NUMBER(R)
      IF (PROB>R) THEN
   	    PCURR=PNEW
      	FCURR=FNEW
      END IF
  	END IF
  END DO
  K=K+1   
  T=T*(C**K)
END DO

!****************************************************
CONTAINS
!****************************************************
FUNCTION F(X,Y)			!FUNCTION DEFINED HERE
IMPLICIT NONE
REAL	:: X,Y,F
F= X**2+ Y**2
END FUNCTION F
!------------------------------------------------
FUNCTION NEW_POINT()		!CREATES A NEW POINT
IMPLICIT NONE
REAL ::  a,b,c,d,R, NEW_POINT(2)
a=-10; b=10; c=-5 ;d=5
CALL RANDOM_SEED()
CALL RANDOM_NUMBER(R)
NEW_POINT(1)=a+ R*(b-a)
NEW_POINT(2)=c+ R*(d-c)
END FUNCTION NEW_POINT
!-----------------------------------------------
FUNCTION V_POINT(X,Y)	!VICINITY POINT
IMPLICIT NONE
REAL :: X,Y,V_POINT

END FUNCTION V_POINT
!-----------------------------------------------
FUNCTION INI_TEMP()		!FINDS THE INITIAL TEMP
IMPLICIT NONE
REAL	:: VAR(2),T0, T1,INI_TEMP
INTEGER :: I

VAR=NEW_POINT()
T0 = F(VAR(1),VAR(2))
DO I=1,20
  VAR=NEW_POINT()
  T1 = F(VAR(1),VAR(2))
  IF(T1>T0) THEN 
    T0=T1
  END IF
END DO
INI_TEMP=T0
END FUNCTION INI_TEMP

END PROGRAM SA