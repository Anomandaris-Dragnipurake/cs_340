-- Flights
-- Insert a new flight
-- Variables: :Departure_Date_Time, :Arrival_Date_Time, :Origin_Airport_ID, :Destination_Airport_ID, :Airplane_Type_ID

INSERT INTO `cs340_mcelhine`.`Flights` (
    `Departure_Date_Time`,
    `Arrival_Date_Time`,
    `Origin_Airport_ID`,
    `Destination_Airport_ID`,
    `Airplane_Type_ID`
) VALUES (
    :Departure_Date_Time,
    :Arrival_Date_Time,
    :Origin_Airport_ID,
    :Destination_Airport_ID,
    :Airplane_Type_ID
);

-- Delete a flight
-- Variable: :Flight_ID

DELETE FROM `cs340_mcelhine`.`Flights`
WHERE `Flight_ID` = :Flight_ID;

-- Retrieve all flights from a specific airport
-- Variable: :Origin_Airport_ID
SELECT *
FROM `cs340_mcelhine`.`Flights`
WHERE `Origin_Airport_ID` = :Origin_Airport_ID;

-- Seats
-- Update seat availability
-- Variables: :Seat_Number, :Flight_ID, :Passenger_Name

UPDATE `cs340_mcelhine`.`Seats`
SET `Available` = 0, `Passenger_Name` = :Passenger_Name
WHERE `Seat_Number` = :Seat_Number AND `Flight_ID` = :Flight_ID;

-- Delete a seat from a flight
-- Variables: :Seat_ID

DELETE FROM `cs340_mcelhine`.`Seats` WHERE `Seat_ID` = :Seat_ID;

-- Find all available seats on a specific flight
-- Variable: :Flight_ID

SELECT *
FROM `cs340_mcelhine`.`Seats`
WHERE `Flight_ID` = :Flight_ID AND `Available` = 1;

-- List all airports in a specific country
-- Variable: :Airport_Country

SELECT *
FROM `cs340_mcelhine`.`Airports`
WHERE `Airport_Country` = :Airport_Country;

-- Calculate total seats sold for a specific flight
-- Variable: :Flight_ID

SELECT COUNT(*) AS `Total_Seats_Sold`
FROM `cs340_mcelhine`.`Seats`
WHERE `Flight_ID` = :Flight_ID AND `Available` = 0;

-- Retrieve all flights with a specific airplane type
-- Variable: :Airplane_Type_ID

SELECT *
FROM `cs340_mcelhine`.`Flights`
WHERE `Airplane_Type_ID` = :Airplane_Type_ID;

-- Retrieve all travel classes for a specific airplane type
-- Variable: :Airplane_Type_ID

SELECT `tc`.`Travel_Class_Name`, `atc`.`Travel_Class_Capacity`
FROM `cs340_mcelhine`.`Airplane_Travel_Classes` `atc`
JOIN `cs340_mcelhine`.`Travel_Classes` `tc` ON `atc`.`Travel_Class_ID` = `tc`.`Travel_Class_ID`
WHERE `atc`.`Airplane_Type_ID` = :Airplane_Type_ID;

-- Retrieve all flights between two airports
-- Variables: :Origin_Airport_ID, :Destination_Airport_ID

SELECT *
FROM `cs340_mcelhine`.`Flights`
WHERE `Origin_Airport_ID` = :Origin_Airport_ID
  AND `Destination_Airport_ID` = :Destination_Airport_ID;

-- Update flight time
-- Variables: :Departure_Date_Time, :Arrival_Date_Time, :Flight_ID

UPDATE `cs340_mcelhine`.`Flights`
SET `Departure_Date_Time` = :Departure_Date_Time,
    `Arrival_Date_Time` = :Arrival_Date_Time
WHERE `Flight_ID` = :Flight_ID;

-- Insert a new airport
-- Variables: :Airport_Name, :Airport_City, :Airport_Country

INSERT INTO `cs340_mcelhine`.`Airports` (
    `Airport_Name`,
    `Airport_City`,
    `Airport_Country`
) VALUES (
    :Airport_Name,
    :Airport_City,
    :Airport_Country
);