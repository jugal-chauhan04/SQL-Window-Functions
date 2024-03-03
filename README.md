# SQL-Window-Functions
 Exploring real world problems for advanced data insights with SQL queries using powerful window functions.  

## What are Window Functions ?  

Window functions in SQL are analytical tools that compute values across a specific set of rows related to the current row in a query result. Unlike traditional aggregate functions that operate on the entire result set, window functions focus on a defined window of rows determined by an OVER clause. This window can be customized based on criteria such as partitioning and ordering.

Common window functions include:

1. **ROW_NUMBER()**: Assigns a unique number to each row within a partition.
2. **RANK()**: Assigns a rank to each row within a partition, with tied values receiving the same rank and leaving gaps.
3. **DENSE_RANK()**: Similar to RANK(), but without gaps in ranking for tied values.
4. **SUM(), AVG(), COUNT()**: Aggregates values over a specified window.
5. **LEAD() and LAG()**: Access data from subsequent or preceding rows within the window.
6. **FIRST_VALUE() and LAST_VALUE()**: Retrieve the first or last value within the window.

These functions enhance the analytical capabilities of SQL queries, enabling more sophisticated and adaptable data analysis, particularly in scenarios involving time series data, ranking, and cumulative calculations.  

## Real World Applications  

We are going to use real world application of window functions, for that will we solve four interview questions for companies like Google, Airbnb, Amazon, and Yelp which will showcase how and in what scenario window functions are utilized.  

## 1. Email Activity Rank - Google.  

The key to solving any Sql problem, or any coding problem, is to understand the required application. Let's read the problem statement to understand the requirement.  

> Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. The user with the highest number of emails sent will have a rank of 1, and so on. Output the user, total emails, and their activity rank. Order records by the total emails in descending order. Sort users with the same number of emails in alphabetical order.
In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails. For tie breaker use alphabetical order of the user usernames.

The table name and schema is as shown below  

**google_gmail_emails**  

| Column | Datatype |
| --------- |:--------:|
| id        | int      |
| from_user | varchar  |
| to_user   | varchar  |
| day       |  int     |  

Now, let's break down the problem into sub-problems for better understanding  

1. email activity rank - **COUNT of total emails sent**
2. user having highest emails sent will have **rank of 1**
3. Output columns
   * user (from user)
   * total emails (COUNT)
   * activity rank (ranking)
4. Sort by alphabetical for tie breaker
   * rank needs to be **unique**

Here, we understand that we need to create two new columns in output - one is the aggregate function (either count or sum) and the other that assigns a rank. By this detail it is clear as a day that we need to use window function, but which one? We see that we need to obtain a unique rank, ROW_NUMBER() is the function that assigns a unique value to the partition, hence we will use that. The overall query will constructed using following plan:  

1. Find the count of total emails sent.
2. Use ROW_NUMBER() to assign a rank based on the count, sorted in descending order to prioritize users who sent the most emails.
3. Implement another sorting based on ascending alphabetical order of usernames as a tiebreaker.
4. Finally, group the users by their usernames to obtain the total count and rank of each user's sent emails

The PostgreSQL solution is given below.  

```sql
SELECT
   from_user, 
   COUNT(from_user) AS total_email,  
   ROW_NUMBER() OVER(ORDER BY COUNT(from_user) desc, from_user asc) as activity_rank  
FROM 
   google_gmail_emails
GROUP BY 
   from_user; 
``` 
This will produce the desired result, hence giving a basic demonstration of ROW_NUMBER() window function. Now let's explore more window functions.  

## 2. Most Active Guests - Airbnb  

Now let's see an example of how to differentiate between RANK() and DENSE_RANK() functions. The problem statement and table schema is given below.  

> Rank guests based on the total number of messages they've exchanged with any of the hosts. Guests with the same number of messages as other guests should have the same rank. Do not skip rankings if the preceding rankings are identical.
Output the rank, guest id, and number of total messages they've sent. Order by the highest number of total messages first.

**airbnb_contacts**

| Column | Type |
| ------ |:----:|
| id_guest | varchar |
| id_host | varchar |
| id_listing | varchar |
| ts_contact_at | datetime |
| ts_reply_at | datetime |
| ts_accepted_at | datetime |
| ts_booking_at | datetime |
| ds_checkin | datetime |
| ds_checkout | datetime |
| n_guests | int |
| n_messages | int |  

Again, break down the problem into smaller parts:  
1. Use an aggregate function to find total number of messages exchanged and provide rank based on that.
2. Same total = Same rank.
3. Do not skip ranks.
4. Output columns - rank, guest_id, total messages
5. Sort in desc order of total messages.

Similarly, build a query plan based on this. The important details that helps us recognize which window function to use are points 2 and 3. The RANK() functions assigns the same rank for same values, but skips rank. The DENSE_RANK() function, instead, does the same thing as RANK() except it does not leave gaps in ranking. Hence we understand that we have to use DENSE_RANK() function here.  

