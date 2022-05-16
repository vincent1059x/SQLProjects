DROP TABLE IF EXISTS sales_volume
CREATE TABLE sales_volume (
		sales_date DATE,
		volume float)
INSERT INTO sales_volume(sales_date,volume)
VALUES
('2022-05-01', 50000),
('2022-05-10', 120000),
('2022-05-25', 90000),
('2022-06-01', 60000),
('2022-06-10', 160000),
('2022-06-25', 290000),
('2022-07-01', 110000),
('2022-07-10', 220000),
('2022-07-25', 430000)

SELECT SUM(volume) FROM sales_volume
--1530000
--1. Viết lệnh để thể hiện total volume theo tháng và % total volume theo tháng trên tổng volume					
DROP TABLE IF EXISTS sales
WITH sales AS (
	SELECT MONTH(sales_date) AS Month_sales, SUM(volume) AS Total_Volume
	FROM sales_volume
	GROUP BY MONTH(sales_date)
	)
SELECT Month_sales, Total_Volume, Round((Total_Volume/1530000)*100,2) AS p_to_total
FROM sales
GROUP BY Month_sales, Total_Volume

--2.Viết lệnh để thể hiện đơn hàng có delivery time sớm nhất của mỗi tài xế				

DROP TABLE IF EXISTS delivery_data
CREATE TABLE delivery_data (
		driver_id int,
		order_id int,
		deliver_time date)
INSERT INTO delivery_data (driver_id,order_id,deliver_time)
VALUES
(1002723,1,'2022-09-15'),
(1872845,2,'2022-09-15'),
(1002723,3,'2022-09-16'),
(1872845,4,'2022-09-16'),
(1002723,5,'2022-09-17'),
(1285836,6,'2022-09-17'),
(1872845,7,'2022-09-17'),
(1002723,8,'2022-09-18'),
(1285836,9,'2022-09-18'),
(1872845,10,'2022-09-18')

SELECT * FROM delivery_data


--3. Viết code để tìm shipping fee trung bình (average shipping fee) theo từng thành phố và theo tháng

DROP TABLE IF EXISTS order_detail
CREATE TABLE order_detail (
		order_id int,
		driver_id int,
		deliver_time date,
		city_id int,
		shipping_fee float)
INSERT INTO order_detail (order_id, driver_id, deliver_time, city_id, shipping_fee)
VALUES
(1, 1002723, '2022-09-15', 217, 15000),
(2, 1872845, '2022-09-15', 218, 13500),
(3, 1002723, '2022-09-16', 217, 23000),
(4, 1872845, '2022-09-16', 218, 53000),
(5, 1002723, '2022-09-16', 217, 24000),
(6, 1285836, '2022-09-17', 219, 52000),
(7, 1872845, '2022-09-17', 218, 16000),
(8, 1002723, '2022-09-17', 217, 39000),
(9, 1285836, '2022-09-18', 219, 23000),
(10, 1872845, '2022-09-18', 218, 16500)

DROP TABLE IF EXISTS city_infor
CREATE TABLE city_infor (
		city_id int,
		city_name varchar(250))
INSERT INTO city_infor (city_id, city_name)
VALUES
(215, 'Hue'),
(216, 'Hai Phong'),
(217, 'Ho Chi Minh'),
(218, 'Ha Noi'),
(219, 'Ha Nang')

SELECT * FROM city_infor
SELECT * FROM order_detail

SELECT MONTH(deliver_time) AS Month, city_name, AVG(shipping_fee) AS Average_Shipping_fee
FROM order_detail od LEFT JOIN city_infor ci ON od.city_id = ci.city_id
GROUP BY city_name, MONTH(deliver_time)
ORDER BY 3

--4. Viết code để gộp 2 bảng dưới đây lại:

DROP TABLE IF EXISTS food_order_detail
CREATE TABLE food_order_detail (
		service varchar(250),
		order_id int,
		shipper_id int,
		deliver_time date)
INSERT INTO food_order_detail (service, order_id, shipper_id, deliver_time)
VALUES
('Food', 1, 1002723, '2022-09-15'),
('Food', 2, 1002723, '2022-09-15'),
('Food', 3, 1872845, '2022-09-15'),
('Food', 4, 1872845, '2022-09-16'),
('Food', 5, 1872845, '2022-09-16')

DROP TABLE IF EXISTS ship_order_detail
CREATE TABLE ship_order_detail (
		service varchar(250),
		order_id int,
		shipper_id int,
		deliver_time datetime)
INSERT INTO ship_order_detail (service, order_id, shipper_id, deliver_time)
VALUES
('Ship', 1, 1285836, '2022-10-29 12:00:00'),
('Ship', 2, 1285836, '2022-10-29 12:00:00'),
('Ship', 3, 1285836, '2022-10-29 12:00:00'),
('Ship', 4, 4329812, '2022-11-03 12:00:00'),
('Ship', 5, 4329812, '2022-11-03 12:00:00')

SELECT * FROM food_order_detail
SELECT * FROM ship_order_detail

WITH new_data AS (
SELECT * FROM food_order_detail
UNION
SELECT * FROM ship_order_detail)

SELECT service, CONCAT(service, '-', order_id) AS order_uid, shipper_id, CONVERT(date, deliver_time) AS deliver_time_new 
FROM new_data

