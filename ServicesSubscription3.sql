-- View next session’s data usage for each customer.

SELECT *,
LEAD (data_used) OVER (PARTITION BY Customer_id ORDER BY usage_date) as 'next use'
FROM service_usage;

-- Calculate the difference in data usage between the current and next session.

SELECT * ,
data_used - (LEAD (data_used) OVER (PARTITION BY Customer_id ORDER BY usage_date)) as 'difference b/w current and next'
FROM service_usage;

-- Review Previous Session's Data Usage.

SELECT *,
LAG (data_used) OVER (PARTITION BY Customer_id ORDER BY usage_date DESC) as 'previous use'
FROM service_usage;

-- Interval Between Service Usage Sessions.

SELECT *,
datediff(usage_date , LAG(usage_date) OVER (PARTITION BY customer_id ORDER BY usage_date)) as 'time interval'
FROM service_usage;

-- Rank customers according to the number of services they have subscribed to.

SELECT customer_id , count(subscription_id) as 'no. of subscriptions' ,  
RANK() OVER (ORDER BY count(subscription_id) desc) as 'ranking based on subscriptions'
FROM subscriptions
GROUP BY customer_id;

-- Rank customers based on the total sum of their rating they have ever given.              

SELECT customer_id , sum(rating) as 'sum of ratings' ,  
RANK() OVER (ORDER BY sum(rating) desc) as 'ranking on sum of ratings'
FROM feedback
GROUP BY customer_id;

-- Find the number of feedback entries for each service type for each customer.

SELECT customer_id , service_impacted , 
count(feedback_id) OVER (PARTITION BY customer_id,service_impacted) as 'no. of feedbacks'
FROM feedback;

-- Calculate the Average data_used for each service_type for each customer.

SELECT * ,                                     -- this was done in another way in the class.
avg(data_used) OVER (PARTITION BY customer_id , service_type) as 'average data used'
FROM service_usage;

-- Find customers who consistently use more data than average.

WITH average_data_usage as (SELECT avg(data_used) as avg_data_use FROM service_usage)
SELECT customer_id 
FROM service_usage su , average_data_usage adu
WHERE su.data_used > adu.avg_data_use
GROUP BY customer_id;

-- Find out  the most recent feedback from each customer.

WITH LatestFeedback as (SELECT customer_id , max(feedback_date) as latest_feedback_date FROM feedback GROUP BY customer_id)
SELECT f.customer_id , feedback_text , latest_feedback_date
FROM feedback f
JOIN LatestFeedback lf
ON f.customer_id = lf.customer_id AND f.feedback_date = lf.latest_feedback_date;

-- Find customer name and id for all customers with length of subscription more than 4000 days.

WITH subscription_length as (SELECT customer_id , datediff(end_date , start_date) as sublength FROM subscriptions)
SELECT c.Customer_id , c.First_name , c.Last_name , sublength
FROM customer c
INNER JOIN subscription_length sl
ON c.Customer_id = sl.customer_id
WHERE sublength > 4000;