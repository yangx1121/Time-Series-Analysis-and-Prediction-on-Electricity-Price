/* import data */
proc import
	datafile='.../Electricitey Generation Data.csv'
	out=sasuser.electricity
	replace;
run;

DATA NEW;
SET sasuser.electricity;
TIME=_N_;
run;

/* plot the series */
proc sgplot data=NEW;
series y=price x=yearmonth;
run;

/* plot the seasonal box plot */
proc sort data=new;
by year month;
run;

proc format ;  
 value mn_name 1='January'
               2='February'
               3='March'
               4='April'
               5='May'
               6='June'
               7='July'
               8='August'
               9='September'
              10='October'
              11='November'
              12='December'
           other='Invalid';
run;

proc sort data=new;
   by month;
run;

proc boxplot data=new;
   plot price*month;
   format month mn_name.;
run;

/* Section 3*/

/* Exclude Hold-out Sample*/

DATA NEW2;
SET NEW;
if _n_>299 then delete;
run;


/* PRICE VS CPI */

/* Difference the series */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI;
RUN;

PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI(1);
RUN;

PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI(1);
ESTIMATE Q=(1)(12) METHOD=ULS;
RUN;

/* Check Cross Correlation */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI(1) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(CPI(1));
RUN;

/* Fit Model */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI(1) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) NLAG=48 CROSSCOR=(CPI(1));
ESTIMATE INPUT=(8$/ CPI) METHOD=ULS NOCONSTANT NOEST;
RUN;

/* Add Error Model */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=CPI(1) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(CPI(1));
ESTIMATE INPUT=(8$/ CPI) P=(12) METHOD=ULS NOCONSTANT NOEST;
RUN;

/* Forecast and assess with the hold-out sample */
PROC ARIMA DATA=NEW;
IDENTIFY VAR=CPI(1) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(CPI(1));
ESTIMATE INPUT=(8$/ CPI) P=(12) METHOD=ULS NOCONSTANT NOEST;
forecast back = 36 lead = 36 out = forecast1;
RUN;


/* PRICE VS GASIMPORTS */

/* Difference the series */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=GASIMPORTS;
RUN;

PROC ARIMA DATA=NEW2;
IDENTIFY VAR=GASIMPORTS(1 12) NLAG=60;
RUN;

PROC ARIMA DATA=NEW2;
IDENTIFY VAR=GASIMPORTS(1 12);
ESTIMATE Q=(1)(12) METHOD=ULS;
RUN;

/* Check Cross Correlation */
PROC ARIMA DATA=NEW2;
IDENTIFY VAR=GASIMPORTS(1 12) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(GASIMPORTS(1 12));
RUN;


/* Fit Model */
/*
PROC ARIMA DATA=NEW;
IDENTIFY VAR=GASIMPORTS(1 12) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(GASIMPORTS(1 12));
ESTIMATE INPUT=GASIMPORTS METHOD=ULS Q=(1)(12) NODF  NOCONSTANT OUTSTAT=stat2;
forecast back = 36 lead = 36 out = forecast2;
RUN;
*/

/* Add Error Model */
/*
PROC ARIMA DATA=NEW;
IDENTIFY VAR=GASIMPORTS(1 12) NOPRINT;
ESTIMATE Q=(1)(12) METHOD=ULS;
IDENTIFY VAR=PRICE(1 12) CROSSCOR=(GASIMPORTS(1 12));
ESTIMATE INPUT=GASIMPORTS METHOD=ULS Q=(1)(12) NOCONSTANT OUTSTAT=stat2;
RUN;
*/
