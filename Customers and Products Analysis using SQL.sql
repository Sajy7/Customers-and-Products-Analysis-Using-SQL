/*
This database contains information about a car and motorcycle sales company, its employees,
customers, offices and  orders and other information related to sales department of company.
I will focus on analysis of customers and products of this company. 

*/

-- This is the summary of tables in this DATABASE 

SELECT 'Customers' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('customers'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM customers

 UNION ALL
 
 SELECT 'Orders' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('orders'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM orders
  
 UNION ALL

SELECT 'Orderdetails' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('orderdetails'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM orderdetails
  
 UNION ALL
 
 SELECT 'Payments' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('payments'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM payments
  
 UNION ALL
 
 SELECT 'Employees' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('employees'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM employees
  
 UNION ALL
 
 SELECT 'Offices' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('offices'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM offices
   
  UNION ALL
  
  SELECT 'Products' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('products'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM products
  
  UNION ALL
 
 SELECT 'ProductLines' AS table_name, (SELECT COUNT(*) 
                                    FROM pragma_table_info('productlines'))
									AS number_of_attributes,
								  COUNT(*) AS number_of_rows
  FROM productlines
  
 ORDER BY number_of_attributes DESC, table_name DESC;
 
 /*
 I will answer this question: 
     which products should we order more of or less of?
 This question refers to inventory reports, including low stock and product performance.
 This will optimize the supply and the user experience by preventing the best-selling products from going out-of-stock.
 */
 
 
 -- The low stock represents the quantity of each product sold divided by the quantity of product in stock.
 -- Query below will show the products that needs to be recharged imediately.
 
 SELECT p.productCode, p.productName,  ROUND(( SELECT SUM(o.quantityOrdered)
                                                 FROM orderdetails AS o
					                         	WHERE p.productCode = o.productCode
				                      	 	    GROUP BY o.productCode )/ p.quantityInStock , 2) AS low_stock
   FROM products AS p 
  GROUP BY p.productCode
  ORDER BY low_stock DESC
  LIMIT 10; 
  
  -- The product performance represents the sum of sales per product.
  
 SELECT p.productCode, p.productName, ( SELECT o.quantityOrdered * o.priceEach
                         FROM orderdetails AS o
						WHERE p.productCode = o.productCode
						GROUP BY o.productCode) AS product_performance
   FROM products AS p
  GROUP BY p.productCode
  ORDER BY product_performance DESC 
  LIMIT 10;
  
  
  -- In the query below we will compute how much profit each customer generates.
  
 WITH
 joined_tables_products_orders_orderdetails AS(
SELECT *
  FROM products AS p
  JOIN orderdetails AS od
    ON p.productCode = od.productCode
  JOIN orders AS o
    ON od.orderNumber = o.orderNumber
 )
 
 -- The average amount of money a customer generates. 
 
SELECT ROUND(AVG(profit_from_customer ),2) AS average_amount_of_money_a_customer_generates
  FROM (SELECT SUM( quantityOrdered * (priceEach - buyPrice)) AS profit_from_customer
          FROM joined_tables_products_orders_orderdetails
		 GROUP BY customerNumber);
 
 -- Top five VIP customers Which have benefited our company the most.
 
 SELECT c.contactLastName, c.contactFirstName, c.city, c.country, SUM( quantityOrdered * (priceEach - buyPrice)) AS profit_from_customer
   FROM joined_tables_products_orders_orderdetails AS j
   JOIN customers AS c
     ON j.customerNumber = c.customerNumber
  GROUP BY c.customerNumber
  ORDER BY profit_from_customer DESC
  LIMIT 5;

 -- Top five least-engaged customers.
 SELECT c.contactLastName, c.contactFirstName, c.city, c.country, SUM( quantityOrdered * (priceEach - buyPrice)) AS profit_from_customer
   FROM joined_tables_products_orders_orderdetails AS j
   JOIN customers AS c
     ON j.customerNumber = c.customerNumber
  GROUP BY c.customerNumber
  ORDER BY profit_from_customer ASC
  LIMIT 5; 
  
  
  
  /*
 Queries below will compute The number of new customers arriving each month.
 That way we can check if it's worth spending money on acquiring new customers.
  */
  
  
 
WITH 
payment_with_year_month_table AS (
SELECT *, 
       CAST(SUBSTR(paymentDate, 1,4) AS INTEGER)*100 + CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
  FROM payments p
),

customers_by_month_table AS (
SELECT p1.year_month, COUNT(*) AS number_of_customers, SUM(p1.amount) AS total
  FROM payment_with_year_month_table p1
 GROUP BY p1.year_month
),

new_customers_by_month_table AS (
SELECT p1.year_month, 
       COUNT(*) AS number_of_new_customers,
       SUM(p1.amount) AS new_customer_total,
       (SELECT number_of_customers
          FROM customers_by_month_table c
        WHERE c.year_month = p1.year_month) AS number_of_customers,
       (SELECT total
          FROM customers_by_month_table c
         WHERE c.year_month = p1.year_month) AS total
  FROM payment_with_year_month_table p1
 WHERE p1.customerNumber NOT IN (SELECT customerNumber
                                   FROM payment_with_year_month_table p2
                                  WHERE p2.year_month < p1.year_month)
 GROUP BY p1.year_month
)

SELECT year_month, 
       ROUND(number_of_new_customers*100/number_of_customers,1) AS number_of_new_customers_props,
       ROUND(new_customer_total*100/total,1) AS new_customers_total_props
  FROM new_customers_by_month_table;
  
  /*
  As you can see, the number of clients has been decreasing since 2003, and in 2004, we had the lowest values.
  The year 2005, which is present in the database as well, isn't present in the table above, 
  this means that the store has not had any new customers since September of 2004. 
  This means it makes sense to spend money acquiring new customers.
  */
  
  /*
  To determine how much money we can spend acquiring new customers, we can compute the Customer Lifetime Value (LTV),
  which represents the average amount of money a customer generates. Which is 39039.59 $.
  */
 

 -- In this project I analyzed the database tables, the low stock and performance of each product, profits from customers, top five customers, LTV, and the number of new customers for each month. 