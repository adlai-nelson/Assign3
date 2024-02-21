# Assignment 3 of IDCE 376: Spatial Databases
Adlai Nelson


## Introduction

Data normalization standards are used to reduce redundancy and simplify datasets. 
In this assignment, we normalize datasets to 3NF and 4NF

To use scripts.sql, first create a new postgresql database (with postgis enabled), then run the contents of scripts.sql in the environment of your choice.

## Methods

This project took place using the pgAdmin 4 for PostgreSQL, and extensively used the postgis extension. 
This input dataset was 1NF compliant, as all the values are atomic, have unique attribute names, have the same variable type, and do not depend on order.
The input dataset was also 2NF compliant, as there was no partial dependance, becuase there was not a compound key

To normalize the dataset to 3NF, transative dependancies needed to be eliminated. 
The state, country, and citypopulation variables are all dependant on the 'city' variable, not the primary key.
To resolve this, a new table was created, with 'city' as the primary key. 
Unique cities and the state, country, and citypopulation variables were added.
These columns were then dropped from the PropertyDetails table.
The resulting data structure is 3NF compliant, as there are no transitive dependancies 
(ie. no columns rely on other non-primary key attributes). This is becuase 'city' is the primary key in the CityDemographics table.

To normalize the dataset to 4NF, we need to eliminate multi-valued dependancies, where attributes that are independ of one another both depend on the primary key.
Becuase Zoning and Utilities are both indipendant attributes of propertyID but not related to one another, we need to create two additional tables. 
The PropertyUtilities and PropertyZoning tables were populated with PropertyID and Utility name variables. 
The 4NF compliant data structure consists of four seperate tables: PropertyZoning, PropertyUtilities, PropertyDetails, and CityDemographics.
In this data structure, each indipendant attribute related to the primary key, but not other attribues, gets it's own table.
In the PropertyDetails table, the 'city' and 'address' variables are both dependant on the primary key, but they also inform one another, so they do not need to be split. 

Additional spatial queries were run as well. 
Firstly, the `ST_DWithin` function was used to find all properties within one mile of Clark University. 
Only one property was within this distance (see table 1).
Additionally, the `ST_Distance` function was used to calculate the distance from each property to Clark U (see table 2).


## Results

Table 1: Properties within 1 mile of Clark U

|Address | City |
| ------ | ---- |
| 123 STREET RD | Worcester   |


Table 2: Distance from each property to Clark U 

| Address     | City        | Distance From Clark U (m) |
| ----------- | ----------- | --------------------- |
| 123 STREET RD| Worcester   | 1303         |
| 567 ROAD BLVD| Worcester   | 1976       |
| 100 ROAD ST | Worcester   | 2252         |
| 250 WEST ST| Auburn      | 2308         |
| 333 EAST ST| Auburn      | 2389         |
| 246 WATER ST| Auburn      | 2553         |
| 050 1ST STREET| Worcester   | 2596       |
| 987 2ND ST| Auburn      | 3624         |

