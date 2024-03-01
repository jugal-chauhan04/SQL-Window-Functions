SELECT from_user, COUNT(from_user) AS total_email,
ROW_NUMBER() OVER(ORDER BY COUNT(from_user) desc, from_user asc) as activity_rank
FROM google_gmail_emails
GROUP BY from_user;
