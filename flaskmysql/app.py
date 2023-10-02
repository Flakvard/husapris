from flask import Flask,render_template
import db_connect as db
import mysql.connector

# connection = mysql.connector.connect(host='localhost',user='root', 
                                    # password='root', database='fo_properties',)
# print("DB connection successful")
# cursor = connection.cursor()

app = Flask(__name__)

@app.route("/")
def index():
    return "Welcome to Faroese Properties"

@app.route("/python")
def python():
    connection = db.openDB()
    cursor = db.openCursor(connection)

    select_query = "SELECT * FROM properties"
    cursor.execute(select_query)
    records = cursor.fetchall()
    value = cursor.rowcount
    print("Total number of properties are: ", cursor.rowcount)

    cursor.close()
    connection.close()
    return render_template("registration.html",data=records,name="Python")

@app.route("/registration")
def reg():
    return "FaroeseProperties Registration details"




if __name__ == "__main__":
    app.run(debug=True)