/*
________________________________________________________________________________________________________________________________________________
											*PROJECT : NEW WHEELS*
_______________________________________________________________________________________________________________________________________________
# PROBLEM STATEMENT:
NEW-WHEELS SALES HAVE BEEN DIPPING STEADILY IN THE PAST YEAR, AND DUE TO THE CRITICAL CUSTOMER FEEDBACK AND RATINGS ONLINE,
THERE HAS BEEN A DROP IN NEW CUSTOMERS EVERY QUARTER, WHICH IS CONCERNING TO THE BUSINESS.
THE CEO OF THE COMPANY NOW WANTS A QUARTERLY REPORT WITH ALL THE KEY METRICS SENT TO HIM SO HE CAN ASSESS THE HEALTH OF THE BUSINESS
AND MAKE THE NECESSARY DECISIONS.
________________________________________________________________________________________________________________________________________________
# OBJECTIVE:
THERE IS AN ARRAY OF QUESTIONS THAT ARE BEING ASKED AT THE LEADERSHIP LEVEL THAT NEEDS TO BE ANSWERED USING DATA. 
USE THE DATA TO ANSWER THE QUESTIONS POSED AND CREATE A QUARTERLY BUSINESS REPORT FOR THE CEO.
________________________________________________________________________________________________________________________________________________
# NEW WHEELS TABLES & DATA DICTIONARY

TABLE NAMES:
CUSTOMER_T
ORDER_T
PRODUCT_T
SHIPPER_T
-----------------------------------
SHIPPER_ID: UNIQUE ID OF THE SHIPPER    
SHIPPER_NAME: NAME OF THE SHIPPER
SHIPPER_CONTACT_DETAILS: CONTACT DETAIL OF THE SHIPPER
PRODUCT_ID: UNIQUE ID OF THE PRODUCT
VEHICLE_MAKER: VEHICLE MANUFACTURING COMPANY NAME
VEHICLE_MODEL: VEHICLE MODEL NAME
VEHICLE_COLOR: COLOR OF THE VEHICLE
VEHICLE_MODEL_YEAR: YEAR OF MANUFACTURING
VEHICLE_PRICE: PRICE OF THE VEHICLE
QUANTITY: ORDERED QUANTITY
CUSTOMER_ID: UNIQUE ID OF THE CUSTOMER
CUSTOMER_NAME: NAME OF THE CUSTOMER
GENDER: GENDER OF THE CUSTOMER
JOB_TITLE: JOB TITLE OF THE CUSTOMER
PHONE_NUMBER: CONTACT DETAIL OF THE CUSTOMER
EMAIL_ADDRESS: EMAIL ADDRESS OF THE CUSTOMER
CITY: RESIDING CITY OF THE CUSTOMER
COUNTRY: RESIDING COUNTRY OF THE CUSTOMER
STATE: RESIDING STATE OF THE CUSTOMER
CUSTOMER_ADDRESS: ADDRESS OF THE CUSTOMER
ORDER_DATE: DATE ON WHICH CUSTOMER ORDERED THE VEHICLE
ORDER_ID: UNIQUE ID OF THE ORDER
SHIP_DATE: SHIPMENT DATE
SHIP_MODE: SHIPPING MODE/CLASS
SHIPPING: SHIPPING WAYS
POSTAL_CODE: POSTAL CODE OF THE CUSTOMER
DISCOUNT: DISCOUNT GIVEN TO THE CUSTOMER FOR THE PARTICULAR ORDER BY CREDIT CARD IN PERCENTAGE
CREDIT_CARD_TYPE: CREDIT CARD TYPE
CREDIT_CARD_NUMBER: CREDIT CARD NUMBER
CUSTOMER_FEEDBACK: FEEDBACK OF THE CUSTOMER
QUARTER_NUMBER : QUARTER NUMBER
________________________________________________________________________________________________________________________________________________
*/

/* ======================= QUERY STARTS FROM HERE ========================*/

USE  NEW_WHEELS;  #CALLING DATABASE TO USE THE NEW_WHEELS SCHEMA CREATED HERE FOR THE CURRENT SESSION

