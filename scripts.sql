-----------------Setup-----------------
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create PropertyDetails table
CREATE TABLE PropertyDetails (
    PropertyID SERIAL PRIMARY KEY, -- Serial data type: auto-incrimenting integer
    Address VARCHAR(255), -- Variable Character 
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    ZoningType VARCHAR(255),
    Utility VARCHAR(255),
    GeoLocation GEOMETRY(Point, 4326), -- Geometry data type with SRID 4326
    CityPopulation INT -- Intiger
);

-- Due to the large number of data fields, there were only 8 properies input
-- Data was fabricated for the purposes of this assignment, points were taken in semi-random pattern in respective cities
INSERT INTO PropertyDetails (Address, City, State, Country, ZoningType, Utility, Geolocation, CityPopulation)VALUES
('123 STREET RD', 'WORCESTER', 'MA', 'USA', 'SINGLE FAMILY', 'WATER', ST_GeomFromText('POINT(42.2621462 -71.8353757)', 4326), '205918'),
('100 ROAD ST', 'WORCESTER', 'MA', 'USA', 'SINGLE FAMILY', 'GAS', ST_GeomFromText('POINT(42.3076588 -71.8341473)', 4326), '205918'),
('050 1ST STREET', 'WORCESTER', 'MA', 'USA', 'GENERAL RETAIL BUISNESS', 'ELECTRICITY', ST_GeomFromText('POINT(42.2565582 -71.8009761)', 4326), '205918'),
('567 ROAD BLVD', 'WORCESTER', 'MA', 'USA', 'TWO FAMILY', 'WATER', ST_GeomFromText('POINT(42.2874937 -71.8105226)', 4326), '205918'),
('987 2ND ST', 'AUBURN', 'MA', 'USA', 'SINGLE FAMILY', 'GAS', ST_GeomFromText('POINT(42.206857 -71.8535504)', 4326), '16889'),
('250 WEST ST', 'AUBURN', 'MA', 'USA', 'TWO FAMILY', 'ELECTRICITY', ST_GeomFromText('POINT(42.2127055 -71.8409923)', 4326), '16889'),
('246 WATER ST', 'AUBURN', 'MA', 'USA', 'SINGLE FAMILY', 'GAS', ST_GeomFromText('POINT(42.189948 -71.8366816)', 4326), '16889'),
('333 EAST ST', 'AUBURN', 'MA', 'USA', 'GENERAL RETAIL BUISNESS', 'WATER', ST_GeomFromText('POINT(42.2007768 -71.8386448)', 4326), '16889')

-- View table and ensure that it is 1NF and 2NF compliant
SELECT * FROM PropertyDetails;
-----------------Normalize to 3NF-----------------

-- Create City Demographics table, these variables are dependant on the City variable, not the PropertyID variable
CREATE TABLE CityDemographics (
    City VARCHAR(255) PRIMARY KEY, -- City is primary key
    State VARCHAR(255),
    Country VARCHAR(255),
    CityPopulation INT
);

-- Manually insert values to CityDemographics 
INSERT INTO CityDemographics (City, State, Country, CityPopulation) VALUES
('WORCESTER', 'MA', 'USA', 205918),
('AUBURN', 'MA', 'USA', 16889)

-- Remove columns from PropertyDetails 
ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;

-- Add Forign key constraint to PropertyDetails
ALTER TABLE PropertyDetails
    ADD CONSTRAINT city FOREIGN KEY (City) REFERENCES CityDemographics(City);
	
-- View data to confirm 3NF compliance
SELECT * FROM PropertyDetails;
SELECT * FROM CityDemographics;

-----------------Normalize to 4NF-----------------

-- Zoning and Utilities are indipendant of one another, but both depend on PropertyID.
-- Create PropertyZoning table with foreign key PropertyID
CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(255)
);
-- Create PropertyUtilities table with foreign key PropertyID
CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(255)
);
-- Insert PropertyID and ZoningType into PropertyZoning table
INSERT INTO PropertyZoning (PropertyID, ZoningType)
SELECT PropertyID, ZoningType
FROM PropertyDetails
ORDER BY PropertyID;
-- Insert PropertyID and Utility into PropertyUtilities table
INSERT INTO PropertyUtilities (PropertyID, Utility)
SELECT PropertyID, Utility
FROM PropertyDetails
ORDER BY PropertyID;

-- Remove Uneccisarry columns from PropertyDetails
ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;

-- View Finalized Dataset to confirm 4NF compliance
SELECT * FROM PropertyZoning;
SELECT * FROM PropertyUtilities;
SELECT * FROM PropertyDetails;
SELECT * FROM CityDemographics;

-----------------Perform Spatial Queries-----------------

-- Find properties within 1 mile of Clark University (Coordinates: 42.251389 -71.8241867)
SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation::geography,  -- Cast to geography so units are in meters not degrees.
    ST_GeomFromText('POINT( 42.251389 -71.8241867)', 4326)::geography,
    1609 -- 1 mile radius (1609m = 1 mile)
);

-- Only 1 property is within a mile of Clark U.
-- What if we want the distance in meters from Clark U to each property?

-- Create ClarkU table, containing Name and geom variables
CREATE TABLE ClarkU (Name VARCHAR(255), geom GEOMETRY(Point, 4326));
-- Insert Name and geom values
INSERT INTO ClarkU VALUES ('CLARKU', ST_GeomFromText('POINT( 42.251389 -71.8241867)', 4326));


-- Calculate distance from ClarkU for each property, and order by distance
SELECT address, city, ST_Distance(PropertyDetails.GeoLocation::geography,ClarkU.geom::geography) as Dist_ClarkU
	FROM PropertyDetails, ClarkU
	ORDER BY Dist_ClarkU;

-- CREDIT: https://stackoverflow.com/questions/60349562/postgis-calculate-distances-from-one-point-to-multiple-points

