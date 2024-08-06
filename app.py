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


@app.route('/')
def root():
    return render_template("main.j2")


@app.route('/seat-admin')
def seat_admin():
    query = "SELECT `Seat_ID`, TC.`Travel_Class_Name` AS Class, `Flight_ID` AS Flight, `Seat_Number`, `Available`, `Passenger_Name` FROM seats INNER JOIN travel_classes AS TC ON seats.`Travel_Class_ID`=`TC`.`Travel_Class_ID` WHERE Flight_ID = 1;"  # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("seat_admin.j2", data=results)


@app.route('/flight-admin')
def flight_admin():
    query = "SELECT `Flight_ID` AS FlightNumber, `Departure_Date_Time` AS Departure, `Arrival_Date_Time` AS Arrival, OA.`Airport_Name` AS Origin, DA.`Airport_Name` AS Destination, airplane.`Airplane_Type` AS Airplane FROM Flights INNER JOIN airports AS OA ON `Flights`.`Origin_Airport_ID` = OA.`Airport_ID` INNER JOIN airports AS DA ON `Flights`.`Destination_Airport_ID` = DA.`Airport_ID` INNER JOIN airplane_types AS airplane ON `Flights`.`Airplane_Type_ID` = airplane.`Airplane_Type_ID`"  # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("flight_admin.j2", data=results)


@app.route('/airplane-admin')
def airplane_admin():
    query = "SELECT * FROM Airplane_Types;"  # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airplane_admin.j2", data=results)

# Airport Routes


@app.route('/airport-admin', methods=["POST", "GET"])
def airport_admin():
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        query = "SELECT DISTINCT Airport_Country FROM Airports;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getCResults = cursor.fetchall()

        query = "SELECT * FROM Airports;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getAPResults = cursor.fetchall()
        return render_template("airport_admin.j2", data=getAPResults, pgOption=pgOption, countryData=getCResults)
    
@app.route('/airport-admin/<country>', methods=["POST", "GET"])
def airport_adminFilter(country):
    pgOption = "browseForm()"
    # Populate table
    if request.method == "GET":
        query = "SELECT Country FROM Airports;"
        cursor = db.execute_query(db_connection=db_connection, query=query)
        getCResults = cursor.fetchall()
        
        if country == 0 or country.upper() == "NULL":
            query = "SELECT * FROM Airports;"
            cursor = db.execute_query(db_connection=db_connection, query=query)
            getAPResults = cursor.fetchall()
        else:
            query = "SELECT * FROM Airports WHERE Country = %s;"
            cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(country,))
            getAPResults = cursor.fetchall()

        return render_template("airport_admin.j2", data=getAPResults, pgOption=pgOption, countryData=getCResults)
    # Create a new entry
    if request.method == "POST":
        cAName = request.form["name"]
        cACity = request.form["city"]
        cACountry = request.form["country"]
        query = "INSERT INTO airports (`Airport_Name`, `Airport_City`, `Airport_Country`) VALUES (%s, %s, %s);"
        cursor = db.execute_query(
            db_connection=db_connection, query=query, query_params=(cAName,cACity,cACountry))
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


@app.route('/airplanetravelclass-admin')
def airplanetravelclass_admin():
    query = "SELECT ACT.`Airplane_Travel_Classes_ID`, APT.`Airplane_Type` AS Airplane, TC.`Travel_Class_Name` AS Class, ACT.`Travel_Class_Capacity` AS Capacity FROM airplane_travel_classes AS ACT INNER JOIN airplane_types AS APT ON ACT.`Airplane_Type_ID` = APT.`Airplane_Type_ID` INNER JOIN travel_classes AS TC ON ACT.`Travel_Class_ID` = TC.`Travel_Class_ID`;"  # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airplanetravelclass_admin.j2", data=results)

# Listener


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
