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

We are going to use real world application of window functions, for that will we solve four interview questions for companies like Forbes, Google, Airbnb, and Uber which will showcase how and in what scenario window functions are utilized.  

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

Here, we understand that we need to create two new columns in output - one is the aggregate function (either count or sum) and the other that assigns a rank. By this detail it is clear as a day that we need to use window function, but which one? We see that we need to obtain a unique rank, ROW_NUMBER() is the function that assigns a unique value to the partition, hence we will use that. The PostgreSQL solution is given below.  

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

This will produce the desired result, hence giving a basic demonstration of ROW_NUMBER() window function. Now let's try to solve a bit trickier questions.  

## 2. 