SHOW TABLES;      # QUERY TO SHOW THE AVAILABLE TABLES IN THE DATABASE

#CHECKING EACH TABLE DESCRIPTION SUCH AS FIELDS, TYPE, NULL & KEYS
DESC CUSTOMER_T;  
DESC ORDER_T;		
DESC PRODUCT_T;
DESC SHIPPER_T;

 
/*-- QUESTIONS RELATED TO CUSTOMERS 
     [Q1] WHAT IS THE DISTRIBUTION OF CUSTOMERS ACROSS STATES?
     HINT: FOR EACH STATE, COUNT THE NUMBER OF CUSTOMERS.*/
     
SELECT 
    STATE, COUNT(CUSTOMER_NAME) AS TOTAL_CUSTOMERS #COUNT FUNCTION USED TO GET COUNT OF CUSTOMERS AGAIST EACH STATE 
FROM CUSTOMER_T
GROUP BY STATE
ORDER BY TOTAL_CUSTOMERS DESC;

-- _________________________________________________________________________________________________________________________________________

/* [Q2] WHAT IS THE AVERAGE RATING IN EACH QUARTER?
-- VERY BAD IS 1, BAD IS 2, OKAY IS 3, GOOD IS 4, VERY GOOD IS 5.

HINT: USE A COMMON TABLE EXPRESSION AND IN THAT CTE, ASSIGN NUMBERS TO THE DIFFERENT CUSTOMER RATINGS. 
      NOW AVERAGE THE FEEDBACK FOR EACH QUARTER. 

NOTE: FOR REFERENCE, REFER TO QUESTION NUMBER 4. WEEK-2: MLS_WEEK-2_GL-BEATS_SOLUTION-1.SQL. 
      YOU'LL GET AN OVERVIEW OF HOW TO USE COMMON TABLE EXPRESSIONS FROM THIS QUESTION.*/

WITH FEEDBACK_BUCKET AS							# WITH CTE IS USED HERE FOR TEMPORARY TABLE RESULTS
( SELECT 
	QUARTER_NUMBER,
CASE 											#CASE FUNCTION TO CHANGE TEXT RATING TO NUMERIC FOR AVERAGE RATING
	WHEN CUSTOMER_FEEDBACK='VERY GOOD' THEN 5
	WHEN CUSTOMER_FEEDBACK ='GOOD' THEN 4
	WHEN CUSTOMER_FEEDBACK ='OKAY' THEN 3
	WHEN CUSTOMER_FEEDBACK ='BAD' THEN 2
    ELSE 1
	END FEEDBACK_RATING
FROM ORDER_T
)

SELECT
	QUARTER_NUMBER, AVG(FEEDBACK_RATING) AS AVG_RATING
FROM FEEDBACK_BUCKET
GROUP BY QUARTER_NUMBER
ORDER BY 1;

-- _________________________________________________________________________________________________________________________________________

/* [Q3] ARE CUSTOMERS GETTING MORE DISSATISFIED OVER TIME?

HINT: NEED THE PERCENTAGE OF DIFFERENT TYPES OF CUSTOMER FEEDBACK IN EACH QUARTER. USE A COMMON TABLE EXPRESSION AND
	  DETERMINE THE NUMBER OF CUSTOMER FEEDBACK IN EACH CATEGORY AS WELL AS THE TOTAL NUMBER OF CUSTOMER FEEDBACK IN EACH QUARTER.
	  NOW USE THAT COMMON TABLE EXPRESSION TO FIND OUT THE PERCENTAGE OF DIFFERENT TYPES OF CUSTOMER FEEDBACK IN EACH QUARTER.
      EG: (TOTAL NUMBER OF VERY GOOD FEEDBACK/TOTAL CUSTOMER FEEDBACK)* 100 GIVES YOU THE PERCENTAGE OF VERY GOOD FEEDBACK.
      
NOTE: FOR REFERENCE, REFER TO QUESTION NUMBER 4. WEEK-2: MLS_WEEK-2_GL-BEATS_SOLUTION-1.SQL. 
      YOU'LL GET AN OVERVIEW OF HOW TO USE COMMON TABLE EXPRESSIONS FROM THIS QUESTION.*/
      
