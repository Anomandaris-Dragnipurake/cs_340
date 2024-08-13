-- Data Manipulation Queries
-- Group 3: Eric McElhinny, Andrew Chi

-- Airports
-- Create a new Airport
-- Variables: :AirportName, :City, :Country
INSERT INTO `Airports` (`Airport_Name`, `Airport_City`, `Airport_Country`)
VALUES (:AirportName, :City, :Country);

-- Read all airports
SELECT * FROM airports;

-- Return a specific Airport
-- Variables: :ID
SELECT * FROM Airports WHERE Airport_ID = :ID;

-- Read airports with a country filter
-- Variables: :Country
SELECT * FROM airports WHERE `Airport_Country` = :Country;

-- Populate country filter
SELECT DISTINCT Airport_Country FROM Airports;

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

-- Return a specific travel class
-- Variables: :ID
SELECT * FROM Travel_Classes WHERE Travel_Class_ID = :ID;

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

--Populate travel class dropdown
SELECT Travel_Class_ID FROM Airplane_Travel_Classes;

-- Airplane Travel Class
-- Create a new airplane travel class
-- Variables: :APType, :TravelClass, :Capacity
INSERT INTO `Airplane_Travel_Classes` (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`)
VALUES (
    (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :APType), 
    (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = :TravelClass), 
    :Capacity
);

-- This will be triggered in the backend when a new airplane is added to seed the table with 0 capacity entries for new planes.
-- Variables: :APType, :TravelClass, :Capacity
INSERT INTO `Airplane_Travel_Classes` (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`)
VALUES (
    (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :APType), 
    (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = :TravelClass), 
    0
);
-- Read all airplane travel classes
SELECT
    `Airplane_Travel_Classes_ID`,
    `Airplane_Type_ID`,
    APT.`Airplane_Type`,
    `Travel_Class_ID`,
    TC.`Travel_Class_Name`,
    `Travel_Class_Capacity`,
FROM
    airplane_travel_classes
    INNER JOIN airplane_types AS APT ON `APT`.`Airplane_Type_ID` = airplane_travel_classes.`Airplane_Type_ID`
    INNER JOIN travel_classes AS TC ON TC.`Travel_Class_ID` = airplane_travel_classes.`Travel_Class_ID`
ORDER BY APT.`Airplane_Type` ASC;

;

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

-- Retrieve all flights
SELECT
    `Flight_ID` AS Flight_Number,
    `Departure_Date_Time` AS Departure,
    `Arrival_Date_Time` AS Arrival,
    OA.`Airport_Name` AS Origin,
    DA.`Airport_Name` AS Destination,
    airplane.`Airplane_Type` AS Airplane
FROM
    Flights
    INNER JOIN airports AS OA ON `Flights`.`Origin_Airport_ID` = OA.`Airport_ID`
    INNER JOIN airports AS DA ON `Flights`.`Destination_Airport_ID` = DA.`Airport_ID`
    INNER JOIN airplane_types AS airplane ON `Flights`.`Airplane_Type_ID` = airplane.`Airplane_Type_ID`
ORDER BY Flight_Number ASC
    -- Retrieve all flight numbers
SELECT `Flight_ID`
FROM `Flights`
    -- Retrieve all airport names
SELECT Airport_Name
FROM Airports;
--Retrieve all airplane types
SELECT Airplane_Type FROM Airplane_Types;
-- Update a flight
-- Variables :Departure, :Arrival, :Origin, :Destination, :Airplane_Type, :Flight
UPDATE `Flights` 
SET `Departure_Date_Time` = :Departure,
    `Arrival_Date_Time` = :Arrival,
    `Origin_Airport_ID`= (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Origin),
    `Destination_Airport_ID` = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Destination),
    `Airplane_Type_ID` = (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :Airplane_Type)
WHERE `Flight_ID` = :Flight;

-- Retrieve a newly created flight
-- Variables: :Departure, :Arrival, :Origin, :Destination, :Airplane_Type
SELECT Flight_ID FROM `Flights` WHERE Departure_Date_Time = :Departure AND Arrival_Date_Time = :Arrival AND Origin_Airport_ID = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Origin) AND Destination_Airport_ID = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Destination) AND Airplane_Type_ID = (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :Airplane_Type);

-- Retrieve all capacities for a given airplane
-- Variables: :Airplane_Type
SELECT ACT.`Travel_Class_ID`, ACT.`Travel_Class_Capacity` FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` WHERE APT.Airplane_Type = :Airplane_Type
-- Update a flight
-- Variables: :Departure, :Arrival, :Origin, :Destination, :Airplane_Type, :Flight
UPDATE `Flights` 
SET `Departure_Date_Time` = :Departure,
    `Arrival_Date_Time` = :Arrival,
    `Origin_Airport_ID` = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Origin),
    `Destination_Airport_ID` = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = :Destination),
    `Airplane_Type_ID` = (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = :Airplane_Type)
WHERE `Flight_ID` = :Flight

-- Delete a flight
-- Variable: :Flight_ID
-- Ensure deleting a flight also deletes associated seats
DELETE FROM `Flights` WHERE `Flight_ID` = :Flight_ID;

-- Seats
-- Insert a new seat
-- Variables: :Class, :Flight, :SeatNumber, :Available, :Passenger_Name
INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`)
VALUES (
    (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = :Class),
    :Flight, 
    :SeatNumber, 
    :Available, 
    :Passenger_Name
);

-- Retrieve all seats
SELECT
    `Seat_ID`,
    TC.`Travel_Class_Name` AS Class,
    `Flight_ID` AS Flight_Number,
    `Seat_Number`,
    CASE
        WHEN `Available` = '0' THEN 'False'
        ELSE 'True'
    END AS Available,
    `Passenger_Name`
FROM seats
    LEFT JOIN travel_classes AS TC ON seats.`Travel_Class_ID` = `TC`.`Travel_Class_ID`
ORDER BY Flight_Number ASC;

-- Retrieve all seats for a flight
-- Variables: :FlightID
SELECT `Seat_ID`, TC.`Travel_Class_Name` AS Class, `Flight_ID` AS Flight_Number, `Seat_Number`, CASE WHEN `Available` = '0' THEN 'False' ELSE 'True' END AS Available, `Passenger_Name` FROM seats INNER JOIN travel_classes AS TC ON seats.`Travel_Class_ID`=`TC`.`Travel_Class_ID` WHERE Flight_ID = :FlightID ORDER BY Flight_Number ASC;
-- Update seat availability
-- Variables: :Seat_Number, :Flight_ID, :Passenger_Name

UPDATE `Seats`
SET `Available` = 0, `Passenger_Name` = :Passenger_Name
WHERE `Seat_Number` = :Seat_Number AND `Flight_ID` = :Flight_ID;

-- Delete a seat
-- Variable: :Seat_ID
DELETE FROM `Seats` WHERE `Seat_ID` = :Seat_ID;