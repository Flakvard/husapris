-- CALL fo_properties.DeleteALL(46);

-- CALL fo_properties.CleanDB(TRUE);
SELECT * FROM fo_properties.view_properties;
SELECT * FROM fo_properties.properties;
SELECT * FROM fo_properties.address;
SELECT * FROM fo_properties.cities;
SELECT * FROM fo_properties.img_to_properties;
SELECT * FROM fo_properties.house_num;
SELECT * FROM fo_properties.price_InsertPropertyWithAddressAndCityof_properties;
SELECT * FROM fo_properties.price_bids;
SELECT * FROM fo_properties.price_of_properties;

-- view
SELECT * FROM fo_properties.view_properties;
SELECT * FROM fo_properties.properties WHERE idproperties = 2069;
SELECT COUNT(idproperties) FROM fo_properties.properties ;

SELECT AVG(suggestPrice) FROM fo_properties.view_properties WHERE view_properties.cityName = "Tórshavn" AND view_properties.insideM2 > 0;
SELECT COUNT(idproperties) FROM fo_properties.view_properties WHERE view_properties.cityName = "Tórshavn" AND view_properties.insideM2 > 0;
SELECT * FROM fo_properties.view_properties WHERE view_properties.cityName = "Tórshavn" AND view_properties.insideM2 > 0;
SELECT * FROM fo_properties.view_properties WHERE view_properties.latestBidPrice > 0;

SELECT * FROM fo_properties.view_properties WHERE view_properties.lastUpdate >= "2023-11-30 00:00:00";

SELECT * FROM fo_properties.view_properties WHERE view_properties.addressName = "Flatnavegur";

SELECT * FROM fo_properties.view_properties WHERE view_properties.cityName IN ("Sandavágur", "Miðvágur", "Sørvágur") ;

-- fermetur prísurin fyri Sandavág, Miðvág og Sørvág
SELECT cityName,addressName, insideM2, outsideM2, ROUND(suggestPrice,0) AS suggestPrice, ROUND(suggestPrice / insideM2,0) AS m2PriceHouse, ROUND(suggestPrice / outsideM2, 0) AS m2PriceLand FROM fo_properties.view_properties WHERE view_properties.cityName IN ("Sandavágur", "Miðvágur", "Sørvágur") ORDER BY cityName, suggestPrice;
-- fermetur prísurin fyri Sandavág, Miðvág og Sørvág
-- CASE WHEN * IS NOT NULL THEN * END - er í grundini neyðugt, um ein bert skal hava fyri hús fermetur prís
SELECT cityName,ROUND(AVG(suggestPrice), 0) AS avgSuggestPrice,ROUND(AVG(CASE WHEN insideM2 IS NOT NULL THEN suggestPrice / insideM2 END), 0) AS avgM2PriceHouse,ROUND(AVG(CASE WHEN insideM2 IS NULL THEN NULL ELSE suggestPrice / outsideM2 END), 0) AS avgM2PriceLand, COUNT(suggestPrice) AS countOfProperties FROM fo_properties.view_properties WHERE view_properties.cityName IN ("Sandavágur", "Miðvágur", "Sørvágur") AND insideM2 != 0 GROUP BY cityName;
SELECT cityName,ROUND(AVG(suggestPrice), 0) AS avgSuggestPrice,ROUND(AVG(suggestPrice / insideM2), 0) AS avgM2PriceHouse,ROUND(AVG(suggestPrice / outsideM2), 0) AS avgM2PriceLand, COUNT(suggestPrice) AS countOfProperties FROM fo_properties.view_properties WHERE view_properties.cityName IN ("Sandavágur", "Miðvágur", "Sørvágur") AND insideM2 != 0 GROUP BY cityName;

-- fermetur prísurin fyri allar bygdir
SELECT cityName,
	ROUND(AVG(suggestPrice), 0) AS avgSuggestPrice,
    ROUND(AVG(suggestPrice / insideM2), 0) AS avgM2PriceHouse,
    ROUND(AVG(suggestPrice / outsideM2), 0) AS avgM2PriceLand,
    COUNT(suggestPrice) AS countOfProperties
FROM fo_properties.view_properties 
WHERE insideM2 != 0 
GROUP BY cityName;


SELECT * FROM fo_properties.view_properties WHERE view_properties.cityName = "Saltangará" AND view_properties.insideM2 > 0;



SELECT * FROM fo_properties.price_bids WHERE properties_idproperties = 2104;
SELECT COUNT(suggestPrice),AVG(suggestPrice) FROM fo_properties.view_properties WHERE view_properties.cityName = "Sandavágur";


-- CALL fo_properties.InsertPropertyWithAddressAndCity("Betri", 1929, 123, 433, 4, 3, 'Zarepta', '2', 'Vatnsoyrar','375',LOAD_FILE('C:\Users\marni\Downloads\381291489_1033763987632828_5122911739328786514_n.jpg'));
-- CALL fo_properties.InsertPropertyWithAddressAndCity("Betri", 1929, 123, 433, 4, 3, 'Zarepta', '2', 'Vatnsoyrar','375',LOAD_FILE('C:\xampp\htdocs\381291489_1033763987632828_5122911739328786514_n.jpg'));

-- "C:\xampp\htdocs\381291489_1033763987632828_5122911739328786514_n.jpg"
-- "C:/xampp/htdocs/381291489_1033763987632828_5122911739328786514_n.jpg"
-- CALL fo_properties.InsertPropertyWithAddressAndCity("Betri", 1929, 123, 433, 4, 3, 'Beitini', '69', 'Miðvágur','370');

-- Check if property is already created
-- DELIMITER //
-- DECLARE isCreated INT;
--   SELECT idproperties FROM fo_properties.properties 
--    WHERE houseNum_idhouse_num = 1 
--    AND address_idaddress = 1;
    -- set @propertyInsert = isCreated; -- debugging
    -- set @isCreatedprint = isCreated; -- debugging
    -- select isCreatedprint;

-- DELIMITER ;