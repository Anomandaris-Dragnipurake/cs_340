-- Active: 1720982518894@@127.0.0.1@3306@step3ddl

-- Airports
-- Create a new Airport
-- Variables: :AirportName, :City, :Country
INSERT INTO `Airports` (`Airport_Name`, `Airport_City`, `Airport_Country`)
VALUES (:AirportName, :City, :Country);

-- Read all airports
SELECT * FROM airports;

-- Read airports with a country filter
-- Variables: :Country
SELECT * FROM airports WHERE `Airport_Country` = :Country;

-- Update an airport
-- Variables: :AirportName, :City, :Country, :AirportID
UPDATE airports
SET `Airport_Name` = :AirportName, 
`Airport_City` = :City, 
`Airport_Country`=:Country 
WHERE `Airport_ID` = :AirportID;

-- Delete an airport
-- Variables: :AirportID
DELETE FROM airports WHERE `Airport_ID` = :AirportID;

-- Travel_Classes
-- Create a new Travel Class
-- Variables: :TCName, :Cost
INSERT INTO travel_classes (`Travel_Class_Name`, `Travel_Class_Cost`)
VALUES (:TCName, :Cost);

-- Read all travel classes
SELECT * FROM travel_classes;

-- Update a travel class
-- Variables: :TCName, :Cost :TCID
UPDATE travel_classes
SET `Travel_Class_Name` = :TCName, 
`Travel_Class_Cost` = :Cost 
WHERE `Travel_Class_ID` = :TCID;

-- Delete  travel class
-- Variables: :TCID
DELETE FROM travel_classes WHERE `Travel_Class_ID` = :TCID;

-- Airplane_Types
-- Create a new airplane type
-- Variables: :APType
INSERT INTO airplane_types (`Airplane_Type`) VALUES (:APType);

-- Read all airplane types
SELECT * FROM airplane_types;

-- Update an airplane type
-- Variables: :APType, :ATID
UPDATE airplane_types
SET `Airplane_Type` = :APType
WHERE `Airplane_Type_ID` = :ATID;

-- Delete airplane type
-- Variables: :ATID
DELETE FROM airplane_types WHERE `Airplane_Type_ID` = :ATID;

-- Airplane Travel Class
-- Create a new airplane travel class
-- Variables: :APType, :TravelClass, :Capacity
INSERT INTO airplane_travel_classes (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`)
 VALUES ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :APType), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = :TravelClass), :Capacity);

-- Read all airplane travel classes
SELECT * FROM airplane_travel_classes;

-- Read all travel classes for a specific airplane type
-- Variables: :APType
SELECT * 
FROM airplane_travel_classes 
INNER JOIN airplane_types ON airplane_travel_classes.`Airplane_Type_ID` = airplane_types.`Airplane_Type_ID`
WHERE airplane_types.`Airplane_Type` = :APType;

-- Update an airplane travel class
-- Variables: :Capacity, :ATCID
UPDATE airplane_travel_classes
SET `Travel_Class_Capacity` = :`Travel_Class_Capacity`
WHERE `Airplane_Travel_Classes_ID` = :ATCID;

-- Delete airplane travel class
-- Variables: :ATCID
DELETE FROM airplane_travel_classes WHERE `Airplane_Travel_Classes_ID` = :ATCID;

-- Flights
-- Insert a new flight
-- Variables: :Departure, :Arrival, :Origin, :Destination, :Airplane_Type
INSERT INTO `Flights` (
    `Departure_Date_Time`,
    `Arrival_Date_Time`,
    `Origin_Airport_ID`,
    `Destination_Airport_ID`,
    `Airplane_Type_ID`
) VALUES (
    :Departure,
    :Arrival,
    (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Origin),
    (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Destination),
    (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :Airplane_Type)
);

-- Retrieve all flights from a specific airport
-- Variable: :Origin
SELECT *
FROM `Flights`
WHERE `Origin_Airport_ID` = :Origin_Airport_ID;

-- Retrieve all flights from a specific airport
-- Variable: :Origin
SELECT *
FROM `Flights`
INNER JOIN airports ON `Flights`.`Origin_Airport_ID`=airports.`Airport_ID`
WHERE airports.`Airport_Name` = :Origin;

-- Retrieve all flights to a specific airport
-- Variable: :Destination
SELECT *
FROM `Flights`
INNER JOIN airports ON `Flights`.`Destination_Airport_ID`=airports.`Airport_ID`
WHERE airports.`Airport_Name` = :Destination;

-- Retrieve all flights in a specific duration
-- Variable: :Departure, :Arrival
SELECT *
FROM `Flights`
WHERE `Departure_Date_Time` >= :Departure AND `Arrival_Date_Time` <= :Arrival

-- Update a flight
-- Variables: :Departure, :Arrival, :Origin, :Destination, :Airplane_Type, :Flight
UPDATE `Flights` 
SET `Departure_Date_Time` = :Departure,
    `Arrival_Date_Time` = :Arrival,
    `Origin_Airport_ID`= :Origin,
    `Destination_Airport_ID` = :Destination,
    `Airplane_Type_ID` = :Airplane_Type
WHERE `Flight_ID` = :Flight


-- Delete a flight
-- Variable: :Flight_ID
DELETE FROM `Flights` WHERE `Flight_ID` = :Flight_ID;

-- Seats
-- Insert a new seat
-- Variables: :Class, :Flight, :SeatNumber
INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`)
VALUES ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = :Class),
:Flight, :SeatNumber, 1, NULL);

