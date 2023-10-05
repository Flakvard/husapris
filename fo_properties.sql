-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 05, 2023 at 11:00 PM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 8.0.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fo_properties`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CleanDB` (IN `dbClean` BOOL)  BEGIN

	IF dbClean IS NOT NULL THEN
		-- Delete all data from the `img` table
		DELETE FROM fo_properties.img_to_properties;
        
        -- Delete all data from the `price_of_properties` table
		DELETE FROM fo_properties.price_of_properties;
        
        -- Delete all data from the `price_bids` table
		DELETE FROM fo_properties.price_bids;
		
		-- Delete all data from the `properties` table
		DELETE FROM fo_properties.properties;
		
		-- Delete all data from the `house_num` table
		DELETE FROM fo_properties.house_num;
		
		-- Delete all data from the `address` table
		DELETE FROM fo_properties.address;
		
		-- Delete all data from the `cities` table
		-- DELETE FROM fo_properties.cities;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Could not clean everything';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteALL` (IN `propertyId` INT(11))  BEGIN
    DECLARE houseNum INT(11);
    DECLARE addressid INT(11);
    DECLARE cityid INT(11);
    
    SELECT houseNum_idhouse_num INTO houseNum FROM fo_properties.properties WHERE idproperties = propertyId;
    SELECT address_idaddress INTO addressid FROM fo_properties.house_num WHERE house_num = houseNum; 
    SELECT cities_idCity INTO cityid FROM fo_properties.address WHERE idaddress = addressid; 
   
    -- If the houseNum exist
    IF houseNum IS NOT NULL THEN
		-- delete img first
		DELETE FROM fo_properties.img_to_properties where properties_idproperties = propertyId;
		-- then delete property 
		DELETE FROM fo_properties.properties WHERE idproperties = propertyId;
        -- then delete house num 
		DELETE FROM fo_properties.house_num where idhouse_num = houseNum;
        -- then delete addresses
        DELETE FROM fo_properties.address where idaddress = addressid;
        -- then delete cities
        DELETE FROM fo_properties.cities where idCity = cityid;
		
        
    -- If the houseNum doesn't exist 
    ELSE
        -- Handle the case where the address was found (e.g., raise an error or return a message)
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Could not delete everything';
        
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteProperty` (IN `propertyId` INT(11))  BEGIN
    DECLARE houseNum INT(11);
    SELECT houseNum_idhouse_num INTO houseNum FROM fo_properties.properties WHERE idproperties = propertyId; 
   
    -- If the houseNum exist
    IF houseNum IS NOT NULL THEN
		-- delete img first
		DELETE FROM fo_properties.img_to_properties where properties_idproperties = propertyId;
		-- then delete property 
		DELETE FROM fo_properties.properties WHERE idproperties = propertyId;
        -- then delete house num 
		DELETE FROM fo_properties.house_num where idhouse_num = houseNum;
		
		
        
    -- If the houseNum doesn't exist 
    ELSE
        -- Handle the case where the address was found (e.g., raise an error or return a message)
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Could not delete property';
        
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertAddress` (IN `address_text` VARCHAR(255), IN `city_id` INT(11), OUT `address_id` INT)  BEGIN
    DECLARE city_in_address INT(11);
	-- Initialize variables
	SET city_in_address = NULL;
    
    -- Check if the address is in the city
    SELECT idaddress INTO city_in_address FROM fo_properties.address WHERE addressName = address_text AND cities_idCity = city_id;
    set @addressInsert = city_in_address; -- debugging
          
	-- If the address exist and the city exist together, get the address_id
    IF city_in_address IS NOT NULL THEN
		SELECT idaddress INTO address_id FROM fo_properties.address WHERE addressName = address_text AND cities_idCity = city_id;
        set @addressInsert = address_id; -- debugging
        
    -- If the address doesn't exist and the city does exist
    ELSEIF city_in_address IS NULL THEN
        INSERT INTO fo_properties.address (addressName, cities_idCity) VALUES (address_text,city_id);
        SET address_id = LAST_INSERT_ID();
        set @addressInsert = address_id; -- debugging

    ELSE
        -- Handle the case where the address was found (e.g., raise an error or return a message)
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'City for specific address not found.';
        
    END IF;
    
	Select @addressInsert; -- for debugging
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCity` (IN `city_text` VARCHAR(45), IN `postnum` VARCHAR(45), OUT `city_id` INT)  BEGIN
	-- DECLARE cityID INT(11);
    
    -- Check if postnum is null and try find it
	SELECT idCity INTO city_id FROM fo_properties.cities WHERE cityName = city_text;
    
    /* 
    -- Check if the city already exists
    SELECT idCity INTO cityID FROM fo_properties.cities WHERE cityName = city_text AND cityPostNum = postnum;
    set @cityInsert = cityID; -- debugging
    
    -- If the city doesn't exist and there is city_text and post_num, insert it
    IF cityID IS NULL AND city_text IS NOT NULL AND postnum IS NOT NULL THEN
        INSERT INTO fo_properties.cities (cityName,cityPostNum) VALUES (city_text,postnum);
        SET city_id = LAST_INSERT_ID();
        
    -- If the city doesn't exist and there is no city_text or post_num,
    ELSEIF cityID IS NULL AND postnum IS NULL OR city_text IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No Post Number or City provided to create new city.';
        
    -- If the city exist, select the city id and return
	ELSEIF cityID IS NOT NULL THEN
		SELECT idCity INTO city_id FROM fo_properties.cities WHERE idCity = cityID;
        set @cityInsert = city_id; -- debugging
    ELSE
        -- Handle the case where the nothing works or found (e.g., raise an error or return a message)
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Could not create og get city.';
    END IF;
    
	Select @cityInsert; -- for debugging
    */
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertHouseNum` (IN `houseNum` VARCHAR(45), IN `address_id` INT(11), OUT `houseID` INT)  BEGIN
    DECLARE getHouseID INT;
    
    -- Initialize variables
    SET getHouseID = NULL;

    -- Check if the house number already exists for the given address
    SELECT idhouse_num INTO getHouseID
    FROM fo_properties.house_num
    WHERE house_num = houseNum AND address_idaddress = address_id;
    
    -- If the house number exists for the address
    IF getHouseID IS NOT NULL THEN
        SET houseID = getHouseID;
    -- If the house number does not exist for the address
    ELSE
        INSERT INTO fo_properties.house_num (house_num, address_idaddress)
        VALUES (houseNum, address_id);
        SET houseID = LAST_INSERT_ID();
    -- ELSE
    --     -- Handle the case where the address was found (e.g., raise an error or return a message)
	--    SIGNAL SQLSTATE '45000'
    --    SET MESSAGE_TEXT = 'Could not find or create a new house num for a specific address.';
    END IF;

    -- SELECT houseID; -- Return the houseID
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertImg` (IN `imgName` VARCHAR(45), IN `propertyId` INT(11))  BEGIN
    DECLARE getPropertyID INT;
    SET getPropertyID = NULL;

     -- Check if the property exists
    SELECT idproperties INTO getPropertyID FROM fo_properties.properties WHERE idproperties = propertyId;
    
    -- If the houseNum does not exist and the address_id does not exist for that specific houseNum
    IF getPropertyID IS NOT NULL THEN
		INSERT INTO fo_properties.img_to_properties (img_name, properties_idproperties)
		VALUES (imgName, propertyId);
		-- SET imgID = LAST_INSERT_ID();
        -- img_blob_max16mb
    ELSE
        -- Handle the case where the property not found (e.g., raise an error or return a message)
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Property for img not found.';
        
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertOnlyImg` (IN `in_properties_id` INT, IN `imgblob` MEDIUMBLOB)  BEGIN
	DECLARE getPropertyID INT;
    SET getPropertyID = NULL;

     -- Check if the property exists
    SELECT idproperties INTO getPropertyID FROM fo_properties.properties WHERE idproperties = in_properties_id;
    
    -- If the houseNum does not exist and the address_id does not exist for that specific houseNum
    IF getPropertyID IS NOT NULL AND imgblob IS NOT NULL THEN
		UPDATE fo_properties.img_to_properties SET img_blob_max16mb=imgblob WHERE properties_idproperties = in_properties_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPriceBid` (IN `in_priceBid` DECIMAL(45,2), IN `in_priceBidDueDate` DATETIME, IN `in_properties_id` INT)  BEGIN
    INSERT INTO price_bids (priceBid, priceBidDueDate, properties_idproperties)
    VALUES (in_priceBid, in_priceBidDueDate, in_properties_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPriceOfProperty` (IN `in_suggestPrice` DECIMAL(45,2), IN `in_latestBidPrice` DECIMAL(45,2), IN `in_soldPrice` DECIMAL(45,2), IN `in_properties_id` INT)  BEGIN
    INSERT INTO price_of_properties (suggestPrice, latestBidPrice, soldPrice, properties_idproperties)
    VALUES (in_suggestPrice, in_latestBidPrice, in_soldPrice, in_properties_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertProperty` (IN `website` VARCHAR(255), IN `yearbuild` INT(50), IN `insideM2` INT(50), IN `outsideM2` INT(50), IN `rooms` INT(50), IN `floorLevels` INT(50), IN `address_idaddress` INT(11), IN `houseNum_idhouse_num` INT(11), OUT `propertyID` INT)  BEGIN
    -- Insert values into the 'properties' table
    IF website IS NOT NULL AND address_idaddress IS NOT NULL AND houseNum_idhouse_num IS NOT NULL THEN
		INSERT INTO fo_properties.properties (website, yearbuild, insideM2, outsideM2, rooms, floorLevels, address_idaddress, houseNum_idhouse_num)
		VALUES (website, yearbuild, insideM2, outsideM2, rooms, floorLevels, address_idaddress, houseNum_idhouse_num);
		SET propertyID = LAST_INSERT_ID();
    ELSE 
    -- Handle the case where the nothing works (e.g., raise an error or return a message)
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Could not create property - InsertProperty PROCEDURE';
	END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPropertyWithAddressAndCity` (IN `website` VARCHAR(255), IN `yearbuilt` INT(50), IN `insideM2` INT(50), IN `outsideM2` INT(50), IN `rooms` INT(50), IN `floorLevels` INT(50), IN `address_text` VARCHAR(255), IN `houseNum` VARCHAR(45), IN `city_text` VARCHAR(50), IN `postNum` VARCHAR(50), IN `prices` DECIMAL(45,2), IN `LatestPrices` DECIMAL(45,2), IN `validDates` DATETIME)  BEGIN
	DECLARE address_id INT;
    DECLARE city_id INT;
    DECLARE houseNum_id INT;
    DECLARE propertyID INT;
    DECLARE imgID INT;
	DECLARE currentBidPrice INT;
    
    -- Initialize variables
    SET address_id = NULL;
    SET city_id = NULL;
    SET houseNum_id = NULL;
    SET propertyID = NULL;
    SET currentBidPrice = NULL;

    -- Insert or retrieve the city_id
    CALL fo_properties.InsertCity(city_text, postNum, city_id);

    -- Insert or retrieve the address_id
    CALL fo_properties.InsertAddress(address_text, city_id, address_id);

    -- Insert houseNum or retrieve the houseNum_id
    CALL fo_properties.InsertHouseNum(houseNum, address_id, houseNum_id);

    -- Check if property with the same address and house number already exists
    SELECT idproperties INTO propertyID
    FROM fo_properties.properties
    WHERE address_idaddress = address_id
    AND houseNum_idhouse_num = houseNum_id;

    IF propertyID IS NOT NULL THEN
        -- Handle the case where the address and house number are found (e.g., raise an error or return a message)
        -- SIGNAL SQLSTATE '45000'
        -- SET MESSAGE_TEXT = 'House number at specific address is already created.';
        -- propertyID
        SELECT latestBidPrice INTO currentBidPrice FROM fo_properties.price_of_properties WHERE properties_idproperties = propertyID;
        IF LatestPrices > currentBidPrice THEN
			UPDATE fo_properties.price_of_properties SET price_of_properties.latestBidPrice=LatestPrices WHERE properties_idproperties = propertyID;
            CALL fo_properties.InsertPriceBid(LatestPrices,validDates,propertyID);
        END IF;
    ELSE
        -- Insert the property using the obtained address_id, houseNum_id, and city_id
        CALL fo_properties.InsertProperty(website, yearbuilt, insideM2, outsideM2, rooms, floorLevels, address_id, houseNum_id, propertyID);
        
        -- Insert img blob
        SELECT idproperties INTO propertyID
        FROM fo_properties.properties
        WHERE houseNum_idhouse_num = houseNum_id
        AND address_idaddress = address_id;
        
        CALL fo_properties.InsertImg(CONCAT(city_text,'_',address_text,'_',houseNum,'_',yearbuilt,'_',website), propertyID);
        CALL fo_properties.InsertPriceOfProperty(prices,0.00,0.00,propertyID);
        
    END IF;
    
    SELECT propertyID; -- Return the property ID
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `idaddress` int(11) NOT NULL,
  `addressName` varchar(255) NOT NULL,
  `cities_idCity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`idaddress`, `addressName`, `cities_idCity`) VALUES
(1741, 'Gerðisbreyt ', 493),
(1742, 'Steigarbrekka ', 457),
(1743, 'Heimaratún ', 485),
(1744, 'Ennivegur ', 391),
(1745, 'Grásteinsgøta ', 485),
(1746, 'Geilarvegur ', 388),
(1747, 'Kráarvegur ', 391),
(1748, 'Liðabrekkan ', 482),
(1749, 'Garðavegur ', 467),
(1750, 'Stoffalág ', 485),
(1751, 'Garðavegur ', 419),
(1752, 'Bøgøta ', 490),
(1753, 'Karlamagnusarbreyt ', 407),
(1754, 'Ærgisbrekka ', 455),
(1755, 'Niels Winthersgøta ', 485),
(1756, 'Neyst Matr nr ', 448),
(1757, 'Matr nr ', 432),
(1758, 'Grundstykki  ', 493),
(1759, 'Íbúð ', 443),
(1760, 'Lýðarsvegur ', 484),
(1761, 'Undir Ryggi ', 485),
(1762, 'Liljugøta ', 485),
(1763, 'Leirvíksvegur ', 467),
(1764, 'Landavegur ', 485),
(1765, 'í Homrum ', 421),
(1766, 'Niels Finsens gøta ', 485),
(1767, 'við Krossá ', 415),
(1768, 'Niðari Vegur ', 466),
(1769, 'matr.nr. ', 448),
(1770, 'Handan Á ', 436),
(1771, 'Hagabrekka ', 464),
(1772, 'Geilin ', 490),
(1773, 'matr.nr. ', 432),
(1774, 'Hjaltarók ', 485),
(1775, 'Ovastuhjallar ', 457),
(1776, 'matr.nr. ', 485),
(1777, 'Salvarávegur ', 480),
(1778, 'matr.nr. ', 499),
(1779, 'Klaksvíksvegur ', 419),
(1780, 'matr. ', 419),
(1781, 'matr.nr. ', 446),
(1782, 'matr.nr. ', 429),
(1783, 'matr.nr. ', 500),
(1784, 'Traðagøta ', 419),
(1785, 'Ólavsvegur ', 484),
(1786, 'Jørð til grundøkir omanfyri Múlaklett', 387),
(1787, 'Sílagøta íbúð ', 485),
(1788, 'Gripsvegur ', 485),
(1789, 'Tróndargøta ', 485),
(1790, 'Bíarvegur ', 410),
(1791, 'matr.nr. ', 444),
(1792, 'Torkilsgøta ', 407),
(1793, 'Sjógøta ', 489),
(1794, 'Kongagøta ', 485),
(1795, 'Heiðastubbi ', 485),
(1796, 'Meinhartstrøð ', 485),
(1797, 'Øksnagerði ', 485),
(1798, 'Steigartún ', 457),
(1799, 'Heiðagøta ', 380),
(1800, 'Ryskigøta ', 485),
(1801, 'Vesturgøta ', 485),
(1802, 'Traðarvegur ', 421),
(1803, 'Flatnavegur ', 441);

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `idCity` int(11) NOT NULL,
  `cityName` varchar(45) DEFAULT NULL,
  `cityPostNum` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`idCity`, `cityName`, `cityPostNum`) VALUES
(379, 'Akrar', '927'),
(380, 'Argir', '160'),
(381, 'Argir (postsmoga)', '165'),
(382, 'Ánir', '726'),
(383, 'Árnafjørður', '727'),
(384, 'Bøur', '386'),
(385, 'Dalur', '235'),
(386, 'Depil', '735'),
(387, 'Eiði', '470'),
(388, 'Elduvík', '478'),
(389, 'Fámjin', '870'),
(390, 'Froðba', '825'),
(391, 'Fuglafjørður', '530'),
(392, 'Funningsfjørður', '477'),
(393, 'Funningur', '475'),
(394, 'Gásadalur', '387'),
(395, 'Gjógv', '476'),
(396, 'Glyvrar', '625'),
(397, 'Gøta', '510'),
(398, 'Gøtueiði', '666'),
(399, 'Gøtugjógv', '511'),
(400, 'Haldarsvík', '440'),
(401, 'Haraldssund', '785'),
(402, 'Hattarvík', '767'),
(403, 'Hellur', '695'),
(404, 'Hestur', '280'),
(405, 'Hósvík', '420'),
(406, 'Hov', '960'),
(407, 'Hoyvík', '188'),
(408, 'Húsar', '796'),
(409, 'Húsavík', '230'),
(410, 'Hvalba', '850'),
(411, 'Hvalvík', '430'),
(412, 'Hvannasund', '740'),
(413, 'Hvítanes', '187'),
(414, 'Innan Glyvur', '494'),
(415, 'Kaldbak', '180'),
(416, 'Kaldbaksbotnur', '185'),
(417, 'Kirkja', '766'),
(418, 'Kirkjubøur', '175'),
(419, 'Klaksvík', '700'),
(420, 'Kolbanargjógv', '495'),
(421, 'Kollafjørður', '410'),
(422, 'Koltur', '285'),
(423, 'Kunoy', '780'),
(424, 'Kvívík', '340'),
(425, 'Lambareiði', '626'),
(426, 'Lambi', '627'),
(427, 'Langasandur', '438'),
(428, 'Leirvík', '520'),
(429, 'Leynar', '335'),
(430, 'Ljósá', '466'),
(431, 'Lopra', '926'),
(432, 'Miðvágur', '370'),
(433, 'Mikladalur', '797'),
(434, 'Morskranes', '496'),
(435, 'Múli', '737'),
(436, 'Mykines', '388'),
(437, 'Nes (Eysturoy)', '655'),
(438, 'Nes (Vágur)', '925'),
(439, 'Nesvík', '437'),
(440, 'Norðdepil', '730'),
(441, 'Norðoyri', '725'),
(442, 'Norðradalur', '178'),
(443, 'Norðragøta', '512'),
(444, 'Norðskáli', '460'),
(445, 'Norðtoftir', '736'),
(446, 'Nólsoy', '270'),
(447, 'Oyndarfjørður', '690'),
(448, 'Oyrarbakki', '400'),
(449, 'Oyrareingir', '415'),
(450, 'Oyri', '450'),
(451, 'Porkeri', '950'),
(452, 'Rituvík', '640'),
(453, 'Runavík', '620'),
(454, 'Saksun', '436'),
(455, 'Saltangará', '600'),
(456, 'Saltnes', '656'),
(457, 'Sandavágur', '360'),
(458, 'Sandur', '210'),
(459, 'Sandvík', '860'),
(460, 'Selatrað', '497'),
(461, 'Signabøur', '416'),
(462, 'Skarvanes', '236'),
(463, 'Skálabotnur', '485'),
(464, 'Skálavík', '220'),
(465, 'Skáli', '480'),
(466, 'Skipanes', '665'),
(467, 'Skopun', '240'),
(468, 'Skúvoy', '260'),
(469, 'Skælingur', '336'),
(470, 'Stóra Dímun', '286'),
(471, 'Strendur', '490'),
(472, 'Streymnes', '435'),
(473, 'Stykkið', '330'),
(474, 'Sumba', '970'),
(475, 'Sund', '186'),
(476, 'Svínáir', '465'),
(477, 'Svínoy', '765'),
(478, 'Syðradalur (Kal.)', '795'),
(479, 'Syðradalur (Str.)', '177'),
(480, 'Syðrugøta', '513'),
(481, 'Søldarfjørður', '660'),
(482, 'Sørvágur', '380'),
(483, 'Tjørnuvík', '445'),
(484, 'Toftir', '650'),
(485, 'Tórshavn', '100'),
(486, 'Tórshavn (postsmoga)', '110'),
(487, 'Trongisvágur', '826'),
(488, 'Trøllanes', '798'),
(489, 'Tvøroyri', '800'),
(490, 'Vágur', '900'),
(491, 'Válur', '358'),
(492, 'Vatnsoyrar', '385'),
(493, 'Velbastaður', '176'),
(494, 'Vestmanna', '350'),
(495, 'Viðareiði', '750'),
(496, 'Víkarbyrgi', '928'),
(497, 'Æðuvík', '645'),
(498, 'Øravík', '827'),
(499, 'Ørðavík', '827'),
(500, 'Skála', '480');

-- --------------------------------------------------------

--
-- Table structure for table `house_num`
--

CREATE TABLE `house_num` (
  `idhouse_num` int(11) NOT NULL,
  `house_num` varchar(45) DEFAULT NULL,
  `address_idaddress` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `house_num`
--

INSERT INTO `house_num` (`idhouse_num`, `house_num`, `address_idaddress`) VALUES
(1875, '3', 1741),
(1876, '14', 1742),
(1877, '3', 1743),
(1878, '66', 1744),
(1879, '2B', 1745),
(1880, '5', 1746),
(1881, '20', 1747),
(1882, '15', 1748),
(1883, '12', 1749),
(1884, '59', 1750),
(1885, '70', 1751),
(1886, '30', 1752),
(1887, '44', 1753),
(1888, '1', 1754),
(1889, '9', 1755),
(1890, '141', 1756),
(1891, '13d', 1757),
(1892, '176', 1758),
(1893, '1', 1759),
(1894, '48B', 1760),
(1895, '2', 1759),
(1896, '3', 1759),
(1897, '4', 1759),
(1898, '12', 1761),
(1899, '7', 1762),
(1900, '9', 1763),
(1901, '61', 1764),
(1902, '25', 1765),
(1903, '23A', 1766),
(1904, '6', 1767),
(1905, '78', 1768),
(1906, '58a', 1769),
(1907, '4', 1770),
(1908, '28', 1771),
(1909, '33', 1772),
(1910, '208p', 1773),
(1911, '4', 1774),
(1912, '9', 1775),
(1913, '1350a', 1776),
(1914, '9', 1777),
(1915, '31', 1778),
(1916, '59', 1779),
(1917, '144i', 1780),
(1918, '159d', 1781),
(1919, '21f', 1782),
(1920, '240a', 1783),
(1921, '37', 1784),
(1922, '6', 1785),
(1923, '', 1786),
(1924, '0.3', 1787),
(1925, '33', 1788),
(1926, '55', 1789),
(1927, '107', 1790),
(1928, '0.2', 1787),
(1929, '12a', 1791),
(1930, '7', 1792),
(1931, '178', 1793),
(1932, '3', 1794),
(1933, '8', 1795),
(1934, '5', 1795),
(1935, '94B', 1764),
(1936, '9', 1796),
(1937, '8', 1797),
(1938, '13', 1798),
(1939, '7A', 1799),
(1940, '34', 1800),
(1941, '22', 1801),
(1942, '41', 1800),
(1943, '5A', 1802),
(1944, '73B', 1803);

-- --------------------------------------------------------

--
-- Table structure for table `img_to_properties`
--

CREATE TABLE `img_to_properties` (
  `idimg_to_properties` int(11) NOT NULL,
  `img_name` varchar(45) DEFAULT 'Unnamed',
  `properties_idproperties` int(11) NOT NULL,
  `img_blob_max16mb` mediumblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `img_to_properties`
--

INSERT INTO `img_to_properties` (`idimg_to_properties`, `img_name`, `properties_idproperties`, `img_blob_max16mb`) VALUES
(102027, 'Velbastaður_Gerðisbreyt _3_1985_Betri', 2067, NULL),
(102028, 'Sandavágur_Steigarbrekka _14_1926_Betri', 2068, NULL),
(102029, 'Tórshavn_Heimaratún _3_1959_Betri', 2069, NULL),
(102030, 'Fuglafjørður_Ennivegur _66_1952_Betri', 2070, NULL),
(102031, 'Tórshavn_Grásteinsgøta _2B_2023_Betri', 2071, NULL),
(102032, 'Elduvík_Geilarvegur _5_2018_Betri', 2072, NULL),
(102033, 'Fuglafjørður_Kráarvegur _20_1990_Betri', 2073, NULL),
(102034, 'Sørvágur_Liðabrekkan _15_1918_Betri', 2074, NULL),
(102035, 'Skopun_Garðavegur _12_1924_Betri', 2075, NULL),
(102036, 'Tórshavn_Stoffalág _59_0_Betri', 2076, NULL),
(102037, 'Klaksvík_Garðavegur _70_1940_Betri', 2077, NULL),
(102038, 'Vágur_Bøgøta _30_1960_Betri', 2078, NULL),
(102039, 'Hoyvík_Karlamagnusarbreyt _44_2021_Betri', 2079, NULL),
(102040, 'Saltangará_Ærgisbrekka _1_2003_Betri', 2080, NULL),
(102041, 'Tórshavn_Niels Winthersgøta _9_1947_Betri', 2081, NULL),
(102042, 'Oyrarbakki_Neyst Matr nr _141_1989_Betri', 2082, NULL),
(102043, 'Miðvágur_Matr nr _13d_0_Betri', 2083, NULL),
(102044, 'Velbastaður_Grundstykki  _176_0_Betri', 2084, NULL),
(102045, 'Norðragøta_Íbúð _1_2023_Skyn', 2085, NULL),
(102046, 'Toftir_Lýðarsvegur _48B_2021_Skyn', 2086, NULL),
(102047, 'Norðragøta_Íbúð _2_2023_Skyn', 2087, NULL),
(102048, 'Norðragøta_Íbúð _3_2023_Skyn', 2088, NULL),
(102049, 'Norðragøta_Íbúð _4_2023_Skyn', 2089, NULL),
(102050, 'Tórshavn_Undir Ryggi _12_1900_Skyn', 2090, NULL),
(102051, 'Tórshavn_Liljugøta _7_2022_Skyn', 2091, NULL),
(102052, 'Skopun_Leirvíksvegur _9_1949_Skyn', 2092, NULL),
(102053, 'Tórshavn_Landavegur _61_1936_Skyn', 2093, NULL),
(102054, 'Kollafjørður_í Homrum _25_1910_Skyn', 2094, NULL),
(102055, 'Tórshavn_Niels Finsens gøta _23A_0_Skyn', 2095, NULL),
(102056, 'Kaldbak_við Krossá _6_0_Skyn', 2096, NULL),
(102057, 'Skipanes_Niðari Vegur _78_2022_Skyn', 2097, NULL),
(102058, 'Oyrarbakki_matr.nr. _58a_0_Skyn', 2098, NULL),
(102059, 'Mykines_Handan Á _4_1905_Skyn', 2099, NULL),
(102060, 'Skálavík_Hagabrekka _28_1980_Skyn', 2100, NULL),
(102061, 'Vágur_Geilin _33_1978_Skyn', 2101, NULL),
(102062, 'Miðvágur_matr.nr. _208p_0_Skyn', 2102, NULL),
(102063, 'Tórshavn_Hjaltarók _4_0_Skyn', 2103, NULL),
(102064, 'Sandavágur_Ovastuhjallar _9_0_Skyn', 2104, NULL),
(102065, 'Tórshavn_matr.nr. _1350a_0_Skyn', 2105, NULL),
(102066, 'Syðrugøta_Salvarávegur _9_0_Skyn', 2106, NULL),
(102067, 'Ørðavík_matr.nr. _31_0_Skyn', 2107, NULL),
(102068, 'Klaksvík_Klaksvíksvegur _59_0_Skyn', 2108, NULL),
(102069, 'Klaksvík_matr. _144i_0_Skyn', 2109, NULL),
(102070, 'Nólsoy_matr.nr. _159d_0_Skyn', 2110, NULL),
(102071, 'Leynar_matr.nr. _21f_0_Skyn', 2111, NULL),
(102072, 'Skála_matr.nr. _240a_0_Skyn', 2112, NULL),
(102073, 'Klaksvík_Traðagøta _37_0_Skyn', 2113, NULL),
(102074, 'Toftir_Ólavsvegur _6_0_Skyn', 2114, NULL),
(102075, 'Eiði_Jørð til grundøkir omanfyri Múlaklett__0', 2115, NULL),
(102076, 'Tórshavn_Sílagøta íbúð _0.3_2023_Skyn: Selt', 2116, NULL),
(102077, 'Tórshavn_Gripsvegur _33_1951_Skyn: Selt', 2117, NULL),
(102078, 'Tórshavn_Tróndargøta _55_0_Skyn: Selt', 2118, NULL),
(102079, 'Hvalba_Bíarvegur _107_1920_Skyn: Selt', 2119, NULL),
(102080, 'Tórshavn_Sílagøta íbúð _0.2_2023_Skyn: Selt', 2120, NULL),
(102081, 'Norðskáli_matr.nr. _12a_1965_Skyn: Selt', 2121, NULL),
(102082, 'Hoyvík_Torkilsgøta _7_2001_Skyn: Selt', 2122, NULL),
(102083, 'Tvøroyri_Sjógøta _178_1908_Skyn: Selt', 2123, NULL),
(102084, 'Tórshavn_Kongagøta _3_1968_Skyn: Selt', 2124, NULL),
(102085, 'Tórshavn_Heiðastubbi _8_1970_Skyn: Selt', 2125, NULL),
(102086, 'Tórshavn_Heiðastubbi _5_0_Skyn: Selt', 2126, NULL),
(102087, 'Tórshavn_Landavegur _94B_2023_Skyn: Nyggj ogn', 2127, NULL),
(102088, 'Tórshavn_Meinhartstrøð _9_0_Skyn: Nyggj ogn', 2128, NULL),
(102089, 'Tórshavn_Øksnagerði _8_1990_Skyn: Nyggj ogn', 2129, NULL),
(102090, 'Sandavágur_Steigartún _13_1900_Skyn: Nyggj og', 2130, NULL),
(102091, 'Argir_Heiðagøta _7A_1986_Skyn: Nyggj ogn', 2131, NULL),
(102092, 'Tórshavn_Ryskigøta _34_0_Skyn: Nytt bod', 2132, NULL),
(102093, 'Tórshavn_Vesturgøta _22_1989_Skyn: Nytt bod', 2133, NULL),
(102094, 'Tórshavn_Ryskigøta _41_0_Skyn: Fasturprisur', 2134, NULL),
(102095, 'Kollafjørður_Traðarvegur _5A_0_Betri', 2135, NULL),
(102096, 'Norðoyri_Flatnavegur _73B_2021_Betri', 2136, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `price_bids`
--

CREATE TABLE `price_bids` (
  `idpriceBids` int(11) NOT NULL,
  `priceBid` decimal(45,2) DEFAULT NULL,
  `priceBidDueDate` datetime NOT NULL,
  `properties_idproperties` int(11) NOT NULL,
  `createdDate` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `price_bids`
--

INSERT INTO `price_bids` (`idpriceBids`, `priceBid`, `priceBidDueDate`, `properties_idproperties`, `createdDate`) VALUES
(27, '3020000.00', '2023-10-03 14:00:00', 2067, '2023-10-05'),
(28, '425000.00', '0000-00-00 00:00:00', 2082, '2023-10-05'),
(29, '1200000.00', '0000-00-00 00:00:00', 2092, '2023-10-05'),
(30, '3200000.00', '0000-00-00 00:00:00', 2093, '2023-10-05'),
(31, '250000.00', '0000-00-00 00:00:00', 2104, '2023-10-05'),
(32, '300000.00', '0000-00-00 00:00:00', 2111, '2023-10-05'),
(33, '1800000.00', '2023-10-09 10:00:00', 2073, '2023-10-05');

-- --------------------------------------------------------

--
-- Table structure for table `price_of_properties`
--

CREATE TABLE `price_of_properties` (
  `idpriceOfProperties` int(11) NOT NULL,
  `suggestPrice` decimal(45,2) DEFAULT NULL,
  `latestBidPrice` decimal(45,2) DEFAULT NULL,
  `soldPrice` decimal(45,2) DEFAULT NULL,
  `properties_idproperties` int(11) NOT NULL,
  `lastUpdate` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `price_of_properties`
--

INSERT INTO `price_of_properties` (`idpriceOfProperties`, `suggestPrice`, `latestBidPrice`, `soldPrice`, `properties_idproperties`, `lastUpdate`) VALUES
(1179, '2995000.00', '3020000.00', '0.00', 2067, '2023-10-05 22:24:36'),
(1180, '1395000.00', '0.00', '0.00', 2068, '2023-10-05 22:24:22'),
(1181, '3595000.00', '0.00', '0.00', 2069, '2023-10-05 22:24:22'),
(1182, '1545000.00', '0.00', '0.00', 2070, '2023-10-05 22:24:22'),
(1183, '4700000.00', '0.00', '0.00', 2071, '2023-10-05 22:24:22'),
(1184, '2695000.00', '0.00', '0.00', 2072, '2023-10-05 22:24:22'),
(1185, '2095000.00', '1800000.00', '0.00', 2073, '2023-10-05 22:24:42'),
(1186, '975000.00', '0.00', '0.00', 2074, '2023-10-05 22:24:22'),
(1187, '1350000.00', '0.00', '0.00', 2075, '2023-10-05 22:24:22'),
(1188, '1795000.00', '0.00', '0.00', 2076, '2023-10-05 22:24:22'),
(1189, '695000.00', '0.00', '0.00', 2077, '2023-10-05 22:24:22'),
(1190, '1690000.00', '0.00', '0.00', 2078, '2023-10-05 22:24:22'),
(1191, '2995000.00', '0.00', '0.00', 2079, '2023-10-05 22:24:22'),
(1192, '4700000.00', '0.00', '0.00', 2080, '2023-10-05 22:24:22'),
(1193, '10000000.00', '0.00', '0.00', 2081, '2023-10-05 22:24:22'),
(1194, '495000.00', '425000.00', '0.00', 2082, '2023-10-05 22:24:36'),
(1195, '925000.00', '0.00', '0.00', 2083, '2023-10-05 22:24:22'),
(1196, '745000.00', '0.00', '0.00', 2084, '2023-10-05 22:24:22'),
(1197, '2100000.00', '0.00', '0.00', 2085, '2023-10-05 22:24:22'),
(1198, '2000000.00', '0.00', '0.00', 2086, '2023-10-05 22:24:22'),
(1199, '2100000.00', '0.00', '0.00', 2087, '2023-10-05 22:24:22'),
(1200, '2100000.00', '0.00', '0.00', 2088, '2023-10-05 22:24:22'),
(1201, '2100000.00', '0.00', '0.00', 2089, '2023-10-05 22:24:22'),
(1202, '3995000.00', '0.00', '0.00', 2090, '2023-10-05 22:24:22'),
(1203, '4995000.00', '0.00', '0.00', 2091, '2023-10-05 22:24:22'),
(1204, '1585000.00', '1200000.00', '0.00', 2092, '2023-10-05 22:24:36'),
(1205, '3675000.00', '3200000.00', '0.00', 2093, '2023-10-05 22:24:36'),
(1206, '1395000.00', '0.00', '0.00', 2094, '2023-10-05 22:24:22'),
(1207, '7495000.00', '0.00', '0.00', 2095, '2023-10-05 22:24:22'),
(1208, '330000.00', '0.00', '0.00', 2096, '2023-10-05 22:24:22'),
(1209, '3600000.00', '0.00', '0.00', 2097, '2023-10-05 22:24:22'),
(1210, '450000.00', '0.00', '0.00', 2098, '2023-10-05 22:24:22'),
(1211, '2900000.00', '0.00', '0.00', 2099, '2023-10-05 22:24:22'),
(1212, '1995000.00', '0.00', '0.00', 2100, '2023-10-05 22:24:22'),
(1213, '1295000.00', '0.00', '0.00', 2101, '2023-10-05 22:24:22'),
(1214, '500000.00', '0.00', '0.00', 2102, '2023-10-05 22:24:22'),
(1215, '1850000.00', '0.00', '0.00', 2103, '2023-10-05 22:24:22'),
(1216, '375000.00', '250000.00', '0.00', 2104, '2023-10-05 22:24:36'),
(1217, '5400000.00', '0.00', '0.00', 2105, '2023-10-05 22:24:22'),
(1218, '1800000.00', '0.00', '0.00', 2106, '2023-10-05 22:24:22'),
(1219, '300000.00', '0.00', '0.00', 2107, '2023-10-05 22:24:22'),
(1220, '950000.00', '0.00', '0.00', 2108, '2023-10-05 22:24:22'),
(1221, '400000.00', '0.00', '0.00', 2109, '2023-10-05 22:24:22'),
(1222, '600000.00', '0.00', '0.00', 2110, '2023-10-05 22:24:22'),
(1223, '390000.00', '300000.00', '0.00', 2111, '2023-10-05 22:24:36'),
(1224, '3595000.00', '0.00', '0.00', 2112, '2023-10-05 22:24:22'),
(1225, '400000.00', '0.00', '0.00', 2113, '2023-10-05 22:24:22'),
(1226, '350000.00', '0.00', '0.00', 2114, '2023-10-05 22:24:22'),
(1227, '3000000.00', '0.00', '0.00', 2115, '2023-10-05 22:24:22'),
(1228, '3250000.00', '0.00', '0.00', 2116, '2023-10-05 22:24:22'),
(1229, '3995000.00', '0.00', '0.00', 2117, '2023-10-05 22:24:22'),
(1230, '2500000.00', '0.00', '0.00', 2118, '2023-10-05 22:24:22'),
(1231, '795000.00', '0.00', '0.00', 2119, '2023-10-05 22:24:22'),
(1232, '3300000.00', '0.00', '0.00', 2120, '2023-10-05 22:24:22'),
(1233, '650000.00', '0.00', '0.00', 2121, '2023-10-05 22:24:22'),
(1234, '3895000.00', '0.00', '0.00', 2122, '2023-10-05 22:24:22'),
(1235, '1995000.00', '0.00', '0.00', 2123, '2023-10-05 22:24:22'),
(1236, '3200000.00', '0.00', '0.00', 2124, '2023-10-05 22:24:22'),
(1237, '4600000.00', '0.00', '0.00', 2125, '2023-10-05 22:24:22'),
(1238, '1600000.00', '0.00', '0.00', 2126, '2023-10-05 22:24:23'),
(1239, '4200000.00', '0.00', '0.00', 2127, '2023-10-05 22:24:23'),
(1240, '2000000.00', '0.00', '0.00', 2128, '2023-10-05 22:24:23'),
(1241, '3395000.00', '0.00', '0.00', 2129, '2023-10-05 22:24:23'),
(1242, '1495000.00', '0.00', '0.00', 2130, '2023-10-05 22:24:23'),
(1243, '3500000.00', '0.00', '0.00', 2131, '2023-10-05 22:24:23'),
(1244, '1595000.00', '0.00', '0.00', 2132, '2023-10-05 22:24:23'),
(1245, '1760000.00', '0.00', '0.00', 2133, '2023-10-05 22:24:23'),
(1246, '1700000.00', '0.00', '0.00', 2134, '2023-10-05 22:24:23'),
(1247, '595000.00', '0.00', '0.00', 2135, '2023-10-05 22:24:42'),
(1248, '2250000.00', '0.00', '0.00', 2136, '2023-10-05 22:24:42');

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `idproperties` int(11) NOT NULL,
  `website` varchar(45) DEFAULT NULL,
  `yearbuild` int(50) DEFAULT NULL,
  `insideM2` int(50) DEFAULT NULL,
  `outsideM2` int(50) DEFAULT NULL,
  `rooms` int(50) DEFAULT NULL,
  `floorLevels` int(50) DEFAULT NULL,
  `address_idaddress` int(11) NOT NULL,
  `houseNum_idhouse_num` int(11) DEFAULT NULL,
  `createdDate` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`idproperties`, `website`, `yearbuild`, `insideM2`, `outsideM2`, `rooms`, `floorLevels`, `address_idaddress`, `houseNum_idhouse_num`, `createdDate`) VALUES
(2067, 'Betri', 1985, 154, 602, 4, 2, 1741, 1875, '2023-10-05'),
(2068, 'Betri', 1926, 104, 179, 0, 3, 1742, 1876, '2023-10-05'),
(2069, 'Betri', 1959, 173, 137, 0, 4, 1743, 1877, '2023-10-05'),
(2070, 'Betri', 1952, 132, 305, 3, 3, 1744, 1878, '2023-10-05'),
(2071, 'Betri', 2023, 174, 305, 5, 2, 1745, 1879, '2023-10-05'),
(2072, 'Betri', 2018, 100, 450, 2, 1, 1746, 1880, '2023-10-05'),
(2073, 'Betri', 1990, 264, 500, 5, 2, 1747, 1881, '2023-10-05'),
(2074, 'Betri', 1918, 772, 173, 3, 3, 1748, 1882, '2023-10-05'),
(2075, 'Betri', 1924, 156, 137, 4, 3, 1749, 1883, '2023-10-05'),
(2076, 'Betri', 0, 0, 424, 0, 0, 1750, 1884, '2023-10-05'),
(2077, 'Betri', 1940, 150, 150, 5, 3, 1751, 1885, '2023-10-05'),
(2078, 'Betri', 1960, 134, 382, 0, 2, 1752, 1886, '2023-10-05'),
(2079, 'Betri', 2021, 83, 0, 2, 1, 1753, 1887, '2023-10-05'),
(2080, 'Betri', 2003, 360, 616, 5, 3, 1754, 1888, '2023-10-05'),
(2081, 'Betri', 1947, 555, 185, 0, 3, 1755, 1889, '2023-10-05'),
(2082, 'Betri', 1989, 0, 48, 0, 0, 1756, 1890, '2023-10-05'),
(2083, 'Betri', 0, 0, 5166, 0, 0, 1757, 1891, '2023-10-05'),
(2084, 'Betri', 0, 0, 510, 0, 0, 1758, 1892, '2023-10-05'),
(2085, 'Skyn', 2023, 81, 0, 2, 1, 1759, 1893, '2023-10-05'),
(2086, 'Skyn', 2021, 150, 341, 0, 2, 1760, 1894, '2023-10-05'),
(2087, 'Skyn', 2023, 81, 0, 2, 1, 1759, 1895, '2023-10-05'),
(2088, 'Skyn', 2023, 81, 0, 2, 1, 1759, 1896, '2023-10-05'),
(2089, 'Skyn', 2023, 81, 0, 2, 1, 1759, 1897, '2023-10-05'),
(2090, 'Skyn', 1900, 59, 40, 2, 3, 1761, 1898, '2023-10-05'),
(2091, 'Skyn', 2022, 198, 510, 3, 1, 1762, 1899, '2023-10-05'),
(2092, 'Skyn', 1949, 211, 926, 3, 3, 1763, 1900, '2023-10-05'),
(2093, 'Skyn', 1936, 172, 815, 4, 3, 1764, 1901, '2023-10-05'),
(2094, 'Skyn', 1910, 193, 450, 0, 3, 1765, 1902, '2023-10-05'),
(2095, 'Skyn', 0, 332, 179, 0, 3, 1766, 1903, '2023-10-05'),
(2096, 'Skyn', 0, 0, 0, 0, 0, 1767, 1904, '2023-10-05'),
(2097, 'Skyn', 2022, 132, 13693, 3, 1, 1768, 1905, '2023-10-05'),
(2098, 'Skyn', 0, 0, 4792, 0, 0, 1769, 1906, '2023-10-05'),
(2099, 'Skyn', 1905, 125, 105, 4, 3, 1770, 1907, '2023-10-05'),
(2100, 'Skyn', 1980, 272, 500, 3, 2, 1771, 1908, '2023-10-05'),
(2101, 'Skyn', 1978, 237, 1667, 6, 3, 1772, 1909, '2023-10-05'),
(2102, 'Skyn', 0, 0, 21129, 0, 0, 1773, 1910, '2023-10-05'),
(2103, 'Skyn', 0, 0, 602, 0, 0, 1774, 1911, '2023-10-05'),
(2104, 'Skyn', 0, 0, 1508, 0, 0, 1775, 1912, '2023-10-05'),
(2105, 'Skyn', 0, 0, 7583, 0, 0, 1776, 1913, '2023-10-05'),
(2106, 'Skyn', 0, 0, 622, 0, 0, 1777, 1914, '2023-10-05'),
(2107, 'Skyn', 0, 0, 5776, 0, 0, 1778, 1915, '2023-10-05'),
(2108, 'Skyn', 0, 0, 757, 0, 0, 1779, 1916, '2023-10-05'),
(2109, 'Skyn', 0, 0, 569, 0, 0, 1780, 1917, '2023-10-05'),
(2110, 'Skyn', 0, 0, 709, 0, 0, 1781, 1918, '2023-10-05'),
(2111, 'Skyn', 0, 0, 912, 0, 0, 1782, 1919, '2023-10-05'),
(2112, 'Skyn', 0, 0, 6213, 0, 0, 1783, 1920, '2023-10-05'),
(2113, 'Skyn', 0, 0, 498, 0, 0, 1784, 1921, '2023-10-05'),
(2114, 'Skyn', 0, 0, 688, 0, 0, 1785, 1922, '2023-10-05'),
(2115, 'Skyn', 0, 0, 27000, 0, 0, 1786, 1923, '2023-10-05'),
(2116, 'Skyn: Selt', 2023, 72, 0, 3, 1, 1787, 1924, '2023-10-05'),
(2117, 'Skyn: Selt', 1951, 188, 374, 4, 2, 1788, 1925, '2023-10-05'),
(2118, 'Skyn: Selt', 0, 217, 205, 6, 3, 1789, 1926, '2023-10-05'),
(2119, 'Skyn: Selt', 1920, 120, 323, 2, 2, 1790, 1927, '2023-10-05'),
(2120, 'Skyn: Selt', 2023, 72, 0, 3, 1, 1787, 1928, '2023-10-05'),
(2121, 'Skyn: Selt', 1965, 63, 92, 0, 0, 1791, 1929, '2023-10-05'),
(2122, 'Skyn: Selt', 2001, 169, 238, 4, 2, 1792, 1930, '2023-10-05'),
(2123, 'Skyn: Selt', 1908, 225, 1829, 4, 3, 1793, 1931, '2023-10-05'),
(2124, 'Skyn: Selt', 1968, 160, 152, 5, 3, 1794, 1932, '2023-10-05'),
(2125, 'Skyn: Selt', 1970, 262, 504, 6, 3, 1795, 1933, '2023-10-05'),
(2126, 'Skyn: Selt', 0, 0, 504, 0, 0, 1795, 1934, '2023-10-05'),
(2127, 'Skyn: Nyggj ogn', 2023, 117, 0, 3, 1, 1764, 1935, '2023-10-05'),
(2128, 'Skyn: Nyggj ogn', 0, 0, 617, 0, 0, 1796, 1936, '2023-10-05'),
(2129, 'Skyn: Nyggj ogn', 1990, 147, 302, 4, 1, 1797, 1937, '2023-10-05'),
(2130, 'Skyn: Nyggj ogn', 1900, 94, 199, 1, 3, 1798, 1938, '2023-10-05'),
(2131, 'Skyn: Nyggj ogn', 1986, 233, 781, 5, 2, 1799, 1939, '2023-10-05'),
(2132, 'Skyn: Nytt bod', 0, 0, 488, 0, 0, 1800, 1940, '2023-10-05'),
(2133, 'Skyn: Nytt bod', 1989, 42, 0, 1, 1, 1801, 1941, '2023-10-05'),
(2134, 'Skyn: Fasturprisur', 0, 0, 403, 0, 0, 1800, 1942, '2023-10-05'),
(2135, 'Betri', 0, 0, 597, 0, 0, 1802, 1943, '2023-10-05'),
(2136, 'Betri', 2021, 92, 0, 2, 1, 1803, 1944, '2023-10-05');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_properties`
-- (See below for the actual view)
--
CREATE TABLE `view_properties` (
`idproperties` int(11)
,`website` varchar(45)
,`yearbuild` int(50)
,`insideM2` int(50)
,`outsideM2` int(50)
,`rooms` int(50)
,`floorLevels` int(50)
,`addressName` varchar(255)
,`house_Num` varchar(45)
,`cityName` varchar(45)
,`cityPostNum` varchar(45)
,`suggestPrice` decimal(45,2)
,`latestBidPrice` decimal(45,2)
,`soldPrice` decimal(45,2)
);

-- --------------------------------------------------------

--
-- Structure for view `view_properties`
--
DROP TABLE IF EXISTS `view_properties`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_properties`  AS SELECT `p`.`idproperties` AS `idproperties`, `p`.`website` AS `website`, `p`.`yearbuild` AS `yearbuild`, `p`.`insideM2` AS `insideM2`, `p`.`outsideM2` AS `outsideM2`, `p`.`rooms` AS `rooms`, `p`.`floorLevels` AS `floorLevels`, `a`.`addressName` AS `addressName`, `h`.`house_num` AS `house_Num`, `c`.`cityName` AS `cityName`, `c`.`cityPostNum` AS `cityPostNum`, `s`.`suggestPrice` AS `suggestPrice`, `s`.`latestBidPrice` AS `latestBidPrice`, `s`.`soldPrice` AS `soldPrice` FROM ((((`properties` `p` join `address` `a` on(`p`.`address_idaddress` = `a`.`idaddress`)) join `house_num` `h` on(`p`.`houseNum_idhouse_num` = `h`.`idhouse_num`)) join `cities` `c` on(`a`.`cities_idCity` = `c`.`idCity`)) join `price_of_properties` `s` on(`p`.`idproperties` = `s`.`properties_idproperties`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`idaddress`,`cities_idCity`),
  ADD KEY `fk_address_cities` (`cities_idCity`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`idCity`);

--
-- Indexes for table `house_num`
--
ALTER TABLE `house_num`
  ADD PRIMARY KEY (`idhouse_num`),
  ADD KEY `fk_address_idaddress_idx` (`address_idaddress`);

--
-- Indexes for table `img_to_properties`
--
ALTER TABLE `img_to_properties`
  ADD PRIMARY KEY (`idimg_to_properties`),
  ADD KEY `fk_properties_idproperties_idx` (`properties_idproperties`);

--
-- Indexes for table `price_bids`
--
ALTER TABLE `price_bids`
  ADD PRIMARY KEY (`idpriceBids`,`properties_idproperties`),
  ADD KEY `fk_priceBids_properties1` (`properties_idproperties`);

--
-- Indexes for table `price_of_properties`
--
ALTER TABLE `price_of_properties`
  ADD PRIMARY KEY (`idpriceOfProperties`,`properties_idproperties`),
  ADD KEY `fk_price_of_properties_properties1` (`properties_idproperties`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`idproperties`),
  ADD KEY `fk_properties_address1` (`address_idaddress`),
  ADD KEY `fk_house_num_idhouse_num_idx` (`houseNum_idhouse_num`),
  ADD KEY `fk_house_num_idhouse_num_idex` (`houseNum_idhouse_num`),
  ADD KEY `fk_housenum_idhouseNum_idex` (`houseNum_idhouse_num`),
  ADD KEY `fk_housenum_idhouseNum_index` (`houseNum_idhouse_num`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `address`
--
ALTER TABLE `address`
  MODIFY `idaddress` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1804;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `idCity` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=501;

--
-- AUTO_INCREMENT for table `house_num`
--
ALTER TABLE `house_num`
  MODIFY `idhouse_num` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1945;

--
-- AUTO_INCREMENT for table `img_to_properties`
--
ALTER TABLE `img_to_properties`
  MODIFY `idimg_to_properties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102097;

--
-- AUTO_INCREMENT for table `price_bids`
--
ALTER TABLE `price_bids`
  MODIFY `idpriceBids` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `price_of_properties`
--
ALTER TABLE `price_of_properties`
  MODIFY `idpriceOfProperties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1249;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `idproperties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2137;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `address`
--
ALTER TABLE `address`
  ADD CONSTRAINT `fk_address_cities` FOREIGN KEY (`cities_idCity`) REFERENCES `cities` (`idCity`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `house_num`
--
ALTER TABLE `house_num`
  ADD CONSTRAINT `fk_address_idaddress` FOREIGN KEY (`address_idaddress`) REFERENCES `address` (`idaddress`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `img_to_properties`
--
ALTER TABLE `img_to_properties`
  ADD CONSTRAINT `fk_properties_idproperties` FOREIGN KEY (`properties_idproperties`) REFERENCES `properties` (`idproperties`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `price_bids`
--
ALTER TABLE `price_bids`
  ADD CONSTRAINT `fk_priceBids_properties1` FOREIGN KEY (`properties_idproperties`) REFERENCES `properties` (`idproperties`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `price_of_properties`
--
ALTER TABLE `price_of_properties`
  ADD CONSTRAINT `fk_price_of_properties_properties1` FOREIGN KEY (`properties_idproperties`) REFERENCES `properties` (`idproperties`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `fk_house_num_idhouse_num` FOREIGN KEY (`houseNum_idhouse_num`) REFERENCES `house_num` (`idhouse_num`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_properties_address1` FOREIGN KEY (`address_idaddress`) REFERENCES `address` (`idaddress`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