WITH CUST_FEEDBACK AS								# WITH CTE IS USED HERE FOR TEMPORARY TABLE RESULTS
(
	SELECT 
		QUARTER_NUMBER,
		SUM(CASE WHEN CUSTOMER_FEEDBACK = 'VERY GOOD' THEN 1 ELSE 0 END) AS VERY_GOOD,  
		SUM(CASE WHEN CUSTOMER_FEEDBACK = 'GOOD' THEN 1 ELSE 0 END) AS GOOD,
		SUM(CASE WHEN CUSTOMER_FEEDBACK = 'OKAY' THEN 1 ELSE 0 END) AS OKAY,
		SUM(CASE WHEN CUSTOMER_FEEDBACK = 'BAD' THEN 1 ELSE 0 END) AS BAD,
		SUM(CASE WHEN CUSTOMER_FEEDBACK = 'VERY BAD' THEN 1 ELSE 0 END) AS VERY_BAD,
		COUNT(CUSTOMER_FEEDBACK) AS TOTAL_FEEDBACK
	FROM ORDER_T
	GROUP BY 1
)
SELECT 
		QUARTER_NUMBER, TOTAL_FEEDBACK,
        (VERY_GOOD/TOTAL_FEEDBACK)*100 '%_VERY_GOOD',
        (GOOD/TOTAL_FEEDBACK)*100 '%_GOOD',
        (OKAY/TOTAL_FEEDBACK)*100 '%_OKAY',
        (BAD/TOTAL_FEEDBACK)*100 '%_BAD',
        (VERY_BAD/TOTAL_FEEDBACK)*100 '%_VERY_BAD'
FROM CUST_FEEDBACK
ORDER BY 1;

-- _________________________________________________________________________________________________________________________________________

/*[Q4] WHICH ARE THE TOP 5 VEHICLE MAKERS PREFERRED BY THE CUSTOMER.

HINT: FOR EACH VEHICLE MAKE WHAT IS THE COUNT OF THE CUSTOMERS.*/

