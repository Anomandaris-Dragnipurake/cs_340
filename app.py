""" The following python is derived from the starter app code for cs_340
Date 7/25/2024
Derived from the example structure of python
https://github.com/osu-cs340-ecampus/flask-starter-app/tree/master """
from flask import Flask, render_template, json, request, redirect, url_for
from flask_mysqldb import MySQL
import os
import Database.db_connector as db

# Configuration

app = Flask(__name__)
db_connection = db.connect_to_database()
# Routes

# Seat Routes


@app.route('/')
def root():
    return render_template("main.j2")


@app.route('/seat-admin', methods=["POST", "GET"])
def seat_admin():
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        flightNum = request.args.get('flight', default='NULL')

        query = "SELECT Flight_ID FROM flights ORDER BY Flight_ID ASC;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getFResults = cursor.fetchall()

        if flightNum.upper() == "NULL":
            query = "SELECT `Seat_ID`, TC.`Travel_Class_Name` AS Class, `Flight_ID` AS Flight_Number, `Seat_Number`, CASE WHEN `Available` = '0' THEN 'False' ELSE 'True' END AS Available, `Passenger_Name` FROM seats LEFT JOIN travel_classes AS TC ON seats.`Travel_Class_ID`=`TC`.`Travel_Class_ID`ORDER BY Flight_Number ASC;"
            cursor = db.execute_query(db_connection=db_connection, query=query)
            results = cursor.fetchall()
        else:
            query = "SELECT `Seat_ID`, TC.`Travel_Class_Name` AS Class, `Flight_ID` AS Flight_Number, `Seat_Number`, CASE WHEN `Available` = '0' THEN 'False' ELSE 'True' END AS Available, `Passenger_Name` FROM seats INNER JOIN travel_classes AS TC ON seats.`Travel_Class_ID`=`TC`.`Travel_Class_ID` WHERE Flight_ID = %s ORDER BY Flight_Number ASC;"
            cursor = db.execute_query(
                db_connection=db_connection, query=query, query_params=(flightNum,))
            results = cursor.fetchall()

        # Get dropdown data
        tcQuery = "SELECT Travel_Class_Name FROM Travel_Classes;"
        cursor = db.execute_query(
            db_connection=db_connection, query=tcQuery)
        tcNames = cursor.fetchall()

        return render_template("seat_admin.j2", data=results, pgOption=pgOption, flightData=getFResults, tcData=tcNames)
    # Create a new entry
    if request.method == "POST":
        cClass = request.form["class"]
        cFlight = request.form["flight"]
        cSeatNum = request.form["seatnum"]
        cAvailable = request.form["available"]
        cPName = request.form["passenger_name"]

        if cPName == "":
            query = "INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`) VALUES ( (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = %s), %s, %s, %s, NULL );"
            cursor = db.execute_query(
                db_connection=db_connection, query=query, query_params=(cClass, cFlight, cSeatNum, cAvailable))
            return redirect("/seat-admin")
        else:
            query = "INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`) VALUES ( (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = %s), %s, %s, %s, %s );"
            cursor = db.execute_query(
                db_connection=db_connection, query=query, query_params=(cClass, cFlight, cSeatNum, cAvailable, cPName))
            return redirect("/seat-admin")


# Flight Routes


