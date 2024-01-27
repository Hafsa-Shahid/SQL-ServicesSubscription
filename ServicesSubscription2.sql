-- Write a query to find all customers along with their billing information.

SELECT c.Customer_id , First_name , Last_name , Phone_number , bill_id , amount_due , payment_date , due_date
FROM customer c
INNER JOIN billing b                                    
ON c.customer_id = b.customer_id;

-- List all customers with their corresponding total due amounts from the billing table.

SELECT c.Last_name , c.First_name , sum(amount_due) as 'total amount due'
FROM customer c
INNER JOIN billing b
ON c.Customer_id = b.Customer_id
GROUP BY c.Customer_id;

-- Display service packages along with the number of subscriptions each has.

SELECT package_name , count(subscription_id) as 'no. of subscription'
FROM service_packages sp
INNER JOIN subscriptions s
ON sp.package_id = s.package_id
GROUP BY package_name , sp.package_id;

-- Write a query to list all customers and any feedback they have given, including customers who have not given feedback.

SELECT c.Customer_id , First_name , Last_name , Email , Address , Phone_number , Subscription_Date , feedback_id , feedback_text , service_impacted , rating
FROM customer c
LEFT JOIN feedback f
ON c.Customer_id = f.Customer_id;
 
-- Retrieve all customer and the package names of any subscriptions they might have.

SELECT c.Customer_id , First_name , Phone_number , s.subscription_id , sp.package_id , package_name
FROM customer c
LEFT JOIN subscriptions s
ON c.Customer_id = s.customer_id
LEFT JOIN service_packages sp
ON s.package_id = sp.package_id;

-- Find out which customer have never given feedback by left joining customer to feedback.

SELECT c.Customer_id , First_name , Address , Phone_number , f.feedback_id , feedback_text
FROM customer c
LEFT JOIN feedback f
ON c.Customer_id = f.customer_id
WHERE feedback_id IS NULL;

-- Write a query to list all feedback entries and the corresponding customer information, including feedback without a linked customer.

SELECT c.Customer_id , First_name ,Address , Phone_number , feedback_id , feedback_date , feedback_text 
FROM customer c
RIGHT JOIN feedback f
ON f.customer_id = c.Customer_id;

-- Show all feedback entries and the full names of the customer who gave them.

SELECT c.Customer_id , concat(c.First_name , ' ' , c.Last_name) as 'Full Name' , feedback_id , feedback_text , feedback_date , service_impacted , rating
FROM customer c
LEFT JOIN feedback f
ON c.Customer_id = f.customer_id;

-- List all customers, including those without a linked service usage.

SELECT *
FROM customer c
LEFT JOIN service_usage su
ON c.customer_ID = su.customer_id;

-- Write a query to list all customer, their subscription packages, and usage data.

SELECT c.Customer_id , c.First_name , c.Last_name , sp.package_name , su.data_used , su.minutes_used 
FROM customer c
JOIN subscriptions s
ON c.Customer_id = s.Customer_id
JOIN service_packages sp
ON s.package_id = sp.package_id
JOIN service_usage su
ON c.customer_ID = su.customer_id; 

-- Write a query to find the service package with the highest monthly rate.

SELECT * 
FROM service_packages
WHERE monthly_rate = (SELECT MAX(monthly_rate) FROM service_packages);

-- Find the customer with the smallest total amount of data used in service_usage.

SELECT * 
FROM service_usage
WHERE data_used = (SELECT MIN(data_used) FROM service_usage);

-- Identify the service package with the lowest monthly rate.

SELECT *
FROM service_packages
WHERE monthly_rate = (SELECT MIN(monthly_rate) FROM service_packages);

-- Find customers whose subscription lengths are longer than the average subscription length of all customers.

SELECT distinct c.Customer_id , concat(First_name , ' ' , Last_name) as 'Full Name' , Subscription_Date , subscription_id , package_id 
FROM customer c
JOIN subscriptions s
ON c.Customer_id = s.Customer_id
WHERE datediff(end_date , start_date) > ALL (SELECT avg(datediff(end_date , start_date))FROM subscriptions GROUP BY Customer_id);

-- Write a query to find customers whose last interaction date is more recent than the average last interaction date.

SELECT *
FROM customer
WHERE (Customer_id , last_interaction_date) in 
											(SELECT Customer_id , last_interaction_date
											 FROM customer 
                                             WHERE last_interaction_date > (SELECT avg(last_interaction_date) FROM customer));

-- Select all feedback entries that match the worst rating given for any service type.

SELECT feedback_id , service_impacted , rating
FROM feedback
WHERE (service_impacted , rating) in 
                                     (SELECT service_impacted , min(rating)
                                      FROM feedback
                                      GROUP BY service_impacted);

-- List all packages and information for packages where monthly rates are less than the maximum minutes used for each service type.

SELECT *                                 
FROM service_packages sp
WHERE monthly_rate < (SELECT max(minutes_used) FROM service_usage su GROUP BY service_type HAVING sp.service_type = su.service_type); 

-- Find customers who have at least one billing record with an amount due that is greater than their average billing amount.

SELECT *    
FROM billing  
WHERE amount_due > (SELECT avg(amount_due) FROM billing);       

-- Write a query to show each customer's name and the number of subscriptions they have.

SELECT First_name , Last_name , (SELECT count(*) FROM subscriptions s WHERE s.customer_id = c.customer_id )AS 'number of subscriptions'   
FROM customer c;
