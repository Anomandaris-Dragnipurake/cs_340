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
def seat_selection():
    return render_template("seat_admin.j2")


@app.route('/flight-admin')
def flight_admin():
    query = "SELECT * FROM Flights;" # Replace with query to return flights
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("flight_admin.j2", data=results)


@app.route('/airplane-admin')
def airplane_admin():
    return render_template("airplane_admin.j2")


@app.route('/airport-admin')
def airport_admin():
    query = "SELECT * FROM Airports;" # Replace with true query later
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("airport_admin.j2", data=results)


@app.route('/travelclass-admin')
def travelclass_admin():
    return render_template("travelclass_admin.j2")

# Listener


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)