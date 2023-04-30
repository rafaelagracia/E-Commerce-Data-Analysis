USE mavenfuzzyfactory;
/*first*/
SELECT
 YEAR(website_sessions.created_at) AS yr,
 MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders

FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id= website_sessions.website_session_id

WHERE website_sessions.created_at < '2021-11-27'

AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

/*second*/
SELECT
 YEAR(website_sessions.created_at) AS yr,
 MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders


FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id= website_sessions.website_session_id

WHERE website_sessions.created_at < '2021-11-27'

AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

/* third */
SELECT
 YEAR(website_sessions.created_at) AS yr,
 MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders


FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id= website_sessions.website_session_id

WHERE website_sessions.created_at < '2021-11-27'

AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;
/*fourth*/

SELECT DISTINCT
utm_source,
utm_campaign,
http_referer

FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';

SELECT
 YEAR(website_sessions.created_at) AS yr,
 MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions

FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/*fifth*/
SELECT
 YEAR(website_sessions.created_at) AS yr,
 MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT  website_sessions.website_session_id ) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/* sixth */
USE mavenfuzzyfactory;

SELECT
MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- for this step, we'll find the first pageview id
-- CREATE TEMPORARY TABLE first-test_pageviews
SELECT
 website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id ) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-07-28'  -- prescribed by the assignment
AND website_sessions.created_at > '2012-06-19 00:35:54' -- the min_pageview time we found for the test
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 
website_pageviews.website_session_id;

-- Next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
first_test_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');  

-- SELECT * FROM nonbrand_test_sessions_w_landing_pages;

-- then we make a table to bring in orders
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id AS order_id

FROM nonbrand_test_sessions_w_landing_pages
LEFT JOIN orders
ON orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id; 
-- to find the difference between conversion rates

SELECT 
landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

-- .0319 for /home, vs .0406 for /launder-1
-- .0087 additional orders per session

-- Finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home
SELECT MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27'

-- max website_session_id = 17145
SELECT 
 COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
AND website_session_id > 17145 -- last /home session
AND  utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
;

-- 22,972 website sessions since the test
-- X .0087 incremental conversion = 202 incremental orders since 7/29
-- roughly 4 months, so roughly 50 extra orders per month, Not bad!

/* seventh*/
CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
website_session_id,
MAX(homepage) AS saw_homepage,
MAX(custom_lander) AS saw_custom_lander,
MAX(products_page) AS product_made_it,
MAX(mrfuzzy_page) AS mrfuzzy_made_it,
MAX(cart_page) AS cart_made_it,
MAX(shipping_page) AS shipping_made_it,
MAX(billing_page) AS billing_made_it,
MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT 
website_sessions.website_session_id,
website_pageviews.pageview_url,

-- website_pageviews.created_at AS pageview_created_at,

CASE WHEN page_url = '/home' THEN 1 ELSE 0 END AS homepage,
CASE WHEN page_url = '/lander-1' THEN 1 ELSE 0 END AS customer_lander,
CASE WHEN page_url = '/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN page_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN page_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN page_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN page_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN page_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page,

FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session-id = website_pageviews.website_session)_id
WHERE website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND wewebsite_sessions.created_at < '2012-07-28'
AND wewebsite_sessions.created_at > '2012-06-19'
ORDER BY
website_sessions.website_session_id,
website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id;

-- then this would produce the final output, part 1

CASE
WHEN saw_homepage = 1 THEN 'saw_homepage'
WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
ELSE 'uh oh...check logic'
END AS segment,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_ session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged
GROUP BY 1
;

-- then this as final output part 2 - click rates
SELECT
CASE
WHEN saw_homepage = 1 THEN 'saw_homepage'
WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
ELSE 'uh oh... check logic'
END AS segment,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_sessions_id ELSE NULL END) AS shipping_click_rt,
COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt,
FROM session_level_made_it_flagged
GROUP BY 1
;
SELECT
billing_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
AND website_pageviews.pageview_url IN ('/billing', 'billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1
;
-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view

SELECT
COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month

-- 1,194 billing sessions in past month
-- LIFT : $8.51 per billing session
-- VALUE OF BILLING TEST: $10,160 over the past month

