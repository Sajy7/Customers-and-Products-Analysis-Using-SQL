
-- Warm Up Cheking integrity of the database queries

SELECT COUNT(Name)
  FROM Track
 WHERE Composer = 'U2' ; 
 
 SELECT Title
   FROM Employee
  WHERE LastName = 'Johnson' ; 
  
  
 -- The Countries that have most invoices
  
  SELECT BillingCountry, count(BillingCountry) AS invoices
    FROM Invoice
   GROUP BY 1
   ORDER BY count(BillingCountry) DESC, BillingCountry ;
   
   
 -- Which city has the best customers?
   
   SELECT BillingCity, SUM(Total)
     FROM Invoice
	GROUP BY BillingCity
	ORDER BY 2 DESC
	LIMIT 1 ;
	
	
-- Who is the best customer?

SELECT c.FirstName, c.LastName , SUM(i.Total) AS the_total_money_spent
  FROM Invoice i
  JOIN Customer c
    ON i.CustomerId = c.CustomerId
 GROUP BY i.CustomerId
 ORDER BY 3 DESC; 
 
 
 -- The email, first name, last name, and Genre of all Rock Music listeners
 
 SELECT c.Email, c.FirstName, c.LastName, g.Name
   FROM Customer c
   JOIN Invoice i
     ON c.CustomerId = i.CustomerId
   JOIN InvoiceLine inv
     ON i.InvoiceId = inv.InvoiceId
   JOIN Track t
     ON inv.TrackId = t.TrackId
   JOIN Genre g
     ON t.GenreId = g.GenreId
  WHERE g.Name = 'Rock'
  GROUP BY c.CustomerId 
  ORDER BY c.Email; 
  

-- Who is writing the rock music? 
 
SELECT a.Name , count(t.TrackId) AS total_rock_tracks
  FROM Artist a
  JOIN Album al
    ON a.ArtistId = al.ArtistId
  JOIN Track t
    ON al.AlbumId = t.AlbumId
  JOIN Genre g
    ON t.GenreId = g.GenreId
 WHERE g.Name = 'Rock'
 GROUP BY a.ArtistId
 ORDER BY 2 DESC ; 
 


 -- which artist has earned the most according to the InvoiceLines?
 
 SELECT a.Name , SUM(inv.Quantity * inv.UnitPrice )
  FROM Artist a
  JOIN Album al
    ON a.ArtistId = al.ArtistId
  JOIN Track t
    ON al.AlbumId = t.AlbumId
  JOIN InvoiceLine inv 
    ON t.TrackId = inv.TrackId
 GROUP BY a.Name
 ORDER BY 2 DESC;	
 
 -- which customer spent the most on the Iron Maiden artist. 
 
  SELECT a.Name , SUM(inv.Quantity * inv.UnitPrice ) AS Amount_spent, c.CustomerId , c.FirstName, c.LastName
  FROM Artist a
  JOIN Album al
    ON a.ArtistId = al.ArtistId
  JOIN Track t
    ON al.AlbumId = t.AlbumId
  JOIN InvoiceLine inv 
    ON t.TrackId = inv.TrackId
  JOIN Invoice i
    ON inv.InvoiceId = i.InvoiceId
  JOIN Customer c
    ON i.CustomerId = c.CustomerId
 WHERE a.Name = 'Iron Maiden'
 GROUP BY c.CustomerId
 ORDER BY 2 DESC;	
 
 
/*
Advanced SQL
*/

-- Question 1: Most popular music Genre for each country


WITH Purchases_Country_Genre AS(
SELECT  COUNT(i.InvoiceId)  AS Purchases, i.BillingCountry AS Country, g.Name AS Music_Genre , g.GenreId AS GenreID
  FROM Genre g
  JOIN Track t
    ON g.GenreId = t.GenreId
  JOIN InvoiceLine inv
    ON t.TrackId = inv.TrackId
  JOIN Invoice i
    ON inv.InvoiceId = i.InvoiceId	
 GROUP BY i.BillingCountry, g.Name
 ORDER BY 2  
 ),
 max_purchases AS (
SELECT MAX(Purchases) ,  Country
  FROM Purchases_Country_Genre
 GROUP BY Country 
 )
 
SELECT Purchases , Country,  Music_Genre , GenreID   
  FROM Purchases_Country_Genre
 WHERE (Purchases , Country) IN   max_purchases ;

 
 