Query Plan:  
1. Use DENSE_RANK() over sum of messages sent and sort in desc.
2. use SUM() to find total messages
3. Group by guest_id
 
PostgreSQL Query:  

```sql
SELECT 
    DENSE_RANK() OVER(ORDER BY sum(n_messages) DESC) as ranking, 
    id_guest, 
    sum(n_messages) as sum_n_messages
FROM airbnb_contacts
GROUP BY id_guest;
```

Now let's get into more complicated stuff.  

## 3. Workers With The Highest And Lowest Salaries - Amazon  

A lot of practical problems do not start with "Rank the users...." and generally, by understanding the requirement, we have to deduce when to apply window functions. As it happens, some times we can utilie window functions to extract insights that are not directly related to assigning ranks. Let's explore this problem statement to understand what I am talking about.  

> You have been asked to find the employees with the highest and lowest salary. Your output should include the employee's ID, salary, and department, as well as a column salary_type that categorizes the output by: 'Highest Salary' represents the highest salary and 'Lowest Salary' represents the lowest salary.

**Table: worker**

| Column | Type |
| ------ |:----:|
| worker_id | int |
| first_name | varchar |
| last_name | varchar |
| salary | int |
| joining_date | datetime |
| department | varchar |  

**Table: title**  

| Column | Type |
| ------ |:----:|
| worker_ref_id | int |
| worker_title | varchar |
| affected_from | datetime |  

Let's break down the requirements:
1. In the output we need worker_id, salary, and department - all of which are in worker table.
2. We also need a new column 'salary type' in output that has two values: highest salary and lowest salary.

Query Plan:
1. Create two rank columns, one in desc order where rank=1 is highest salary, and other in asc order where rank=1 as lowest salary.
2. Assign a CTE for steps 1.
3. Select the required columns from CTE output and create 'salary_type' column using CASE statement.
4. Filter the highest and lowest salaries only using WHERE clause to select only rank=1 values.

PostgreSQL Query:  

```sql
WITH cte1 AS
(
SELECT 
    *, 
    RANK() OVER(ORDER BY salary desc) AS highest_salary,
    RANK() OVER(ORDER BY salary asc) AS lowest_salary
FROM
    worker
)

SELECT
    worker_id,
    salary,
    department,
    CASE
        WHEN highest_salary = 1 THEN 'Highest Salary'
        ELSE 'Lowest Salary'
    END AS salary_type
FROM cte1
WHERE lowest_salary = 1 OR highest_salary = 1;
```

This showcases how window functions can be applied to extract meanigful insights. Let's work one last example!  

## 4. Top 5 States With 5 Star Businesses - Yelp  

As we saw in previous example, in some cases ranking is not required in the final result, but is used to find another information. Let's understand the problem statement.  

> Find the top 5 states with the most 5 star businesses. Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, return all the unique states. If two states have the same result, sort them in alphabetical order.

Table: **yelp_business**  


| Column | Type |
| ------ |:----:|
| business_id | varchar |
| name | varchar |
| neighborhood | varchar |
| address | varchar |
| city | varchar |
| state | varchar |
| postal_code | varchar |
| latitude | float |
| longitude | float |
| stars | float |
| review_count | int |
| is_open | int |
| categories | varchar |

Break it down:  
1. Filter 5 states based on number of 5 star businesses in desc order.
2. Output columns need name of state and number of 5 star businesses.
3. We need to return all the states in case of ties meaning output rows are not limited to just 5 (Cannot use LIMIT statement).
4. Use alphabetical asc order for tiebreaker.

Plan:
1. COUNT number of states that have 5 stars
2. Assign rank on basis of states having most 5 stars businesses in desc order.
3. USE CTE for steps 1 and 2.
4. From the CTE output select only the rows where rank <= 5. This will ensure all the states that have equal number of 5 star businesses will be included
5. Order by number of businesses desc and by state alphabetically asc.

Here, The key is to use RANK() instead of DENSE_RANK() as we need to find top 5 states. RANK() will skip rankings which make sure we only include top 5 states.

PostgreSQL Solution:  

```sql
WITH cte1 AS
(
select state, business, RANK() OVER (ORDER BY business DESC) AS new
from
(select state, count(state) as business
from yelp_business
where stars = 5
group by state) as a1
)

SELECT cte1.state, cte1.business
from cte1
WHERE new <=5
ORDER BY cte1.business desc, cte1.state asc;
```

Window functions are powerful tools that can be used to not only produce ranked results but also to produce meaningful insights if used with their full potential. The examples here demonstrate just that.  

## Credits  

All the credits for the interview questions and table schema goes to [Stratascratch](https://www.stratascratch.com/) which is a wonderful platform to practice coding skills.




