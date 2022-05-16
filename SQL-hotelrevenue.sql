--Union 3 tables into 1 table and named it as a hotels

WITH hotels as(
SELECT * FROM dbo.[2018]
union
SELECT * FROM dbo.[2019]
union
SELECT * FROM dbo.[2020])
--Calculate the revenue and group by year, hotel
SELECT hotel, arrival_date_year, round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) AS Revenue
FROM hotels
GROUP BY arrival_date_year, hotel

--Join market_segment & meal_cost into hotels table

WITH hotels as(
SELECT * FROM dbo.[2018]
union
SELECT * FROM dbo.[2019]
union
SELECT * FROM dbo.[2020])

SELECT *
FROM hotels h
LEFT JOIN market_segment m ON h.market_segment=m.market_segment
LEFT JOIN meal_cost mc ON mc.meal=h.meal

--And then connect it to PowerBI

