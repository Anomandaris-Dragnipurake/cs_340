-- SQLBook: Code
-- -----------------------------------------------------
-- Group 3 Airplane Reservation System
-- Authors: Andrew Chi, Eric McElhinny
-- -----------------------------------------------------

SET AUTOCOMMIT = 0;

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;

SET
    @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS,
    FOREIGN_KEY_CHECKS = 0;

SET
    @OLD_SQL_MODE = @@SQL_MODE,
    SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema cs340_mcelhine
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `cs340_mcelhine` DEFAULT CHARACTER SET utf8;

USE `cs340_mcelhine`;

-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Airports`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Airports`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Airports` (
    `Airport_ID` INT NOT NULL AUTO_INCREMENT,
    `Airport_Name` VARCHAR(100) NULL,
    `Airport_City` VARCHAR(100) NULL,
    `Airport_Country` VARCHAR(100) NULL,
    PRIMARY KEY (`Airport_ID`)
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Airports` (
        `Airport_Name`,
        `Airport_City`,
        `Airport_Country`
    )
VALUES (
        "MDT",
        "Harrisburg",
        "United States"
    ),
    (
        "LGA",
        "New York",
        "United States"
    ),
    (
        "LHR",
        "London",
        "United Kingdom"
    ),
    ("HND", "Tokyo", "Japan"),
    ("CAI", "Cairo", "Egypt");

