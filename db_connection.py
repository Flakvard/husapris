import csv
import mysql.connector
import faroeseProps as fp


# properties = fp.readInCSV(".\2023-10-02_export_data.csv")
# for prop in properties:
#     print(prop.display())

property_list = []

    # Replace 'your_csv_file.csv' with the actual file path of your CSV file
csv_file_path = "2023-10-02_export_data.csv" #'your_csv_file.csv'

# Open and read the CSV file
with open(csv_file_path, mode='r', newline='', encoding='iso-8859-1') as file:
    reader = csv.reader(file)
    
    # Skip the header row if present
    next(reader, None)

    # Iterate through each row in the CSV file
    for row in reader:
        # Create a Property object and append it to the property_list
        property_obj = fp.FaroesProperties(website=row[0], address=row[1], 
                                        houseNum=row[2], city=row[3],
                                        postNum=row[4], price=row[5],
                                        LatestPrice=row[6],
                                        validDate=row[7],
                                        date=row[8],
                                        buildingSize=row[9],
                                        landSize=row[10],
                                        room=row[11],
                                        floor=row[12],
                                        img=row[13]
                                        )
        property_list.append(property_obj)

for prop in property_list:
    print(prop.display())




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