import mysql.connector
from ..flaskmysql import faroeseProps as fp



def openDB():
    connection = mysql.connector.connect(host='localhost',user='root', 
                                        password='root', database='fo_properties',)
    print("DB connection successful")
    cursor = connection.cursor()
    return connection

def closeDB(connection):
    connection.close()
def openCursor(connection):
    cursor = connection.cursor()
    return cursor 

def closeCursor(cursor):
    cursor.close()



def test():
    try:
        connection = mysql.connector.connect(host='localhost',user='root', 
                                            password='root', database='fo_properties',)
        print("DB connection successful")
        cursor = connection.cursor()

        select_query = "SELECT * FROM properties"
        cursor.execute(select_query)
        records = cursor.fetchall()
        print("Total number of properties are: ", cursor.rowcount)

        print("\nProperties")
        for row in records:
            print("propID: ", row[0])
            print("propWebsite: ", row[1])
            # print("propYear: ", 2023-row[2])
            print("propYear: ", row[2])
            print("propM2In: ", row[3])
            print("propM2Out: ", row[3])
            print("propRooms: ", row[4])
            print("propFloors: ", row[5])
        cursor.close()
        connection.close()
    finally:
        print("DB connection closed")