-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Airplane_Types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Airplane_Types`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Airplane_Types` (
    `Airplane_Type_ID` INT NOT NULL AUTO_INCREMENT,
    `Airplane_Type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`Airplane_Type_ID`)
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Airplane_Types` (`Airplane_Type`)
VALUES ("Boeing 737"),
    ("Airbus A320"),
    ("Bombardier CRJ"),
    ("Cessna 172"),
    ("Boeing 747");
-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Flights`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Flights`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Flights` (
    `Flight_ID` INT NOT NULL AUTO_INCREMENT,
    `Departure_Date_Time` DATETIME NULL,
    `Arrival_Date_Time` DATETIME NULL,
    `Origin_Airport_ID` INT NOT NULL,
    `Destination_Airport_ID` INT NOT NULL,
    `Airplane_Type_ID` INT NOT NULL,
    PRIMARY KEY (`Flight_ID`),
    INDEX `fk_Flights_Airports1_idx` (`Origin_Airport_ID` ASC) VISIBLE,
    INDEX `fk_Flights_Airports2_idx` (`Destination_Airport_ID` ASC) VISIBLE,
    INDEX `fk_Flights_Airplane_Type1_idx` (`Airplane_Type_ID` ASC) VISIBLE,
    CONSTRAINT `fk_Flights_Airports1` FOREIGN KEY (`Origin_Airport_ID`) REFERENCES `cs340_mcelhine`.`Airports` (`Airport_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Flights_Airports2` FOREIGN KEY (`Destination_Airport_ID`) REFERENCES `cs340_mcelhine`.`Airports` (`Airport_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Flights_Airplane_Type1` FOREIGN KEY (`Airplane_Type_ID`) REFERENCES `cs340_mcelhine`.`Airplane_Types` (`Airplane_Type_ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Flights` (
        `Departure_Date_Time`,
        `Arrival_Date_Time`,
        `Origin_Airport_ID`,
        `Destination_Airport_ID`,
        `Airplane_Type_ID`
    )
VALUES (
        '2024-07-16 08:00:00',
        '2024-07-16 20:00:00',
        2,
        3,
        1
    ),
    (
        '2024-07-16 09:00:00',
        '2024-07-16 20:00:00',
        3,
        4,
        2
    ),
    (
        '2024-07-16 10:00:00',
        '2024-07-16 21:00:00',
        4,
        3,
        3
    ),
    (
        '2024-07-16 11:00:00',
        '2024-07-16 22:00:00',
        2,
        5,
        3
    ),
    (
        '2024-07-16 12:00:00',
        '2024-07-17 00:00:00',
        1,
        5,
        5
    );

-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Travel_Classes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Travel_Classes`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Travel_Classes` (
    `Travel_Class_ID` INT NOT NULL AUTO_INCREMENT,
    `Travel_Class_Name` VARCHAR(100) NULL,
    `Travel_Class_Cost` DECIMAL(20, 2) NULL,
    PRIMARY KEY (`Travel_Class_ID`)
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Travel_Classes` (
        `Travel_Class_Name`,
        `Travel_Class_Cost`
    )
VALUES ("First", 100),
    ("Business", 50),
    ("Economy", 10);

-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Seats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Seats`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Seats` (
    `Seat_ID` INT NOT NULL AUTO_INCREMENT,
    `Travel_Class_ID` INT NOT NULL,
    `Flight_ID` INT NOT NULL,
    `Seat_Number` VARCHAR(100) NOT NULL,
    `Available` TINYINT NULL DEFAULT 1,
    `Passenger_Name` VARCHAR(100) NULL,
    PRIMARY KEY (`Seat_ID`),
    UNIQUE KEY `Seat_Numbers` (`Seat_Number`, `Flight_ID`),
    INDEX `fk_Seats_Travel_Class1_idx` (`Travel_Class_ID` ASC) VISIBLE,
    INDEX `fk_Seats_Flights1_idx` (`Flight_ID` ASC) VISIBLE,
    CONSTRAINT `Seat_Number_gtzero` CHECK (`Seat_Number` > 0),
    CONSTRAINT `fk_Seats_Travel_Class1` FOREIGN KEY (`Travel_Class_ID`) REFERENCES `cs340_mcelhine`.`Travel_Classes` (`Travel_Class_ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_Seats_Flights1` FOREIGN KEY (`Flight_ID`) REFERENCES `cs340_mcelhine`.`Flights` (`Flight_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Seats` (
        `Travel_Class_ID`,
        `Flight_ID`,
        `Seat_Number`
    )
VALUES (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3),
    (1, 2, 1),
    (1, 2, 2);

-- -----------------------------------------------------
-- Table `cs340_mcelhine`.`Airplane_Travel_Classes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cs340_mcelhine`.`Airplane_Travel_Classes`;

CREATE TABLE IF NOT EXISTS `cs340_mcelhine`.`Airplane_Travel_Classes` (
    `Airplane_Travel_Classes_ID` INT NOT NULL AUTO_INCREMENT,
    `Airplane_Type_ID` INT NOT NULL,
    `Travel_Class_ID` INT NOT NULL,
    `Travel_Class_Capacity` BIGINT NULL,
    PRIMARY KEY (`Airplane_Travel_Classes_ID`),
    INDEX `fk_Airplane_Type_has_Travel_Class_Travel_Class1_idx` (`Travel_Class_ID` ASC) VISIBLE,
    INDEX `fk_Airplane_Type_has_Travel_Class_Airplane_Type1_idx` (`Airplane_Type_ID` ASC) VISIBLE,
    CONSTRAINT `fk_Airplane_Type_has_Travel_Class_Airplane_Type1` FOREIGN KEY (`Airplane_Type_ID`) REFERENCES `cs340_mcelhine`.`Airplane_Types` (`Airplane_Type_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_Airplane_Type_has_Travel_Class_Travel_Class1` FOREIGN KEY (`Travel_Class_ID`) REFERENCES `cs340_mcelhine`.`Travel_Classes` (`Travel_Class_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO
    `cs340_mcelhine`.`Airplane_Travel_Classes` (
        `Airplane_Type_ID`,
        `Travel_Class_ID`,
        `Travel_Class_Capacity`
    )
VALUES (1, 1, 20),
    (1, 2, 50),
    (1, 3, 100),
    (2, 1, 20),
    (2, 2, 50),
    (2, 3, 100),
    (4, 1, 0),
    (4, 2, 0),
    (4, 3, 5);

SET SQL_MODE = @OLD_SQL_MODE;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;

SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;

COMMIT;