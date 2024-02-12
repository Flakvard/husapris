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
            print(prop.websites+'_'+prop.cities+'_'+prop.postNums+'_'+prop.addresses+'_'+prop.houseNums+'_'+prop.prices+'_'+prop.LatestPrices+'_'+prop.validDates)
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
            price = prop.prices 
            latestPrice = prop.LatestPrices
            validDate =  prop.validDates

            # Call the stored procedure with the input parameters
            cursor.callproc('InsertPropertyWithAddressAndCity', (website, yearbuilt, insideM2, 
                                                                 outsideM2, rooms, floorLevels, 
                                                                 address_text, houseNum, city_text, 
                                                                 postNum, price, latestPrice,validDate 
                                                                 ))
            # Commit the changes to the database
            connection.commit()
            # Fetch the propertyID returned by the stored procedure
            #result = cursor.stored_results() # Get the propertyID returned by the stored procedure 
            # results = [r.fetchall() for r in cursor.stored_results()]
            # print("Result of first stored procedure:", results)
            # # Fetch the propertyID returned by the stored procedure (from the second set of results)
            # propertyID_set = results[1]  # This will be a list of tuples
            # if propertyID_set and len(propertyID_set) > 0:
            #     propertyID = propertyID_set[0][0]  # Extract the value from the first tuple
            #     print("propertyID:", propertyID)
            # else:
            #     print("Property insertion failed")

            # cursor.nextset()  # Move to the next result set (required when using CALL)

            # After calling the stored procedure, insert the image data separately
            # if propertyID is not None :
            #    img = fp.FaroesProperties.getImgs(prop)
            #    img_bytes = bytes(img)
            #    cursor.callproc('InsertOnlyImg', (propertyID , img_bytes))
            #    # Commit the changes to the database
            #    connection.commit()
            # else:
            #     print("Property insertion failed")

    finally:
        # Close the cursor and the database connection
        cursor.close()
        connection.close()
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
# property_list = fp.FaroesProperties.readInCSV("../csv_db/2023-10-05_export_data.csv")
property_list = fp.FaroesProperties.readInCSV("./csv_db/2024-02-12_export_data.csv")
insertPropsToDB(property_list)
