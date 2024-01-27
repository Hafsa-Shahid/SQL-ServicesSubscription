SELECT count(*) 
FROM service_packages;

SELECT * 
FROM service_packages;

            -- Find the average monthly rate for each service type in service_packages.
            
Select service_type , avg(monthly_rate) as Avg_monthly_rate
from service_packages
group by service_type;

			-- the same query with rounding off values.
            
SELECT service_type, ROUND(AVG(monthly_rate),2) AS Avg_monthly_rate
FROM service_packages
GROUP BY service_type;

	       	-- Identify the customer who has used the most data in a single service_usage record.
            
SELECT customer_id , max(data_used) AS max_data_used
FROM service_usage
GROUP BY customer_id
ORDER BY max_data_used desc
LIMIT 1;
 
			-- Calculate the total minutes used by all customers for mobile services.
            
SELECT sum(minutes_used) AS total_minutes_used        
FROM service_usage
WHERE service_type = 'Mobile';    

			-- List the total number of feedback entries for each rating level.
SELECT *
FROM feedback;

SELECT rating, count(*) as total_feedback_ratings
FROM feedback
GROUP BY rating;

			-- Show the total amount due by each customer, but only for those who have a total amount greater than $100.
            
SELECT Customer_id , sum(amount_due) AS total_amount_due
FROM billing
GROUP BY Customer_id
HAVING total_amount_due > 100; 

           -- Group feedback by service impacted and rating to count the number of feedback entries.
           
SELECT service_impacted, rating, count(*) AS feedback_count
FROM feedback
GROUP BY service_impacted , rating   
ORDER BY service_impacted , rating;  

  
SET SQL_SAFE_UPDATES = 0;

UPDATE feedback
SET rating = NULL
WHERE rating = '';

UPDATE feedback
SET service_impacted = null
WHERE service_impacted = '';

            -- Calculate the total data and minutes used per customer, per service type.
            
SELECT *
FROM service_usage;
        
SELECT customer_id , service_type , sum(data_used) AS total_data_used , sum(minutes_used) AS total_minutes_used
FROM service_usage
GROUP BY service_type , customer_id;

-- CASE STATEMENTS AND CONDITIONAL EXPRESSIONS

        -- Categorize customers based on their subscription date: ‘New’ for those subscribed after 2023-01-01, ‘Old’ for all others.
        
SELECT *
FROM customer;

SELECT *,
CASE
    WHEN Subscription_Date > '2023-01-01' THEN 'New'                 
    ELSE 'Old'
END as customer_type
FROM customer;

	  -- Provide a summary of each customer’s billing status, showing ‘Paid’ if the payment_date is not null, and ‘Unpaid’ otherwise.
      
SELECT *
FROM billing;

UPDATE billing
SET payment_date = null
WHERE payment_date = ''; 

SELECT *,
CASE 
    WHEN payment_date is not null THEN 'Paid'
    ELSE 'Unpaid'
END as billing_status
FROM billing
ORDER BY billing_status desc;

        -- In service_usage, label data usage as ‘High’ if above the average usage, ‘Low’ if below.
    
SELECT *
FROM service_usage;
   
SELECT *,
CASE 
     WHEN data_used > (select avg(data_used) from service_usage) THEN 'High'
     ELSE 'Low'
END as usage_level
FROM service_usage;

        -- For each feedback given, categorize the service_impacted into ‘Digital’ for ‘streaming’ or ‘broadband’ and ‘Voice’ for ‘mobile’.

SELECT * 
FROM feedback;        
        
SELECT *,                                  -- this query can be written in multiple ways
CASE
     WHEN service_impacted = 'Broadband' OR service_impacted ='Streaming' THEN 'Digital'
     WHEN service_impacted = 'Mobile' THEN 'Voice'
END as service_category
FROM feedback;     

-- Another way
SELECT *,                                
CASE  service_impacted
     WHEN 'Broadband' THEN 'Digital'
     WHEN 'Streaming' THEN 'Digital'
     WHEN 'Mobile' THEN 'Voice'
END as service_category
FROM feedback;    

        -- Update the discounts_applied field in billing to 10% of amount_due for bills with a payment_date past the due_date, otherwise set it to 5%.

UPDATE billing
SET discounts_applied = 
CASE 
    WHEN payment_date > due_date THEN amount_due*0.1 
    ELSE amount_due*0.5
END;    

SELECT * 
FROM billing;

		-- Classify each customer as ‘High Value’ if they have a total amount due greater than $500, or ‘Standard Value’ if not.

SELECT Customer_id,
   IF (sum(amount_due) > 500 , 'High Value' , 'Standard Value') AS value_category
FROM billing
GROUP BY Customer_id;

         -- Mark each feedback entry as ‘Urgent’ if the rating is 1 and the feedback text includes ‘outage’ or ‘down’.
         
SELECT *,
CASE 
      WHEN rating = 1 AND (LOWER(feedback_text) LIKE '%outage%' OR LOWER(feedback_text) LIKE '%down%') THEN 'Urgent'
      ELSE 'Normal'
END as feedback_status      
FROM feedback
ORDER BY feedback_status;

         -- In billing, create a flag for each bill that is ‘Late’ if the payment_date is after the due_date, ‘On-Time’ if it’s the same, and ‘Early’ if before.         
                      
SELECT *
FROM billing;

SELECT *,
CASE 
    WHEN payment_date > due_date THEN 'Late'
    WHEN payment_date = due_date THEN 'On-Time'
    WHEN payment_date < due_date THEN 'Early'
END as payment_status
FROM billing;    