-- Question 2: Return all the track names that have a song length longer than the average song length


 
SELECT Name, Milliseconds
  FROM Track
 WHERE Milliseconds >= (SELECT avg(Milliseconds) FROM Track ) 
 ORDER BY Milliseconds DESC;
 
 
 -- Question 3: Write a query that determines the customer that has spent the most on music for each country
 
  /*
 Another way of solving this problem:
 
 The first sub query is the same.
 
maxed_table AS (
SELECT Country, MAX(Total_Spent) AS max_spent
  FROM summed_for_every_customer
 GROUP BY Country
)

SELECT t1.*
  FROM summed_for_every_customer t1
 WHERE ( t1.Country , t1.Total_Spent ) IN maxed_table
 ;
 */
 
 WITH summed_for_every_customer AS
(
SELECT i.BillingCountry AS Country, SUM(i.Total) AS Total_Spent, c.FirstName , c.LastName, c.CustomerId
  FROM Invoice i
  JOIN Customer c
    ON i.CustomerId = c.CustomerId 
 GROUP BY c.CustomerId 
 ),
 maxed_table AS (
SELECT Country, MAX(Total_Spent) AS max_spent, FirstName , LastName, CustomerId
  FROM summed_for_every_customer
 GROUP BY Country
)

SELECT t1.*
  FROM summed_for_every_customer t1
  JOIN maxed_table t2
    ON t1.Country = t2.Country
 WHERE t1.Total_Spent = t2.max_spent
 ORDER BY t1.Total_Spent DESC , t1.Country ;
 
 

 
 
 
 
 /*
 Assignment -- Project -- Questions to 
 */
 
 
 
/* Query 1 */
-- What are the top 10 genres that sold most in the marketplace?

SELECT g.Name AS Genre , ROUND(SUM(inv.UnitPrice * inv.Quantity), 2)  AS Total_amount_Sold
  FROM Genre g
  JOIN Track t
    ON g.GenreId = t.GenreId
  JOIN InvoiceLine inv
    ON t.TrackId = inv.TrackId
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 10 ; 
 
 
 /* Query 2 */
-- What are the top 10 Playlists that sold most in the marketplace?

SELECT p.Name AS PlayList_Name ,  ROUND(SUM(inv.UnitPrice * inv.Quantity), 2)   AS Total_amount_Sold
  FROM Playlist p
  JOIN PlaylistTrack pi
    ON p.PlaylistId = pi.PlaylistId
  JOIN Track t
    ON pi.TrackId = t.TrackId 
  JOIN InvoiceLine inv	
    ON t.TrackId = inv.TrackId
 GROUP BY 1
 ORDER BY 2 DESC ;
 
 
 
/* Query 3 */
-- Who is the Most popular Artist in each country?  


WITH Artists_Purchases_Country AS(
SELECT i.BillingCountry AS Country, a.Name AS Artist_Name, COUNT(i.InvoiceId)  AS Number_of_Purchases 
  FROM Artist a
  JOIN Album al
    ON a.ArtistId = al.ArtistId
  JOIN Track t
    ON al.AlbumId = t.AlbumId 
  JOIN InvoiceLine inv
    ON t.TrackId = inv.TrackId
  JOIN Invoice i
    ON inv.InvoiceId = i.InvoiceId	
 GROUP BY i.BillingCountry, a.Name
 ORDER BY 1 , 3 DESC   
 ),
 max_purchases AS (
SELECT MAX(Number_of_Purchases) ,  Country
  FROM Artists_Purchases_Country
 GROUP BY Country 
 )
 
SELECT Artist_Name ,COUNT(Number_of_Purchases)  AS Most_Popular_In_Countries
  FROM Artists_Purchases_Country
 WHERE (Number_of_Purchases , Country) IN   max_purchases
 GROUP BY Artist_Name 
 ORDER BY 2 DESC;
 
 /*
 A way of presenting both the county that the artist is most popular and the total number of that countries for the respective artist.
 
 SELECT  Artist_Name , Country , count(Number_of_Purchases) OVER ( PARTITION BY Artist_Name ) AS MostPopular_in_how_many_countries
  FROM Artists_Purchases_Country
 WHERE (Number_of_Purchases , Country) IN   max_purchases
 ORDER by 3 DESC 
 */
 
 
 
 
 /* Query 4 */
-- They presented most tracks in which media type ?
 
SELECT m.Name AS MediaType , COUNT(t.TrackId) AS Number_of_Tracks
  FROM Track t
  JOIN MediaType m	
    ON t.MediaTypeId = m.MediaTypeId
 GROUP BY 1
 ORDER BY 2 DESC;
 
 
 