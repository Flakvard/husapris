-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 13, 2023 at 11:30 AM
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
(1803, 'Flatnavegur ', 441),
(1804, 'Neyst - matr. ', 461),
(1805, 'Vallalíð ', 485),
(1806, 'Heiðavegur ', 455),
(1807, 'Bøgøta ', 485),
(1808, 'við Hornaveg, Oyri  ', 448),
(1809, 'Dalavegur ', 485),
(1810, 'Blikagøta ', 453),
(1811, 'Gróvargøta ', 480),
(1812, 'Blómubrekka ', 485),
(1813, 'Berjabrekka ', 485),
(1814, 'Æðugøta ', 453),
(1815, 'Bakkavegur ', 451),
(1816, 'Jatnavegur ', 432),
(1817, 'Við Sílá ', 489),
(1818, 'Á Merkrunum ', 457),
(1819, 'Kirkjuvegur ', 391),
(1820, 'Lágabø ', 490),
(1821, 'Argjavegur ', 380),
(1822, 'Oman Rygg ', 391),
(1823, 'Velbastaðvegur ', 485),
(1824, 'Vágsgeil ', 419),
(1825, 'Kráargøta ', 419),
(1826, 'Baraldsgøta ', 485),
(1827, 'Hvalvíksvegur ', 411),
(1828, 'Niðri í Túni ', 393),
(1829, 'Matr.nr. ', 411),
(1830, 'Torvheyggjur ', 390),
(1831, 'Raðhús í Brekkugerði ', 405),
(1832, 'Inni á Fløtum ', 415),
(1833, 'Lyngvegur ', 444),
(1834, 'Høganesvegur ', 484),
(1835, 'Varðagøta ', 485),
(1836, 'Ingibjargargøta ', 407),
(1837, 'Sýnarbrekkan ', 447),
(1838, 'á Hvítanesi ', 413),
(1839, 'Poul Juels gøta ', 485),
(1840, 'Kelduvegur ', 423),
(1841, 'við Myllutjørn ', 407),
(1842, 'í Heygnum ', 487),
(1843, 'Fornarætt ', 487),
(1844, 'Skotarók ', 485),
(1845, 'Bakkavegur ', 482),
(1846, 'Ovari Vegur ', 489),
(1847, 'Gaddavegur ', 437),
(1848, 'undir Hamri ', 411),
(1849, 'við Ánna ', 443),
(1850, 'Hvítanesvegur ', 407),
(1851, 'Maritugøta ', 407),
(1852, 'Vágsheygsgøta ', 419),
(1853, 'Heiðatrøðin ', 489),
(1854, 'Heimasandsvegur ', 458),
(1855, 'Beitisbrekka ', 396),
(1856, 'Magnus Heinasonar gøta ', 485),
(1857, 'Leynarvegur ', 429);

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
(1944, '73B', 1803),
(1945, '283e', 1804),
(1946, '50', 1751),
(1947, '13', 1805),
(1948, '40', 1753),
(1949, '26', 1806),
(1950, '1', 1794),
(1951, '42', 1760),
(1952, '30', 1741),
(1953, '7', 1797),
(1954, '6', 1807),
(1955, '400', 1808),
(1956, '8A', 1809),
(1957, '10', 1796),
(1958, '7', 1810),
(1959, '3A', 1807),
(1960, '2', 1811),
(1961, '24', 1801),
(1962, '120', 1812),
(1963, '183', 1813),
(1964, '13', 1814),
(1965, '25', 1815),
(1966, '33', 1816),
(1967, '9', 1817),
(1968, '1', 1818),
(1969, '1', 1819),
(1970, '15', 1820),
(1971, '21A', 1821),
(1972, '13', 1822),
(1973, '40', 1823),
(1974, '3', 1824),
(1975, '38', 1825),
(1976, '6', 1826),
(1977, '76', 1812),
(1978, '71', 1827),
(1979, '8', 1828),
(1980, '189', 1829),
(1981, '5', 1830),
(1982, '21', 1831),
(1983, '5', 1832),
(1984, '9', 1833),
(1985, '26', 1834),
(1986, '49', 1835),
(1987, '4D', 1836),
(1988, '4', 1837),
(1989, '38', 1838),
(1990, '3', 1839),
(1991, '4', 1840),
(1992, '36', 1841),
(1993, '138', 1842),
(1994, '24', 1752),
(1995, '1', 1843),
(1996, '28', 1760),
(1997, '9B', 1753),
(1998, '2', 1844),
(1999, '19', 1845),
(2000, '25', 1846),
(2001, '21', 1788),
(2002, '54', 1847),
(2003, '28B', 1848),
(2004, '12', 1849),
(2005, '7', 1850),
(2006, '20', 1742),
(2007, '69', 1851),
(2008, '32', 1852),
(2009, '42', 1753),
(2010, '24', 1853),
(2011, '93', 1854),
(2012, '2', 1855),
(2013, '15', 1856),
(2014, '7', 1857),
(2015, '40', 1834);

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
(102096, 'Norðoyri_Flatnavegur _73B_2021_Betri', 2136, NULL),
(102097, 'Signabøur_Neyst - matr. _283e_0_Betri', 2137, NULL),
(102098, 'Klaksvík_Garðavegur _50_0_Skyn', 2138, NULL),
(102099, 'Tórshavn_Vallalíð _13_1997_Betri', 2139, NULL),
(102100, 'Hoyvík_Karlamagnusarbreyt _40_2019_Betri', 2140, NULL),
(102101, 'Saltangará_Heiðavegur _26_1951_Skyn: Nyggj og', 2141, NULL),
(102102, 'Tórshavn_Kongagøta _1_1925_Skyn: Nyggj ogn', 2142, NULL),
(102103, 'Toftir_Lýðarsvegur _42_0_Skyn: Nyggj ogn', 2143, NULL),
(102104, 'Velbastaður_Gerðisbreyt _30_0_Betri', 2144, NULL),
(102105, 'Tórshavn_Øksnagerði _7_0_Betri', 2145, NULL),
(102106, 'Tórshavn_Bøgøta _6_2018_Betri', 2146, NULL),
(102107, 'Oyrarbakki_við Hornaveg, Oyri  _400_0_Betri', 2147, NULL),
(102108, 'Tórshavn_Dalavegur _8A_1940_Betri', 2148, NULL),
(102109, 'Tórshavn_Meinhartstrøð _10_0_Betri', 2149, NULL),
(102110, 'Runavík_Blikagøta _7_2012_Betri', 2150, NULL),
(102111, 'Tórshavn_Bøgøta _3A_1908_Betri', 2151, NULL),
(102112, 'Syðrugøta_Gróvargøta _2_1912_Betri', 2152, NULL),
(102113, 'Tórshavn_Vesturgøta _24_1989_Skyn', 2153, NULL),
(102114, 'Tórshavn_Blómubrekka _120_2008_Skyn: Nyggj og', 2154, NULL),
(102115, 'Tórshavn_Berjabrekka _183_1987_Skyn: Nyggj og', 2155, NULL),
(102116, 'Runavík_Æðugøta _13_2008_Skyn: Nyggj ogn', 2156, NULL),
(102117, 'Porkeri_Bakkavegur _25_1920_Skyn: Nyggj ogn', 2157, NULL),
(102118, 'Miðvágur_Jatnavegur _33_1947_Skyn: Nyggj ogn', 2158, NULL),
(102119, 'Tvøroyri_Við Sílá _9_1950_Betri', 2159, NULL),
(102120, 'Sandavágur_Á Merkrunum _1_1910_Betri', 2160, NULL),
(102121, 'Fuglafjørður_Kirkjuvegur _1_1933_Betri', 2161, NULL),
(102122, 'Vágur_Lágabø _15_1930_Skyn: Nyggj ogn', 2162, NULL),
(102123, 'Argir_Argjavegur _21A_2015_Betri', 2163, NULL),
(102124, 'Fuglafjørður_Oman Rygg _13_2022_Skyn: Nyggj o', 2164, NULL),
(102125, 'Tórshavn_Velbastaðvegur _40_1972_Skyn: Nyggj ', 2165, NULL),
(102126, 'Klaksvík_Vágsgeil _3_1965_Betri', 2166, NULL),
(102127, 'Klaksvík_Kráargøta _38_50_Betri', 2167, NULL),
(102128, 'Tórshavn_Baraldsgøta _6_2021_Skyn: Nyggj ogn', 2168, NULL),
(102129, 'Tórshavn_Blómubrekka _76_2008_Skyn: Nyggj ogn', 2169, NULL),
(102130, 'Hvalvík_Hvalvíksvegur _71_1972_Skyn: Nyggj og', 2170, NULL),
(102131, 'Funningur_Niðri í Túni _8_1926_Betri', 2171, NULL),
(102132, 'Hvalvík_Matr.nr. _189_0_Betri', 2172, NULL),
(102133, 'Froðba_Torvheyggjur _5_1947_Betri', 2173, NULL),
(102134, 'Hósvík_Raðhús í Brekkugerði _21_2024_Betri', 2174, NULL),
(102135, 'Kaldbak_Inni á Fløtum _5_1986_Betri', 2175, NULL),
(102136, 'Norðskáli_Lyngvegur _9_2016_Skyn: Nyggj ogn', 2176, NULL),
(102137, 'Toftir_Høganesvegur _26_0_Skyn: Nyggj ogn', 2177, NULL),
(102138, 'Tórshavn_Varðagøta _49_1977_Betri', 2178, NULL),
(102139, 'Hoyvík_Ingibjargargøta _4D_2023_Betri', 2179, NULL),
(102140, 'Oyndarfjørður_Sýnarbrekkan _4_0_Skyn: Nyggj o', 2180, NULL),
(102141, 'Hvítanes_á Hvítanesi _38_1912_Betri', 2181, NULL),
(102142, 'Tórshavn_Poul Juels gøta _3_1969_Betri', 2182, NULL),
(102143, 'Kunoy_Kelduvegur _4_1998_Betri', 2183, NULL),
(102144, 'Hoyvík_við Myllutjørn _36_2019_Betri', 2184, NULL),
(102145, 'Trongisvágur_í Heygnum _138_0_Betri', 2185, NULL),
(102146, 'Vágur_Bøgøta _24_1948_Skyn: Nyggj bod', 2186, NULL),
(102147, 'Trongisvágur_Fornarætt _1_1991_Skyn: Nyggj og', 2187, NULL),
(102148, 'Toftir_Lýðarsvegur _28_0_Skyn: Nyggj ogn', 2188, NULL),
(102149, 'Hoyvík_Karlamagnusarbreyt _9B_2021_Skyn: Nygg', 2189, NULL),
(102150, 'Tórshavn_Skotarók _2_0_Skyn: Nyggj ogn', 2190, NULL),
(102151, 'Sørvágur_Bakkavegur _19_1968_Skyn: Nyggj ogn', 2191, NULL),
(102152, 'Tvøroyri_Ovari Vegur _25_1955_Skyn: Nyggj ogn', 2192, NULL),
(102153, 'Tórshavn_Gripsvegur _21_1982_Skyn: Nyggj ogn', 2193, NULL),
(102154, 'Nes (Eysturoy)_Gaddavegur _54_2007_Skyn: Nygg', 2194, NULL),
(102155, 'Hvalvík_undir Hamri _28B_2007_Betri', 2195, NULL),
(102156, 'Norðragøta_við Ánna _12_2003_Betri', 2196, NULL),
(102157, 'Hoyvík_Hvítanesvegur _7_1968_Betri', 2197, NULL),
(102158, 'Sandavágur_Steigarbrekka _20_0_Skyn: Nyggj og', 2198, NULL),
(102159, 'Hoyvík_Maritugøta _69_2006_Skyn: Nyggj ogn', 2199, NULL),
(102160, 'Klaksvík_Vágsheygsgøta _32_1959_Skyn: Nyggj o', 2200, NULL),
(102161, 'Hoyvík_Karlamagnusarbreyt _42_2019_Skyn: Nygg', 2201, NULL),
(102162, 'Tvøroyri_Heiðatrøðin _24_0_Skyn: Nyggj ogn', 2202, NULL),
(102163, 'Sandur_Heimasandsvegur _93_0_Betri', 2203, NULL),
(102164, 'Glyvrar_Beitisbrekka _2_1952_Betri', 2204, NULL),
(102165, 'Tórshavn_Magnus Heinasonar gøta _15_0_Skyn: N', 2205, NULL),
(102166, 'Leynar_Leynarvegur _7_1965_Skyn: Nyggj ogn', 2206, NULL),
(102167, 'Toftir_Høganesvegur _40_1930_Skyn: Nyggj ogn', 2207, NULL);

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
(33, '1800000.00', '2023-10-09 10:00:00', 2073, '2023-10-05'),
(34, '1200000.00', '2023-09-11 11:00:00', 2068, '2023-10-05'),
(35, '3400000.00', '2023-10-03 10:00:00', 2116, '2023-10-05'),
(36, '650000.00', '0000-00-00 00:00:00', 2138, '2023-10-08'),
(37, '2450000.00', '2023-10-10 14:00:00', 2136, '2023-10-09'),
(38, '3200000.00', '2023-10-10 16:00:00', 2129, '2023-10-09'),
(39, '950000.00', '0000-00-00 00:00:00', 2130, '2023-10-24'),
(40, '3195000.00', '2023-10-26 10:00:00', 2154, '2023-10-24'),
(41, '375000.00', '2023-10-27 13:30:00', 2159, '2023-10-25'),
(42, '2400000.00', '2023-11-01 16:00:00', 2072, '2023-10-25'),
(43, '1100000.00', '2023-10-27 13:00:00', 2160, '2023-10-25'),
(44, '450000.00', '2023-10-26 16:00:00', 2157, '2023-10-25'),
(45, '3250000.00', '2023-10-30 10:00:00', 2154, '2023-10-26'),
(46, '500000.00', '2023-11-06 11:00:00', 2135, '2023-11-06'),
(47, '2400000.00', '2023-11-01 15:00:00', 2150, '2023-11-06'),
(48, '1300000.00', '0000-00-00 00:00:00', 2092, '2023-11-06'),
(49, '2100000.00', '2023-11-07 14:30:00', 2155, '2023-11-06'),
(50, '1800000.00', '2023-11-07 10:30:00', 2165, '2023-11-06'),
(51, '2490000.00', '2023-11-15 10:00:00', 2155, '2023-11-14'),
(52, '800000.00', '2023-11-20 14:30:00', 2171, '2023-11-16'),
(53, '3000000.00', '2023-11-20 11:30:00', 2168, '2023-11-16'),
(54, '2450000.00', '2023-11-29 15:30:00', 2150, '2023-11-30'),
(55, '380000.00', '2023-11-21 15:30:00', 2172, '2023-11-30'),
(56, '180000.00', '0000-00-00 00:00:00', 2177, '2023-11-30'),
(57, '2400000.00', '2023-12-04 12:00:00', 2181, '2023-11-30'),
(58, '4595000.00', '2023-12-01 16:00:00', 2182, '2023-11-30'),
(59, '300000.00', '2023-12-04 14:00:00', 2186, '2023-11-30'),
(60, '5000000.00', '2023-12-08 16:00:00', 2182, '2023-12-07'),
(61, '500000.00', '2023-12-07 16:00:00', 2186, '2023-12-07'),
(62, '1950000.00', '2023-12-11 12:00:00', 2195, '2023-12-07'),
(63, '5100000.00', '2023-12-13 15:00:00', 2182, '2023-12-13'),
(64, '2650000.00', '2023-12-22 12:00:00', 2175, '2023-12-13'),
(65, '2000000.00', '2023-12-15 12:00:00', 2148, '2023-12-13'),
(66, '1000000.00', '2023-12-13 15:00:00', 2180, '2023-12-13');

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
(1180, '1395000.00', '1200000.00', '0.00', 2068, '2023-10-05 23:09:05'),
(1181, '3595000.00', '0.00', '0.00', 2069, '2023-10-05 22:24:22'),
(1182, '1545000.00', '0.00', '0.00', 2070, '2023-10-05 22:24:22'),
(1183, '4700000.00', '0.00', '0.00', 2071, '2023-10-05 22:24:22'),
(1184, '2695000.00', '2400000.00', '0.00', 2072, '2023-10-25 21:54:22'),
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
(1204, '1585000.00', '1300000.00', '0.00', 2092, '2023-11-06 00:08:21'),
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
(1228, '3250000.00', '3400000.00', '0.00', 2116, '2023-10-05 23:09:05'),
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
(1241, '3395000.00', '3200000.00', '0.00', 2129, '2023-10-09 12:25:08'),
(1242, '1495000.00', '950000.00', '0.00', 2130, '2023-10-24 14:34:51'),
(1243, '3500000.00', '0.00', '0.00', 2131, '2023-10-05 22:24:23'),
(1244, '1595000.00', '0.00', '0.00', 2132, '2023-10-05 22:24:23'),
(1245, '1760000.00', '0.00', '0.00', 2133, '2023-10-05 22:24:23'),
(1246, '1700000.00', '0.00', '0.00', 2134, '2023-10-05 22:24:23'),
(1247, '595000.00', '500000.00', '0.00', 2135, '2023-11-06 00:08:21'),
(1248, '2250000.00', '2450000.00', '0.00', 2136, '2023-10-09 12:25:08'),
(1249, '600000.00', '0.00', '0.00', 2137, '2023-10-05 23:09:05'),
(1250, '700000.00', '650000.00', '0.00', 2138, '2023-10-08 09:14:13'),
(1251, '8250000.00', '0.00', '0.00', 2139, '2023-10-09 12:25:08'),
(1252, '2595000.00', '0.00', '0.00', 2140, '2023-10-09 12:25:08'),
(1253, '9000000.00', '0.00', '0.00', 2141, '2023-10-09 12:25:08'),
(1254, '3495000.00', '0.00', '0.00', 2142, '2023-10-09 12:25:08'),
(1255, '500000.00', '0.00', '0.00', 2143, '2023-10-09 12:25:08'),
(1256, '750000.00', '0.00', '0.00', 2144, '2023-10-18 12:06:55'),
(1257, '1545000.00', '0.00', '0.00', 2145, '2023-10-18 12:06:55'),
(1258, '3995000.00', '0.00', '0.00', 2146, '2023-10-18 12:06:55'),
(1259, '750000.00', '0.00', '0.00', 2147, '2023-10-18 12:06:55'),
(1260, '2750000.00', '2000000.00', '0.00', 2148, '2023-12-13 11:14:02'),
(1261, '1395000.00', '0.00', '0.00', 2149, '2023-10-18 12:06:55'),
(1262, '2695000.00', '2450000.00', '0.00', 2150, '2023-11-30 19:41:19'),
(1263, '3395000.00', '0.00', '0.00', 2151, '2023-10-18 12:06:55'),
(1264, '2100000.00', '0.00', '0.00', 2152, '2023-10-18 12:06:55'),
(1265, '1760000.00', '0.00', '0.00', 2153, '2023-10-18 12:06:55'),
(1266, '2995000.00', '3250000.00', '0.00', 2154, '2023-10-26 12:09:22'),
(1267, '2490000.00', '2490000.00', '0.00', 2155, '2023-11-14 10:58:47'),
(1268, '2400000.00', '0.00', '0.00', 2156, '2023-10-18 12:06:56'),
(1269, '695000.00', '450000.00', '0.00', 2157, '2023-10-25 21:54:23'),
(1270, '1850000.00', '0.00', '0.00', 2158, '2023-10-18 12:06:56'),
(1271, '200000.00', '375000.00', '0.00', 2159, '2023-10-25 21:54:22'),
(1272, '1345000.00', '1100000.00', '0.00', 2160, '2023-10-25 21:54:23'),
(1273, '1495000.00', '0.00', '0.00', 2161, '2023-10-24 14:34:51'),
(1274, '1200000.00', '0.00', '0.00', 2162, '2023-10-24 14:34:51'),
(1275, '4495000.00', '0.00', '0.00', 2163, '2023-10-25 21:54:23'),
(1276, '2995000.00', '0.00', '0.00', 2164, '2023-10-25 21:54:23'),
(1277, '1595000.00', '1800000.00', '0.00', 2165, '2023-11-06 00:08:21'),
(1278, '1950000.00', '0.00', '0.00', 2166, '2023-11-06 00:08:21'),
(1279, '2795000.00', '0.00', '0.00', 2167, '2023-11-06 00:08:21'),
(1280, '2900000.00', '3000000.00', '0.00', 2168, '2023-11-16 23:55:30'),
(1281, '2600000.00', '0.00', '0.00', 2169, '2023-11-06 00:08:21'),
(1282, '2395000.00', '0.00', '0.00', 2170, '2023-11-06 00:08:21'),
(1283, '645000.00', '800000.00', '0.00', 2171, '2023-11-16 23:55:29'),
(1284, '460000.00', '380000.00', '0.00', 2172, '2023-11-30 19:41:19'),
(1285, '750000.00', '0.00', '0.00', 2173, '2023-11-14 10:58:47'),
(1286, '998000.00', '0.00', '0.00', 2174, '2023-11-14 10:58:47'),
(1287, '2895000.00', '2650000.00', '0.00', 2175, '2023-12-13 11:14:02'),
(1288, '2800000.00', '0.00', '0.00', 2176, '2023-11-14 10:58:47'),
(1289, '300000.00', '180000.00', '0.00', 2177, '2023-11-30 19:41:19'),
(1290, '3495000.00', '0.00', '0.00', 2178, '2023-11-16 23:55:29'),
(1291, '3595000.00', '0.00', '0.00', 2179, '2023-11-16 23:55:29'),
(1292, '1200000.00', '1000000.00', '0.00', 2180, '2023-12-13 11:14:02'),
(1293, '2795000.00', '2400000.00', '0.00', 2181, '2023-11-30 20:07:58'),
(1294, '4595000.00', '5100000.00', '0.00', 2182, '2023-12-13 11:14:02'),
(1295, '1650000.00', '0.00', '0.00', 2183, '2023-11-30 19:41:19'),
(1296, '4495000.00', '0.00', '0.00', 2184, '2023-11-30 19:41:19'),
(1297, '350000.00', '0.00', '0.00', 2185, '2023-11-30 19:41:19'),
(1298, '500000.00', '500000.00', '0.00', 2186, '2023-12-07 14:40:41'),
(1299, '1950000.00', '0.00', '0.00', 2187, '2023-11-30 19:41:19'),
(1300, '398000.00', '0.00', '0.00', 2188, '2023-11-30 19:41:19'),
(1301, '2995000.00', '0.00', '0.00', 2189, '2023-11-30 19:41:19'),
(1302, '2000000.00', '0.00', '0.00', 2190, '2023-11-30 22:16:11'),
(1303, '1750000.00', '0.00', '0.00', 2191, '2023-11-30 22:16:11'),
(1304, '1095000.00', '0.00', '0.00', 2192, '2023-11-30 22:16:11'),
(1305, '4695000.00', '0.00', '0.00', 2193, '2023-11-30 22:16:11'),
(1306, '2600000.00', '0.00', '0.00', 2194, '2023-11-30 22:20:57'),
(1307, '1895000.00', '1950000.00', '0.00', 2195, '2023-12-07 14:42:12'),
(1308, '3995000.00', '0.00', '0.00', 2196, '2023-12-07 14:40:41'),
(1309, '4100000.00', '0.00', '0.00', 2197, '2023-12-07 14:40:41'),
(1310, '2695000.00', '0.00', '0.00', 2198, '2023-12-07 14:40:41'),
(1311, '3995000.00', '0.00', '0.00', 2199, '2023-12-07 14:40:41'),
(1312, '2100000.00', '0.00', '0.00', 2200, '2023-12-07 14:40:41'),
(1313, '2750000.00', '0.00', '0.00', 2201, '2023-12-07 14:42:13'),
(1314, '390000.00', '0.00', '0.00', 2202, '2023-12-07 14:42:13'),
(1315, '895000.00', '0.00', '0.00', 2203, '2023-12-13 11:14:02'),
(1316, '2250000.00', '0.00', '0.00', 2204, '2023-12-13 11:14:02'),
(1317, '7700000.00', '0.00', '0.00', 2205, '2023-12-13 11:14:02'),
(1318, '3300000.00', '0.00', '0.00', 2206, '2023-12-13 11:14:02'),
(1319, '1650000.00', '0.00', '0.00', 2207, '2023-12-13 11:14:02');

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
(2136, 'Betri', 2021, 92, 0, 2, 1, 1803, 1944, '2023-10-05'),
(2137, 'Betri', 0, 63, 93, 0, 2, 1804, 1945, '2023-10-05'),
(2138, 'Skyn', 0, 0, 355, 0, 0, 1751, 1946, '2023-10-05'),
(2139, 'Betri', 1997, 349, 586, 4, 2, 1805, 1947, '2023-10-09'),
(2140, 'Betri', 2019, 62, 0, 2, 1, 1753, 1948, '2023-10-09'),
(2141, 'Skyn: Nyggj ogn', 1951, 672, 539, 0, 3, 1806, 1949, '2023-10-09'),
(2142, 'Skyn: Nyggj ogn', 1925, 156, 123, 3, 3, 1794, 1950, '2023-10-09'),
(2143, 'Skyn: Nyggj ogn', 0, 0, 676, 0, 0, 1760, 1951, '2023-10-09'),
(2144, 'Betri', 0, 0, 525, 0, 0, 1741, 1952, '2023-10-18'),
(2145, 'Betri', 0, 0, 504, 0, 0, 1797, 1953, '2023-10-18'),
(2146, 'Betri', 2018, 126, 157, 2, 2, 1807, 1954, '2023-10-18'),
(2147, 'Betri', 0, 0, 11425, 0, 0, 1808, 1955, '2023-10-18'),
(2148, 'Betri', 1940, 246, 444, 0, 3, 1809, 1956, '2023-10-18'),
(2149, 'Betri', 0, 0, 614, 0, 0, 1796, 1957, '2023-10-18'),
(2150, 'Betri', 2012, 79, 76, 2, 1, 1810, 1958, '2023-10-18'),
(2151, 'Betri', 1908, 101, 83, 2, 3, 1807, 1959, '2023-10-18'),
(2152, 'Betri', 1912, 127, 250, 3, 3, 1811, 1960, '2023-10-18'),
(2153, 'Skyn', 1989, 42, 0, 1, 1, 1801, 1961, '2023-10-18'),
(2154, 'Skyn: Nyggj ogn', 2008, 106, 0, 2, 1, 1812, 1962, '2023-10-18'),
(2155, 'Skyn: Nyggj ogn', 1987, 65, 0, 2, 1, 1813, 1963, '2023-10-18'),
(2156, 'Skyn: Nyggj ogn', 2008, 79, 0, 2, 1, 1814, 1964, '2023-10-18'),
(2157, 'Skyn: Nyggj ogn', 1920, 131, 300, 4, 3, 1815, 1965, '2023-10-18'),
(2158, 'Skyn: Nyggj ogn', 1947, 338, 198, 5, 3, 1816, 1966, '2023-10-18'),
(2159, 'Betri', 1950, 222, 441, 4, 3, 1817, 1967, '2023-10-24'),
(2160, 'Betri', 1910, 196, 397, 6, 3, 1818, 1968, '2023-10-24'),
(2161, 'Betri', 1933, 119, 193, 3, 3, 1819, 1969, '2023-10-24'),
(2162, 'Skyn: Nyggj ogn', 1930, 179, 230, 2, 3, 1820, 1970, '2023-10-24'),
(2163, 'Betri', 2015, 225, 338, 5, 3, 1821, 1971, '2023-10-25'),
(2164, 'Skyn: Nyggj ogn', 2022, 177, 580, 4, 1, 1822, 1972, '2023-10-25'),
(2165, 'Skyn: Nyggj ogn', 1972, 256, 476, 5, 3, 1823, 1973, '2023-10-25'),
(2166, 'Betri', 1965, 184, 295, 6, 2, 1824, 1974, '2023-11-06'),
(2167, 'Betri', 50, 237, 360, 5, 3, 1825, 1975, '2023-11-06'),
(2168, 'Skyn: Nyggj ogn', 2021, 156, 347, 0, 2, 1826, 1976, '2023-11-06'),
(2169, 'Skyn: Nyggj ogn', 2008, 64, 0, 2, 1, 1812, 1977, '2023-11-06'),
(2170, 'Skyn: Nyggj ogn', 1972, 325, 2481, 6, 3, 1827, 1978, '2023-11-06'),
(2171, 'Betri', 1926, 113, 107, 3, 3, 1828, 1979, '2023-11-14'),
(2172, 'Betri', 0, 0, 1719, 0, 0, 1829, 1980, '2023-11-14'),
(2173, 'Betri', 1947, 171, 716, 3, 2, 1830, 1981, '2023-11-14'),
(2174, 'Betri', 2024, 82, 0, 2, 1, 1831, 1982, '2023-11-14'),
(2175, 'Betri', 1986, 242, 532, 5, 2, 1832, 1983, '2023-11-14'),
(2176, 'Skyn: Nyggj ogn', 2016, 181, 700, 4, 2, 1833, 1984, '2023-11-14'),
(2177, 'Skyn: Nyggj ogn', 0, 0, 625, 0, 0, 1834, 1985, '2023-11-14'),
(2178, 'Betri', 1977, 123, 524, 2, 1, 1835, 1986, '2023-11-16'),
(2179, 'Betri', 2023, 97, 0, 3, 1, 1836, 1987, '2023-11-16'),
(2180, 'Skyn: Nyggj ogn', 0, 158, 329, 4, 2, 1837, 1988, '2023-11-16'),
(2181, 'Betri', 1912, 272, 517, 4, 3, 1838, 1989, '2023-11-30'),
(2182, 'Betri', 1969, 301, 816, 7, 2, 1839, 1990, '2023-11-30'),
(2183, 'Betri', 1998, 127, 574, 3, 2, 1840, 1991, '2023-11-30'),
(2184, 'Betri', 2019, 195, 213, 4, 3, 1841, 1992, '2023-11-30'),
(2185, 'Betri', 0, 0, 750, 0, 0, 1842, 1993, '2023-11-30'),
(2186, 'Skyn: Nyggj bod', 1948, 140, 244, 2, 2, 1752, 1994, '2023-11-30'),
(2187, 'Skyn: Nyggj ogn', 1991, 169, 638, 3, 1, 1843, 1995, '2023-11-30'),
(2188, 'Skyn: Nyggj ogn', 0, 0, 703, 0, 0, 1760, 1996, '2023-11-30'),
(2189, 'Skyn: Nyggj ogn', 2021, 104, 0, 2, 1, 1753, 1997, '2023-11-30'),
(2190, 'Skyn: Nyggj ogn', 0, 0, 522, 0, 0, 1844, 1998, '2023-11-30'),
(2191, 'Skyn: Nyggj ogn', 1968, 185, 630, 4, 2, 1845, 1999, '2023-11-30'),
(2192, 'Skyn: Nyggj ogn', 1955, 174, 445, 5, 2, 1846, 2000, '2023-11-30'),
(2193, 'Skyn: Nyggj ogn', 1982, 259, 372, 5, 3, 1788, 2001, '2023-11-30'),
(2194, 'Skyn: Nyggj ogn', 2007, 155, 638, 3, 2, 1847, 2002, '2023-11-30'),
(2195, 'Betri', 2007, 185, 283, 5, 3, 1848, 2003, '2023-12-07'),
(2196, 'Betri', 2003, 419, 738, 0, 2, 1849, 2004, '2023-12-07'),
(2197, 'Betri', 1968, 301, 1173, 4, 2, 1850, 2005, '2023-12-07'),
(2198, 'Skyn: Nyggj ogn', 0, 162, 290, 3, 2, 1742, 2006, '2023-12-07'),
(2199, 'Skyn: Nyggj ogn', 2006, 120, 132, 3, 2, 1851, 2007, '2023-12-07'),
(2200, 'Skyn: Nyggj ogn', 1959, 160, 291, 4, 3, 1852, 2008, '2023-12-07'),
(2201, 'Skyn: Nyggj ogn', 2019, 85, 0, 2, 1, 1753, 2009, '2023-12-07'),
(2202, 'Skyn: Nyggj ogn', 0, 0, 575, 0, 0, 1853, 2010, '2023-12-07'),
(2203, 'Betri', 0, 116, 707, 0, 3, 1854, 2011, '2023-12-13'),
(2204, 'Betri', 1952, 272, 1000, 5, 3, 1855, 2012, '2023-12-13'),
(2205, 'Skyn: Nyggj ogn', 0, 316, 171, 5, 3, 1856, 2013, '2023-12-13'),
(2206, 'Skyn: Nyggj ogn', 1965, 173, 964, 3, 2, 1857, 2014, '2023-12-13'),
(2207, 'Skyn: Nyggj ogn', 1930, 120, 383, 3, 3, 1834, 2015, '2023-12-13');

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
,`lastUpdate` datetime
,`soldPrice` decimal(45,2)
);