-- Update seat availability
-- Variables: :Seat_Number, :Flight_ID, :Passenger_Name

UPDATE `Seats`
SET `Available` = 0, `Passenger_Name` = :Passenger_Name
WHERE `Seat_Number` = :Seat_Number AND `Flight_ID` = :Flight_ID;

-- Find all available seats on a specific flight
-- Variable: :Flight_ID

SELECT *
FROM `Seats`
WHERE `Flight_ID` = :Flight_ID AND `Available` = 1;

-- Delete a seat
-- Variable: :Seat_ID
DELETE FROM `Seats` WHERE `Seat_ID` = :Seat_ID;

-- List all airports in a specific country
-- Variable: :Airport_Country

SELECT * FROM `Airports` WHERE `Airport_Country` = :Airport_Country;

-- Calculate total seats sold for a specific flight
-- Variable: :Flight_ID

SELECT COUNT(*) AS `Total_Seats_Sold`
FROM `Seats`
WHERE `Flight_ID` = :Flight_ID AND `Available` = 0;

-- Retrieve all flights with a specific airplane type
-- Variable: :Airplane_Type_ID

SELECT * FROM `Flights` WHERE `Airplane_Type_ID` = :Airplane_Type_ID;

-- Retrieve all travel classes for a specific airplane type
-- Variable: :Airplane_Type_ID

SELECT `tc`.`Travel_Class_Name`, `atc`.`Travel_Class_Capacity`
FROM `Airplane_Travel_Classes` `atc`
JOIN `Travel_Classes` `tc` ON `atc`.`Travel_Class_ID` = `tc`.`Travel_Class_ID`
WHERE `atc`.`Airplane_Type_ID` = :Airplane_Type_ID;

-- Retrieve all flights between two airports
-- Variables: :Origin_Airport_ID, :Destination_Airport_ID

SELECT *
FROM `Flights`
WHERE `Origin_Airport_ID` = :Origin_Airport_ID
  AND `Destination_Airport_ID` = :Destination_Airport_ID;

-- Update flight time
-- Variables: :Departure_Date_Time, :Arrival_Date_Time, :Flight_ID

UPDATE `Flights`
SET `Departure_Date_Time` = :Departure_Date_Time,
    `Arrival_Date_Time` = :Arrival_Date_Time
WHERE `Flight_ID` = :Flight_ID;