-- Active: 1720982518894@@127.0.0.1@3306@step3final
-- SQLBook: Code
-- -----------------------------------------------------
-- Group 3 Airplane Reservation System
-- Authors: Andrew Chi, Eric McElhinny
-- This file details the creation of 6 tables to implement the flight tracking system and populates each with example data
-- -----------------------------------------------------

SET AUTOCOMMIT = 0;

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- -----------------------------------------------------
-- Table `Airports`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Airports`;

CREATE TABLE IF NOT EXISTS `Airports` (
    `Airport_ID` INT NOT NULL AUTO_INCREMENT,
    `Airport_Name` VARCHAR(100) NOT NULL,
    `Airport_City` VARCHAR(100) NOT NULL,
    `Airport_Country` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Airport_ID`)
) ENGINE = InnoDB;

INSERT INTO `Airports` (`Airport_Name`, `Airport_City`, `Airport_Country`)
VALUES 
    ("MDT", "Harrisburg", "United States"),
    ("LGA", "New York", "United States"),
    ("LHR", "London", "United Kingdom"),
    ("HND", "Tokyo", "Japan"),
    ("CAI", "Cairo", "Egypt");

-- -----------------------------------------------------
-- Table `Airplane_Types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Airplane_Types`;

CREATE TABLE IF NOT EXISTS `Airplane_Types` (
    `Airplane_Type_ID` INT NOT NULL AUTO_INCREMENT,
    `Airplane_Type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Airplane_Type_ID`)
) ENGINE = InnoDB;

INSERT INTO `Airplane_Types` (`Airplane_Type`)
VALUES 
    ("Boeing 737"),
    ("Airbus A320"),
    ("Bombardier CRJ"),
    ("Cessna 172"),
    ("Boeing 747");

-- -----------------------------------------------------
-- Table `Flights`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Flights`;

CREATE TABLE IF NOT EXISTS `Flights` (
    `Flight_ID` INT NOT NULL AUTO_INCREMENT,
    `Departure_Date_Time` DATETIME NOT NULL,
    `Arrival_Date_Time` DATETIME NOT NULL,
    `Origin_Airport_ID` INT NOT NULL,
    `Destination_Airport_ID` INT NOT NULL,
    `Airplane_Type_ID` INT NOT NULL,
    PRIMARY KEY (`Flight_ID`),
    INDEX `fk_Flights_Origin_Airport_idx` (`Origin_Airport_ID` ASC) VISIBLE,
    INDEX `fk_Flights_Destination_Airport_idx` (`Destination_Airport_ID` ASC) VISIBLE,
    INDEX `fk_Flights_Airplane_Type_idx` (`Airplane_Type_ID` ASC) VISIBLE,
    CONSTRAINT `fk_Flights_Origin_Airport` FOREIGN KEY (`Origin_Airport_ID`) REFERENCES `Airports` (`Airport_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_Flights_Destination_Airport` FOREIGN KEY (`Destination_Airport_ID`) REFERENCES `Airports` (`Airport_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_Flights_Airplane_Type` FOREIGN KEY (`Airplane_Type_ID`) REFERENCES `Airplane_Types` (`Airplane_Type_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO `Flights` (`Departure_Date_Time`, `Arrival_Date_Time`, `Origin_Airport_ID`, `Destination_Airport_ID`, `Airplane_Type_ID`)
