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
ORDER BY cte1.business desc, cte1.state asc