@app.route('/flight-admin', methods=["POST", "GET"])
def flight_admin():
    pgOption = "browseForm()"
    if request.method == "GET":
        query = "SELECT `Flight_ID` AS Flight_Number, `Departure_Date_Time` AS Departure, `Arrival_Date_Time` AS Arrival, OA.`Airport_Name` AS Origin, DA.`Airport_Name` AS Destination, airplane.`Airplane_Type` AS Airplane FROM Flights INNER JOIN airports AS OA ON `Flights`.`Origin_Airport_ID` = OA.`Airport_ID` INNER JOIN airports AS DA ON `Flights`.`Destination_Airport_ID` = DA.`Airport_ID` INNER JOIN airplane_types AS airplane ON `Flights`.`Airplane_Type_ID` = airplane.`Airplane_Type_ID` ORDER BY Flight_Number ASC"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()

        # Get dropdown data
        airportQuery = "SELECT Airport_Name FROM Airports;"
        cursor = db.execute_query(
            db_connection=db_connection, query=airportQuery)
        airportNames = cursor.fetchall()

        airplaneQuery = "SELECT Airplane_Type FROM Airplane_Types;"
        cursor = db.execute_query(
            db_connection=db_connection, query=airplaneQuery)
        airplaneNames = cursor.fetchall()
        return render_template("flight_admin.j2", data=results, pgOption=pgOption, airportData=airportNames, airplaneData=airplaneNames)

    # Create a new entry
    if request.method == "POST":
        cDepart = request.form["departure"]
        cArrive = request.form["arrival"]
        cOrigin = request.form["origin"]
        cDestination = request.form["destination"]
        cAirplane = request.form["airplane"]
        query = "INSERT INTO `Flights` ( `Departure_Date_Time`, `Arrival_Date_Time`, `Origin_Airport_ID`, `Destination_Airport_ID`, `Airplane_Type_ID` ) VALUES ( %s, %s, (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = %s), (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = %s), (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = %s) );"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cDepart, cArrive, cOrigin, cDestination, cAirplane))
        
        # Add seats to the new flight based on the flight's airplane type's capacities
        newFlightQuery = "SELECT Flight_ID FROM `Flights` WHERE Departure_Date_Time = %s AND Arrival_Date_Time = %s AND Origin_Airport_ID = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = %s) AND Destination_Airport_ID = (SELECT `Airport_ID` FROM `Airports` WHERE `Airport_Name` = %s) AND Airplane_Type_ID = (SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = %s);" 
        cursor = db.execute_query(
            db_connection=db_connection, query=newFlightQuery, query_params=(cDepart, cArrive, cOrigin, cDestination, cAirplane))
        newFlight = cursor.fetchall()
        tcCapacitiesQuery = "SELECT ACT.`Travel_Class_ID`, ACT.`Travel_Class_Capacity` FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` WHERE APT.Airplane_Type = %s"
        cursor = db.execute_query(
            db_connection=db_connection, query=tcCapacitiesQuery, query_params=(cAirplane,))
        tcCapacities = cursor.fetchall()
        seatQuery = "INSERT INTO `Seats` (`Travel_Class_ID`, `Flight_ID`, `Seat_Number`, `Available`, `Passenger_Name`) VALUES ( %s, %s, %s, 1, NULL);"
        newSeatNum = 1
        for travel_class in tcCapacities:
            for i in range(travel_class['Travel_Class_Capacity']):
                cursor = db.execute_query(db_connection=db_connection, query=seatQuery, query_params=(travel_class['Travel_Class_ID'], newFlight[0]['Flight_ID'], newSeatNum))
                newSeatNum += 1

        return redirect("/flight-admin")

# Airplane Routes


@app.route('/airplane-admin', methods=["POST", "GET"])
def airplane_admin():
    pgOption = "browseForm()"

    if request.method == "GET":
        query = "SELECT * FROM Airplane_Types;"  # Replace with true query later
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("airplane_admin.j2", data=results, pgOption=pgOption)

# Create a new entry in airplane_types and add 0 capacity entries to intersection table
    if request.method == "POST":
        cAName = request.form["name"]
        query = "INSERT INTO airplane_types (`Airplane_Type`) VALUES (%s);"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cAName,))

        tcQuery = "SELECT Travel_Class_ID FROM Airplane_Travel_Classes;"
        cursor = db.execute_query(db_connection=db_connection, query=tcQuery)
        tcIds = cursor.fetchall()
        for tcId in tcIds:
            query = "INSERT INTO airplane_travel_classes (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`) VALUES ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = %s), %s, %s);"
            cursor = db.execute_query(
                db_connection=db_connection, query=query, query_params=(cAName, tcId, 0))
        return redirect("/airplane-admin")


@app.route("/edit_airplane/<int:id>", methods=["POST", "GET"])
def edit_airplane(id):
    pgOption = "updateForm()"
    if request.method == "GET":
        query = "SELECT * FROM airplane_types WHERE Airplane_Type_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airplane_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        id = request.form["airplaneID"]
        name = request.form["name"]
        query = "UPDATE airplane_types SET `Airplane_Type` = %s WHERE `Airplane_Type_ID` = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(name, id))
        return redirect("/airplane-admin")


