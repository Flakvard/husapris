import csv
import mysql.connector
import faroeseProps as fp


def insertPropsToDB(property_list):
    try:
        connection = openDB()
        # Create a cursor object to interact with the database
        cursor = connection.cursor()

        # Define the input parameters for the stored procedure
        for prop in property_list:
            # prop.prices, 
            # prop.LatestPrices,
            # prop.validDates,
            # prop.imgs 
            print(prop.websites+'_'+prop.cities+'_'+prop.postNums+'_'+prop.addresses+'_'+prop.houseNums)
            website = prop.websites 
            yearbuilt = prop.dates
            insideM2 = prop.buildingSizes
            outsideM2 = prop.landSizes
            rooms = prop.rooms
            floorLevels = prop.floors
            address_text = prop.addresses
            houseNum = prop.houseNums
            city_text = prop.cities
            postNum = prop.postNums

            # Call the stored procedure with the input parameters
            cursor.callproc('InsertPropertyWithAddressAndCity', (website, yearbuilt, insideM2, outsideM2, rooms, floorLevels, address_text, houseNum, city_text, postNum))

            # Commit the changes to the database
            connection.commit()

        # Close the cursor and the database connection
        cursor.close()
        connection.close()
    finally:
        print("insertation done")



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



property_list = []
property_list = fp.FaroesProperties.readInCSV("2023-10-03_export_data.csv")
insertPropsToDB(property_list)