VALUES 
    ('2024-07-16 08:00:00', '2024-07-16 20:00:00', 
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "LGA"),
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "LHR"),
        (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 737")),
    ('2024-07-16 09:00:00', '2024-07-16 20:00:00', 
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "LHR"),
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "HND"),
        (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Airbus A320")),
    ('2024-07-16 10:00:00', '2024-07-16 21:00:00', 
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "HND"),
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "LHR"),
        (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Bombardier CRJ")),
    ('2024-07-16 11:00:00', '2024-07-16 22:00:00', 
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "LGA"),
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "CAI"),
        (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Bombardier CRJ")),
    ('2024-07-16 12:00:00', '2024-07-17 00:00:00', 
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "MDT"),
        (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = "CAI"),
        (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 747"));

-- -----------------------------------------------------
-- Table `Travel_Classes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Travel_Classes`;

CREATE TABLE IF NOT EXISTS `Travel_Classes` (
    `Travel_Class_ID` INT NOT NULL AUTO_INCREMENT,
    `Travel_Class_Name` VARCHAR(100) NOT NULL,
    `Travel_Class_Cost` DECIMAL(20, 2) NOT NULL,
    PRIMARY KEY (`Travel_Class_ID`)
) ENGINE = InnoDB;

INSERT INTO `Travel_Classes` (`Travel_Class_Name`, `Travel_Class_Cost`)
VALUES 
    ("First", 100.00),
    ("Business", 50.00),
    ("Economy", 10.00);

-- -----------------------------------------------------
-- Table `Seats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Seats`;

CREATE TABLE IF NOT EXISTS `Seats` (
    `Seat_ID` INT NOT NULL AUTO_INCREMENT,
    `Travel_Class_ID` INT,
    `Flight_ID` INT NOT NULL,
    `Seat_Number` VARCHAR(100) NOT NULL,
    `Available` TINYINT NOT NULL DEFAULT 1,
    `Passenger_Name` VARCHAR(100) NULL,
    PRIMARY KEY (`Seat_ID`),
    UNIQUE KEY `Seat_Numbers` (`Seat_Number`, `Flight_ID`),
    INDEX `fk_Seats_Travel_Class_idx` (`Travel_Class_ID` ASC) VISIBLE,
    INDEX `fk_Seats_Flights_idx` (`Flight_ID` ASC) VISIBLE,
    CONSTRAINT `fk_Seats_Travel_Class` FOREIGN KEY (`Travel_Class_ID`) REFERENCES `Travel_Classes` (`Travel_Class_ID`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_Seats_Flights` FOREIGN KEY (`Flight_ID`) REFERENCES `Flights` (`Flight_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`)
VALUES 
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 08:00:00'), 
        '1', FALSE, 'James Smith'),
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 08:00:00'), 
        '2', TRUE, NULL),
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 08:00:00'), 
        '3', TRUE, NULL),
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 09:00:00'), 
        '1', TRUE, NULL),
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 09:00:00'), 
        '2', TRUE, NULL),
    ((SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 
        (SELECT `Flight_ID` FROM `Flights` WHERE `Departure_Date_Time` = '2024-07-16 09:00:00'), 
        '3', TRUE, NULL);

-- -----------------------------------------------------
-- Table `Airplane_Travel_Classes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Airplane_Travel_Classes`;

CREATE TABLE IF NOT EXISTS `Airplane_Travel_Classes` (
    `Airplane_Travel_Classes_ID` INT NOT NULL AUTO_INCREMENT,
    `Airplane_Type_ID` INT NOT NULL,
    `Travel_Class_ID` INT NOT NULL,
    `Travel_Class_Capacity` INT NOT NULL,
    PRIMARY KEY (`Airplane_Travel_Classes_ID`),
    INDEX `fk_Airplane_Travel_Classes_Airplane_Type_idx` (`Airplane_Type_ID` ASC) VISIBLE,
    INDEX `fk_Airplane_Travel_Classes_Travel_Class_idx` (`Travel_Class_ID` ASC) VISIBLE,
    CONSTRAINT `fk_Airplane_Travel_Classes_Airplane_Type` FOREIGN KEY (`Airplane_Type_ID`) REFERENCES `Airplane_Types` (`Airplane_Type_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_Airplane_Travel_Classes_Travel_Class` FOREIGN KEY (`Travel_Class_ID`) REFERENCES `Travel_Classes` (`Travel_Class_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO `Airplane_Travel_Classes` (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`)
VALUES 
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 737"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 12),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 737"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 36),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 737"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 102),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Airbus A320"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 16),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Airbus A320"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 40),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Airbus A320"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 120),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Bombardier CRJ"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 8),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Bombardier CRJ"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 24),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Bombardier CRJ"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 60),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Cessna 172"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 1),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Cessna 172"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 1),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Cessna 172"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 2),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 747"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "First"), 24),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 747"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Business"), 72),
    ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = "Boeing 747"), 
        (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = "Economy"), 200);

SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;

COMMIT;