-- Create an empty database repository
CREATE DATABASE store;
USE store;

CREATE TABLE categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE TABLE stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);

CREATE TABLE staffs (
	staff_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE orders (
	order_id INT IDENTITY (1, 1) PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
-- Run file storedata.sql (https://drive.google.com/file/d/1R257EH0b17rahbMTubH7fWBw72lbSGBI/view?usp=sharing) to add data

-- Query the products of the Hao brand and belong to the Mountain Bikes category.
select
	product_name 
from products as p
join brands as b on p.brand_id = b.brand_id
join categories as c on p.category_id = c.category_id
where
	b.brand_name = N'Haro'
and c.category_name = N'Mountain Bikes'

select
	product_name
from products
where
	brand_id = (select brand_id from brands where brand_name = 'Haro')
and category_id = (select category_id from categories where category_name = N'Mountain Bikes')

--Query for the names of customers whose orders were rejected.
select 
	first_name, last_name
from customers
where customer_id in (
	select customer_id
	from orders
	where order_status = 3
)

select 
	first_name, last_name
from customers as c
join orders as o on c.customer_id = o.customer_id
where order_status = 3

--Query order date and employee name whose orders were rejected
select 
	o.order_date, s.first_name + ' ' + s.last_name as staff_name
from orders as o
join staffs as s on s.staff_id = o.staff_id
where o.order_status = 3

select
	o.order_date, 
	(select s.first_name + ' ' + s.last_name from staffs as s where s.staff_id = o.staff_id) as staff_name
from orders as o
where o.order_status = 3

--Query the name of the products sold on 03/02/2017
select
	product_name
from products as p
join order_items as oi on oi.product_id = p.product_id
join orders as o on o.order_id = oi.order_id
where o.order_date = '2017-02-03'

select
	product_id, product_name
from products as p 
where exists (
	select * from orders as o
	join order_items as oi on o.order_id = oi.order_id
	where oi.product_id = p.product_id and o.order_date = '2017-02-03'
) 
-- Query the names of products sold at Santa Cruz Bikes store in February 2017.
select
	product_name
from products as p
join order_items as oi on oi.product_id = p.product_id
join orders as o on o.order_id = oi.order_id
join stores as s on o.store_id = s.store_id
where o.order_date >= '2017-02-01'
and o.order_date < '2017-03-01'
and s.store_name = N'Santa Cruz Bikes'
-- Query the names of products purchased by a customer named Cesar.
select
	product_name
from products as p
join order_items as oi on oi.product_id = p.product_id
join orders as o on o.order_id = oi.order_id
join customers as c on o.customer_id = c.customer_id
where o.order_status = 4 and c.first_name = N'Cesar'
-- Query the names of brands whose products are sold in January 2016.
select
	distinct brand_name
from brands as b
join products as p on b.brand_id = p.brand_id
join order_items as oi on oi.product_id = p.product_id
join orders as o on o.order_id = oi.order_id
where o.order_date >= '2016-01-01'
and o.order_date < '2016-02-01'
--Query the names of the product categories that were sold at Baldwin Bikes in February 2016.
select
	distinct category_name
from categories as c
join products as p on c.category_id = p.category_id
join order_items as oi on oi.product_id = p.product_id
join orders as o on o.order_id = oi.order_id
join stores as s on o.store_id = s.store_id
where o.order_date >= '2016-02-01'
and o.order_date < '2016-03-01'
and s.store_name = N'Baldwin Bikes'
--Query the customer name generated by the employee whose fisrt_name is Genna.
select
	distinct c.first_name, c.last_name
from customers as c
join orders as o on c.customer_id = o.customer_id
join staffs as s on s.staff_id = o.staff_id
where s.first_name = N'Genna'