@app.route("/delete_airplane/<int:id>", methods=["POST", "GET"])
def delete_airplane(id):
    pgOption = "deleteForm()"
    if request.method == "GET":
        query = "SELECT * FROM airplane_types WHERE Airplane_Type_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airplane_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        query = "DELETE FROM airplane_types WHERE `Airplane_Type_ID` = %s"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
    return redirect("/airplane-admin")

# Airport Routes


@app.route('/airport-admin', methods=["POST", "GET"])
def airport_admin():
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        country = request.args.get('country', default='NULL')

        query = "SELECT DISTINCT Airport_Country FROM Airports;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getCResults = cursor.fetchall()

        if country == 0 or country.upper() == "NULL":
            query = "SELECT * FROM Airports;"
            cursor = db.execute_query(db_connection=db_connection, query=query)
            getAPResults = cursor.fetchall()
        else:
            query = "SELECT * FROM Airports WHERE Airport_Country = %s;"
            cursor = db.execute_query(
                db_connection=db_connection, query=query, query_params=(country,))
            getAPResults = cursor.fetchall()

        return render_template("airport_admin.j2", data=getAPResults, pgOption=pgOption, countryData=getCResults)

    # Create a new entry
    if request.method == "POST":
        cAName = request.form["name"]
        cACity = request.form["city"]
        cACountry = request.form["country"]
        query = "INSERT INTO airports (`Airport_Name`, `Airport_City`, `Airport_Country`) VALUES (%s, %s, %s);"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cAName, cACity, cACountry))
        return redirect("/airport-admin")


@app.route("/edit_airport/<int:id>", methods=["POST", "GET"])
def edit_ap(id):
    pgOption = "updateForm()"
    if request.method == "GET":
        query = "SELECT * FROM airports WHERE Airport_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airport_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        id = request.form["airportID"]
        name = request.form["name"]
        city = request.form["city"]
        country = request.form["country"]
        query = "UPDATE airports SET `Airport_Name` = %s, `Airport_City` = %s, `Airport_Country`=%s WHERE `Airport_ID` = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(name, city, country, id))
        return redirect("/airport-admin")


@app.route("/delete_airport/<int:id>", methods=["POST", "GET"])
def delete_ap(id):
    pgOption = "deleteForm()"
    if request.method == "GET":
        query = "SELECT * FROM Airports WHERE Airport_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airport_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        query = "DELETE FROM airports WHERE `Airport_ID` = %s"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
    return redirect("/airport-admin")


# Travel Class Routes


@app.route('/travelclass-admin', methods=["POST", "GET"])
def travelclass_admin():
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        query = "SELECT * FROM Travel_Classes;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("travelclass_admin.j2", data=results, pgOption=pgOption)
    # Create a new entry
    if request.method == "POST":
        cTCName = request.form["name"]
        cTCCost = request.form["cost"]
        query = "INSERT INTO travel_classes (`Travel_Class_Name`, `Travel_Class_Cost`) VALUES (%s, %s);"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cTCName, cTCCost))
        return redirect("/travelclass-admin")


@app.route("/delete_travelclass/<int:id>", methods=["POST", "GET"])
def delete_tc(id):
    pgOption = "deleteForm()"
    if request.method == "GET":
        query = "SELECT * FROM Travel_Classes WHERE Travel_Class_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("travelclass_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        query = "DELETE FROM travel_classes WHERE `Travel_Class_ID` = %s"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
    return redirect("/travelclass-admin")


@app.route("/edit_travelclass/<int:id>", methods=["POST", "GET"])
def edit_tc(id):
    pgOption = "updateForm()"
    if request.method == "GET":
        query = "SELECT * FROM Travel_Classes WHERE Travel_Class_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("travelclass_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        id = request.form["travelClassID"]
        name = request.form["name"]
        cost = request.form["cost"]
        query = "UPDATE travel_classes SET `Travel_Class_Name` = %s, `Travel_Class_Cost` = %s WHERE `Travel_Class_ID` = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(name, cost, id))
        return redirect("/travelclass-admin")

