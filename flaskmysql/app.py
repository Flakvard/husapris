from flask import Flask,render_template
import db_connect as db
import mysql.connector

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/properties")
def properties():
    connection = db.openDB()
    cursor = db.openCursor(connection)

    select_query = "SELECT * FROM properties"
    cursor.execute(select_query)
    records = cursor.fetchall()
    value = cursor.rowcount
    # print("Total number of properties are: ", cursor.rowcount)

    cursor.close()
    connection.close()
    return render_template("property_list.html",data=records,name="properties", recordCount=value)

@app.route("/registration")
def reg():
    return "FaroeseProperties Registration details"




if __name__ == "__main__":
    app.run(debug=True)