SELECT
	VEHICLE_MAKER, COUNT(CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM ORDER_T AS A
        INNER JOIN PRODUCT_T AS B
			ON A.PRODUCT_ID = B.PRODUCT_ID
GROUP BY 1
ORDER BY TOTAL_CUSTOMERS DESC
LIMIT 5;


-- _________________________________________________________________________________________________________________________________________

/*[Q5] WHAT IS THE MOST PREFERRED VEHICLE MAKE IN EACH STATE?

HINT: USE THE WINDOW FUNCTION RANK() TO RANK BASED ON THE COUNT OF CUSTOMERS FOR EACH STATE AND VEHICLE MAKER. 
AFTER RANKING, TAKE THE VEHICLE MAKER WHOSE RANK IS 1.*/

SELECT
	STATE, VEHICLE_MAKER, NO_OF_CUST,VM_RANK
FROM (
		SELECT
		  STATE,
		  VEHICLE_MAKER,
		  COUNT(CUST.CUSTOMER_ID) NO_OF_CUST,
		  RANK() OVER (PARTITION BY STATE ORDER BY COUNT(CUSTOMER_ID) DESC) AS VM_RANK #RANK FUNCTION USED HERE TO GIVE A RANK 
FROM PRODUCT_T PRO 
	INNER JOIN ORDER_T ORD 							#INNER JOIN TO COMBINE TABLES- HERE 3 TABLES BEING COMBINED
	    ON PRO.PRODUCT_ID = ORD.PRODUCT_ID
	INNER JOIN CUSTOMER_T CUST
	    ON ORD.CUSTOMER_ID = CUST.CUSTOMER_ID
	GROUP BY 1,2) TBL
WHERE VM_RANK = 1;

-- _________________________________________________________________________________________________________________________________________

/*QUESTIONS RELATED TO REVENUE AND ORDERS 

-- [Q6] WHAT IS THE TREND OF NUMBER OF ORDERS BY QUARTERS?

HINT: COUNT THE NUMBER OF ORDERS FOR EACH QUARTER.*/

SELECT
	QUARTER_NUMBER, COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM ORDER_T
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER ASC;


-- _________________________________________________________________________________________________________________________________________

/* [Q7] WHAT IS THE QUARTER OVER QUARTER % CHANGE IN REVENUE? 

HINT: QUARTER OVER QUARTER PERCENTAGE CHANGE IN REVENUE MEANS WHAT IS THE CHANGE IN REVENUE FROM THE SUBSEQUENT QUARTER
	  TO THE PREVIOUS QUARTER IN PERCENTAGE.
      TO CALCULATE YOU NEED TO USE THE COMMON TABLE EXPRESSION TO FIND OUT THE SUM OF REVENUE FOR EACH QUARTER.
      THEN USE THAT CTE ALONG WITH THE LAG FUNCTION TO CALCULATE THE QOQ PERCENTAGE CHANGE IN REVENUE.
*/


WITH REVENEU AS
(
SELECT
	QUARTER_NUMBER, SUM(QUANTITY * (VEHICLE_PRICE - ((DISCOUNT/100)*VEHICLE_PRICE))) AS PAYABLE_AMOUNT  #CALCULATING THE PAYABLE AMOUNT POST DISCOUNT DEDUCTION
FROM ORDER_T
GROUP BY QUARTER_NUMBER
)

SELECT
	QUARTER_NUMBER, PAYABLE_AMOUNT,
	LAG(PAYABLE_AMOUNT) OVER (ORDER BY QUARTER_NUMBER) AS PREVIOUS_QUARTER,
	(PAYABLE_AMOUNT - LAG(PAYABLE_AMOUNT) OVER(ORDER BY QUARTER_NUMBER))/LAG(PAYABLE_AMOUNT) OVER(ORDER BY QUARTER_NUMBER) AS PERC_CHANGE
FROM REVENEU;


-- _________________________________________________________________________________________________________________________________________

/* [Q8] WHAT IS THE TREND OF REVENUE AND ORDERS BY QUARTERS?

HINT: FIND OUT THE SUM OF REVENUE AND COUNT THE NUMBER OF ORDERS FOR EACH QUARTER.*/

SELECT
	QUARTER_NUMBER, COUNT(ORDER_ID) AS TOTAL_ORDERS,
	SUM(QUANTITY * (VEHICLE_PRICE - ((DISCOUNT/100)*VEHICLE_PRICE))) AS REVENUE   #CALCULATING THE REVENUE 
FROM ORDER_T
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER ASC;

-- _________________________________________________________________________________________________________________________________________

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] WHAT IS THE AVERAGE DISCOUNT OFFERED FOR DIFFERENT TYPES OF CREDIT CARDS?

HINT: FIND OUT THE AVERAGE OF DISCOUNT FOR EACH CREDIT CARD TYPE.*/

SELECT
	CREDIT_CARD_TYPE,
    AVG(DISCOUNT) AS AVG_DISCOUNT
FROM ORDER_T AS A
        INNER JOIN CUSTOMER_T AS B
			ON A.CUSTOMER_ID = B.CUSTOMER_ID
GROUP BY CREDIT_CARD_TYPE
ORDER BY AVG_DISCOUNT DESC;
-- _________________________________________________________________________________________________________________________________________

/* [Q10] WHAT IS THE AVERAGE TIME TAKEN TO SHIP THE PLACED ORDERS FOR EACH QUARTERS?
	HINT: USE THE DATEIFF FUNCTION TO FIND THE DIFFERENCE BETWEEN THE SHIP DATE AND THE ORDER DATE.
*/

SELECT 
    QUARTER_NUMBER,
    AVG(DATEDIFF(SHIP_DATE, ORDER_DATE)) AS AVG_TIME		#DATEIFF FUNCTION CALCULATES THE DIFFRENCE OF DAYS BETWEEEN ORDER AND SHIP DATE
FROM ORDER_T
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER ASC;


/* ======================= END OF QUERY ========================*/