# Airplane Travel Class Routes


@app.route('/airplanetravelclass-admin', methods=["POST", "GET"])
def airplanetravelclass_admin():
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        airplane = request.args.get('airplane', default="0")
        travelclass = request.args.get('class', default="0")

        query = "SELECT DISTINCT Airplane_Type FROM Airplane_Types;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getATResults = cursor.fetchall()

        query = "SELECT DISTINCT Travel_Class_Name FROM Travel_Classes;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getTCResults = cursor.fetchall()

        query = "SELECT ACT.`Airplane_Travel_Classes_ID`, APT.`Airplane_Type` AS Airplane, TC.`Travel_Class_Name` AS Class, ACT.`Travel_Class_Capacity` AS Capacity FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` INNER JOIN travel_classes AS TC ON ACT.`Travel_Class_ID` = TC.`Travel_Class_ID`"
        apQuery = ""
        tcQuery = ""

        if airplane != "0":
            apQuery = "APT.`Airplane_Type` = '" + airplane + "'"

        if travelclass != "0":
            tcQuery = "TC.`Travel_Class_Name` = '" + travelclass + "'"

        if apQuery != "" and tcQuery != "":
            query = query + " WHERE " + apQuery + " AND " + tcQuery
        elif apQuery != "" or tcQuery != "":
            query = query + " WHERE " + apQuery + tcQuery

        query = query + "ORDER BY APT.`Airplane_Type` ASC;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        results = cursor.fetchall()
        return render_template("airplanetravelclass_admin.j2", data=results, pgOption=pgOption, airplaneData=getATResults, classData=getTCResults)

    # Create a new entry
    if request.method == "POST":
        cAPName = request.form["airplane_type"]
        cTC = request.form["travel_class"]
        cCapacity = request.form["travel_class_capacity"]
        query = "INSERT INTO airplane_travel_classes (`Airplane_Type_ID`, `Travel_Class_ID`, `Travel_Class_Capacity`) VALUES ((SELECT `Airplane_Type_ID` FROM `Airplane_Types` WHERE `Airplane_Type` = %s), (SELECT `Travel_Class_ID` FROM `Travel_Classes` WHERE `Travel_Class_Name` = %s), %s);"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cAPName, cTC, cCapacity))
        return redirect("/airplanetravelclass-admin")


@app.route("/delete_airplanetravelclass/<int:id>", methods=["POST", "GET"])
def delete_atc(id):
    pgOption = "deleteForm()"
    if request.method == "GET":
        query = "SELECT ACT.`Airplane_Travel_Classes_ID`, APT.`Airplane_Type` AS Airplane, TC.`Travel_Class_Name` AS Class, ACT.`Travel_Class_Capacity` AS Capacity FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` INNER JOIN travel_classes AS TC ON ACT.`Travel_Class_ID` = TC.`Travel_Class_ID` WHERE Airplane_Travel_Classes_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airplanetravelclass_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        query = "DELETE FROM airplane_travel_classes WHERE `Airplane_Travel_Classes_ID` = %s"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
    return redirect("/airplanetravelclass-admin")


@app.route("/edit_airplanetravelclass/<int:id>", methods=["POST", "GET"])
def edit_atc(id):
    pgOption = "updateForm()"
    if request.method == "GET":
        query = "SELECT ACT.`Airplane_Travel_Classes_ID`, APT.`Airplane_Type` AS Airplane, TC.`Travel_Class_Name` AS Class, ACT.`Travel_Class_Capacity` AS Capacity FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` INNER JOIN travel_classes AS TC ON ACT.`Travel_Class_ID` = TC.`Travel_Class_ID` WHERE Airplane_Travel_Classes_ID = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(id,))
        results = cursor.fetchall()
        return render_template("airplanetravelclass_admin.j2", data=results, pgOption=pgOption)

    if request.method == "POST":
        id = request.form["airplanetravelclassID"]
        capacity = request.form["travel_class_capacity"]
        query = "UPDATE airplane_travel_classes SET `Travel_Class_Capacity`=%s WHERE `Airplane_Travel_Classes_ID` = %s;"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(capacity, id))
        return redirect("/airplanetravelclass-admin")


# Listener
if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port)
