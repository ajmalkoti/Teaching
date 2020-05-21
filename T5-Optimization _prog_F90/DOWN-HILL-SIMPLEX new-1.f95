!FOLLOWING IS THE DOWNHILL SIMPLEX METHOD
!ALGO:
!1. START WITH THE SIMPLEX =DIM+1, AND FIND CENTROID OF ALL POINTS EXCLUDING WORST POINT 
!2. TAKE THE REFLECTION(R) OF THE WORST POINT(S(3,:)) AND CHECK THE FUNCTION VALUE
!	I. IF THE F(R) IS LESS THAN MIN 
!			THEN ASSIGN THE REFLECTED POIN AS NEW WORST POINT
!	II. IF F(R) IS EVEN LESS THAN BEST POINT THEN EXPAND (E) IN  THAT DIRECTION FURTHER
!		A. IF E IS BETTER THAN R THEN ASSIGN THE E AS THE BEST POINT (S(1,:))
!		B. IF R IS BETTER THAN E THEN ASSIGN THE R AS THE BEST POINT (S(1,:))
!	III. UF THE F(R) IS GREATER THAN THE F(S(3,:)) THEN
!		A. IF F(R)>F(S(2,:)) THEN CHECK FOR THE CONTRACTION(C).   
!				IF F(C) IS LESS THAN F(R) THEN ASSIGN C AS THE WORST POINT
!				IF F(C) GREATER THAN F(R) THEN SHRINK THE SIMPLEX TOWARDS THE BEST POINT			

!CONTAINED SUBROUTINES/FUNCTION ARE: 
!SUB:DOWN_HILL, SORT_PTS,CENTROID; FUNC: F

PROGRAM SIMPLEX
REAL  	:: S(3,2),FTOL

PRINT *, 'ENTER THE POINTS'
PRINT *, 'ENTER THE POINT 1'
READ *, S(1,1),S(1,2)
PRINT *, 'ENTER THE POINT 2'
READ *, S(2,1),S(2,2)
PRINT *, 'ENTER THE POINTS 3'
READ *, S(3,1),S(3,2)

!FTOL=EPSILON(1.)
FTOL=1.0E-5

CALL DOWN_HILL(S,FTOL)

!*******************************************************************************
CONTAINS
!***********************************

FUNCTION F(P)
IMPLICIT NONE
REAL :: X,Y,F,P(2),PI
PI=4*ATAN(1.)
X=P(1)
Y=P(2)
!F= X**2 + Y**2
!F=100*(Y-X**2)**2 + (1-X)**2
F=10+(X**2-10*COS(2*PI*X)) + (Y**2 + 10*COS(2*PI*Y))

END FUNCTION F
!***************************************

SUBROUTINE DOWN_HILL(S,FTOL)
REAL, INTENT(INOUT)	:: S(3,2), FTOL
REAL, DIMENSION(2)	:: M,R, E, C
REAL				:: FR, FE, FC, FUN(3), ALPHA=1., GAMMA=2., RHO=.5, SIGMA=.5, RTOL, TINY=1.E-5
INTEGER 			:: I,J

OPEN(10, FILE="data5_33.DAT")

  DO I=1,1000

	FUN(1)=F(S(1,:))
	FUN(2)=F(S(2,:))
	FUN(3)=F(S(3,:))
  	CALL SORT_PTS(S,FUN)															!STEP 1: SORT THE POINTS	
	WRITE (10,*)((S(J,K),K=1,2),J=1,3), FUN(1)
    RTOL= 2.0*(ABS(FUN(3))-ABS(FUN(1)))/(ABS(FUN(1))+ABS(FUN(3)) + TINY )
    PRINT *, 'RTOL= ',RTOL
    IF(RTOL<FTOL) EXIT
    
    PRINT *, 'ITERATION NO=', I
    PRINT*, 'The SIMPLEX IS: '
    DO J=1,3
	  PRINT *, S(J,1),S(J,2)
    END DO

  	CALL CENTROID(M,S)					!2 CALCULATE THE CENTROID = M
  	PRINT *, 'CENTROID',M

  	R= M + ALPHA*(M-S(3,:))			!3 REFLECTION OF THE WORST POINT P3 OVER M	! RETURNS REFLECTED COORDINATE 'R'
  	FR=F(R)
  	IF (FR<FUN(1))THEN
 		E= R + GAMMA*(R-M)				! RETURNS EXPANDED COORDINATE 'E'
    	FE=F(E)
   		IF(FE<F(R)) THEN
      		S(3,:)=E
      		FUN(3)=FE
    	ELSE 
       		S(3,:)=R
       		FUN(3)=FR
    	END IF
  	ELSEIF(FR>FUN(1)) THEN
		IF(FR<FUN(2))THEN		!5A
        	S(3,:)=R
            FUN(3)=FR
       	ELSEIF (FR>FUN(3)) THEN		!5B
   	  		C= M + RHO*(S(3,:)- M)		!RETRURNS CONTRACTED POINT C
            FC=F(C)
      		IF (FC<FUN(3))THEN
        		S(3,:)=C
            ELSEIF(FC>FUN(3))THEN
		      	S(2,:)=S(1,:)+SIGMA*(S(2,:)-S(1,:))		! SHRINK TOWARDS THE BEST SOLUTION CANDIDATE 
		      	S(3,:)=S(1,:)+SIGMA*(S(3,:)-S(1,:))            	
      		END IF
        ELSEIF (FR<FUN(3))THEN
			S(3,:)=R
            FUN(3)=FR
        END IF
    END IF
END DO

WRITE (10,*)((S(J,K),K=1,2),J=1,3)
PRINT *,'OBTAINED MIN POINT IS=', S(1,:)
CLOSE(10)
END SUBROUTINE DOWN_HILL
!**********************************

SUBROUTINE SORT_PTS(S,FUN)
REAL 					:: TEMP(2),FTEMP
REAL , INTENT(INOUT)	:: S(3,2), FUN(3)
INTEGER 			:: I,J,N=3
DO I=1,N-1
  DO J=1,N-1
    IF (FUN(J)>FUN(J+1))THEN
      TEMP=S(J,:)
      S(J,:)=S(J+1,:)
      S(J+1,:)=TEMP 

      FTEMP=FUN(J)
      FUN(J)=FUN(J+1)
      FUN(J+1)=FTEMP
	END IF
  END DO
END DO

END SUBROUTINE SORT_PTS
!***********************************

SUBROUTINE CENTROID(C,S)
REAL, INTENT(OUT)	:: C(2)
REAL, INTENT(IN)	:: S(3,2)
C(1)=SUM(S(1:2,1))/2
C(2)=SUM(S(1:2,2))/2
END SUBROUTINE CENTROID
!***********************************

END PROGRAM SIMPLEX