-- --------------------------------------------------------

--
-- Structure for view `view_properties`
--
DROP TABLE IF EXISTS `view_properties`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_properties`  AS SELECT `p`.`idproperties` AS `idproperties`, `p`.`website` AS `website`, `p`.`yearbuild` AS `yearbuild`, `p`.`insideM2` AS `insideM2`, `p`.`outsideM2` AS `outsideM2`, `p`.`rooms` AS `rooms`, `p`.`floorLevels` AS `floorLevels`, `a`.`addressName` AS `addressName`, `h`.`house_num` AS `house_Num`, `c`.`cityName` AS `cityName`, `c`.`cityPostNum` AS `cityPostNum`, `s`.`suggestPrice` AS `suggestPrice`, `s`.`latestBidPrice` AS `latestBidPrice`, `s`.`lastUpdate` AS `lastUpdate`, `s`.`soldPrice` AS `soldPrice` FROM ((((`properties` `p` join `address` `a` on(`p`.`address_idaddress` = `a`.`idaddress`)) join `house_num` `h` on(`p`.`houseNum_idhouse_num` = `h`.`idhouse_num`)) join `cities` `c` on(`a`.`cities_idCity` = `c`.`idCity`)) join `price_of_properties` `s` on(`p`.`idproperties` = `s`.`properties_idproperties`)) ;

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
  ADD UNIQUE KEY `properties_idproperties_UNIQUE` (`properties_idproperties`),
  ADD KEY `fk_properties_idproperties_idx` (`properties_idproperties`);

--
-- Indexes for table `price_bids`
--
ALTER TABLE `price_bids`
  ADD PRIMARY KEY (`idpriceBids`,`properties_idproperties`),
  ADD KEY `properties_idproperties_idx` (`properties_idproperties`);

--
-- Indexes for table `price_of_properties`
--
ALTER TABLE `price_of_properties`
  ADD PRIMARY KEY (`idpriceOfProperties`,`properties_idproperties`),
  ADD UNIQUE KEY `properties_idproperties_UNIQUE` (`properties_idproperties`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`idproperties`),
  ADD KEY `fk_properties_address1` (`address_idaddress`),
  ADD KEY `fk_house_num_idhouse_num_idx` (`houseNum_idhouse_num`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `address`
--
ALTER TABLE `address`
  MODIFY `idaddress` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1858;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `idCity` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=501;

--
-- AUTO_INCREMENT for table `house_num`
--
ALTER TABLE `house_num`
  MODIFY `idhouse_num` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2016;

--
-- AUTO_INCREMENT for table `img_to_properties`
--
ALTER TABLE `img_to_properties`
  MODIFY `idimg_to_properties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102168;

--
-- AUTO_INCREMENT for table `price_bids`
--
ALTER TABLE `price_bids`
  MODIFY `idpriceBids` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `price_of_properties`
--
ALTER TABLE `price_of_properties`
  MODIFY `idpriceOfProperties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1320;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `idproperties` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2208;

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
