with t as (
SELECT
  sp.continent,
  sum (p.price) as revenue,
       sum(case when sp.device = 'mobile' then p.price else 0 end) as revenue_from_mobile,
       sum(case when sp.device = 'desktop' then p.price else 0 end) as revenue_from_desktop,
FROM `DA.order` AS o
JOIN `DA.product` AS p
  ON o.item_id = p.item_id
JOIN `DA.session_params` AS sp
ON o.ga_session_id=sp.ga_session_id
GROUP BY continent
),
u AS (
   SELECT
 sp.continent as continent,
 COUNT(DISTINCT a.id) as account_count,
COUNT(DISTINCT CASE WHEN a.is_verified = 1 THEN a.id END) AS verified_count
 FROM `data-analytics-mate.DA.account` a
 JOIN `data-analytics-mate.DA.account_session` acs
 ON a.id=acs.account_id
 JOIN `data-analytics-mate.DA.session_params` sp
 ON acs.ga_session_id=sp.ga_session_id
 GROUP BY continent
  ),


sc AS(
   SELECT
   sp.continent as continent,
   COUNT(DISTINCT sp.ga_session_id) as session_count
   FROM
    `data-analytics-mate.DA.session_params` sp
 GROUP BY continent
)








select u.continent,
       t.revenue as revenue,
       t.revenue_from_mobile,
       t.revenue_from_desktop,
       t.revenue / sum(t.revenue) over () * 100 as revenue_from_total,
       u.account_count as account_count,
       u.verified_count as verified_account,
       sc.session_count,
from u
left join t
on t.continent = u.continent
left join sc
on sc.continent = t.continent
