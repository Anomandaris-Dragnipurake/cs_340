from flask import Flask, render_template, json
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
    query = "SELECT * FROM Seats WHERE Flight_ID = 1;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("seat_admin.j2", data=results)


@app.route('/flight-admin')
def flight_admin():
    query = "SELECT * FROM Flights;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("flight_admin.j2", data=results)


@app.route('/airplane-admin')
def airplane_admin():
    query = "SELECT * FROM Airplane_Types;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airplane_admin.j2", data=results)


@app.route('/airport-admin')
def airport_admin():
    query = "SELECT * FROM Airports;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airport_admin.j2", data=results)


@app.route('/travelclass-admin')
def travelclass_admin():
    query = "SELECT * FROM Travel_Classes;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("travelclass_admin.j2", data=results)

@app.route('/airplanetravelclass-admin')
def airplanetravelclass_admin():
    query = "SELECT * FROM Airplane_Travel_Classes;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airplanetravelclass_admin.j2", data=results)

# Listener


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)