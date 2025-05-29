use netflix;

#1. Using the Viewing History table, identify the top 3 most-watched movies based on 
#viewing hours. 

select * from viewinghistory;

select * from content;

select titlename , avg(runtime)  as viewing_hours
from viewinghistory
join content on content.contentid=viewinghistory.contentid
where category="Movie"
group by titlename
order by viewing_hours desc
limit 3;

#2. Partition the viewing hours by category and genre to find the top genre in each 
#category. Use the rank function to rank genres within each category
WITH ranked_genres AS (
select  runtime as viewing_hours ,category,genre,
RANK() OVER (PARTITION BY category ORDER BY runtime DESC) AS genre_rank
from viewinghistory
join content on content.contentid=viewinghistory.contentid
)
SELECT 
    category,
    genre,
    viewing_hours,
    genre_rank
FROM 
    ranked_genres
WHERE 
    genre_rank = 1;
    
    

#3. Determine the number of subscriptions for each plan. Display Plan ID, Plan Name and 
#Subscriber count in descending order of Subscriber count. 

select Plans.PlanID,PlanNAme,count(custID) as Number_of_subscribers
from subscribes
join Plans on Plans.PlanID=subscribes.PlanID
group by PlanID
order by Number_of_subscribers desc;

#4. Which device type is most commonly used to access Netflix content? Provide the Device 
#Type and count of accesses. 
 
 select DeviceType , count(ProfileID) as count_of_access
 from uses
 join devices on uses.DeviceID=devices.DeviceID
 group by DeviceType
 having DeviceType =(select max(devicetype) from devices);
 
 #5. Compare the viewing trends of movies versus TV shows. What is the average viewing 
#time for movies and TV shows separately? 

select avg(runtime) as avg_viewing_time , category
from content 
join viewinghistory on content.contentid=viewinghistory.contentid
group by category;


#6. Identify the most preferred language by customers. Provide the number of customers, 
#and language
select * from customerslanguagepreferred;
select count(custid) as Number_of_customers, Language
from customerslanguagepreferred 
group by language
order by Number_of_customers desc
limit 1;

SELECT Language, COUNT(custid) AS Number_of_customers
FROM customerslanguagepreferred
GROUP BY Language
HAVING COUNT(custid) = (
    SELECT MAX(lang_count) 
    FROM (
        SELECT COUNT(custid) AS lang_count
        FROM customerslanguagepreferred
        GROUP BY Language
    ) AS counts
);

WITH LanguageCounts AS (
    SELECT Language, COUNT(custid) AS Number_of_customers
    FROM customerslanguagepreferred
    GROUP BY Language
)
SELECT Language, Number_of_customers
FROM LanguageCounts
WHERE Number_of_customers = (
    SELECT MAX(Number_of_customers) FROM LanguageCounts
);




#7. How many customers have adult accounts versus child accounts? Provide the count for 
#each type. 

SELECT 'Adult' AS account_type, COUNT(profileid) AS count
FROM adultacc
UNION ALL
SELECT 'Child' AS account_type, COUNT(profileid) AS count
FROM childacc;


#8. Determine the average number of profiles created per customer account.

SELECT AVG(profile_count) AS avg_profiles_per_customer
FROM (
    SELECT custid, COUNT(*) AS profile_count
    FROM profiles
    GROUP BY custid
) AS customer_profiles;


SELECT 
    cp.custid,
    cp.profile_count,
    avg_data.avg_profiles_per_customer
FROM (
    SELECT custid, COUNT(*) AS profile_count
    FROM profiles
    GROUP BY custid
) AS cp
CROSS JOIN (
    SELECT AVG(profile_count) AS avg_profiles_per_customer
    FROM (
        SELECT custid, COUNT(*) AS profile_count
        FROM profiles
        GROUP BY custid
    ) AS customer_profiles
) AS avg_data;

#9. Identify the content that has the lowest average viewing time per user. Provide the titles 
#and their average viewing time.

select avg(runtime) as avg_viewing_time , titlename,viewinghistory.contentid
from content 
join viewinghistory on content.contentid=viewinghistory.contentid
group by viewinghistory.contentid
order by avg_viewing_time asc
limit 1;
 

#10. Determine the count for each content type. 
select * from content;
select count(*) as count,category as content_type
from content
group by  category;

#11. Compare the number of customers that have unlimited access and who do not.

select count(customers.custid) as no_of_customers,contentaccess
from customers 
join subscribes on subscribes.custid=customers.custid
join plans on plans.planid=subscribes.planid
group by contentaccess;

#12. Find Average monthly price for plans with Content Access as "unlimited". 

select avg(monthlyprice)  as avg_monthly_price,contentaccess
from plans
group by contentaccess
having contentaccess='unlimited';

#13. List all the customers who have taken the plan for till 2028 and later. Display 
#CustomerID, Customer name and Expiration Date of the plan, ordered by Expiration 
#Date in descending order first, and then by Customer Name.

select customers.custid,concat(fname,lname) as customer_name , expirationdate
from customers
join paymentmethod on customers.custid=paymentmethod.custid
where year(expirationdate)>=2028
order by expirationdate desc,customer_name;

#14.Display Average Revenue generated from each city. Rank city based on average reveue
select city,avg(paymentamount) as avg_revenue,
RANK() OVER ( order by avg(paymentamount) desc) as city_rank
from paymentmethod
join paymenthistory on paymenthistory.cardid=paymentmethod.cardid
group by city;


#15Display most frequently viewed genre among adults for each category. 

select category,genre
from (
     select
       category,
       genre,
       count(content.contentid) as most_viewed,
       row_number() over (partition by category order by count(content.contentid) desc) as rn
       from content
       join viewinghistory on content.contentid=viewinghistory.contentid
       join adultacc on adultacc.profileid=viewinghistory.profileid
       group by genre,category
       ) as ranked_genres
       where rn=1;






