import csv
import requests
# from io import BytesIO
# from PIL import Image


class FaroesProperties:
    def __init__(self, website=None,
                 address=None, houseNum=None,
                 city=None, postNum=None,
                 price=None,LatestPrice=None, validDate=None,
                 date=None, buildingSize=None,
                 landSize=None, room=None, floor=None,
                 img=None):
        if website is None:
            self.websites = "None"
        self.websites = website
                     
        if address is None:
            self.addresses = "None"
        self.addresses = address
                     
        if houseNum is None:
            self.houseNums = "None"
        self.houseNums = houseNum

        if city is None:
            self.cities = "None"
        self.cities = city

        if postNum is None:
            self.postNums = "None"
        self.postNums = postNum
                     
        if price is None:
            self.prices = "None"
        self.prices = price
                     
        if LatestPrice is None:
            self.LatestPrices = "None"
        self.LatestPrices = LatestPrice
                     
        if validDate is None:
            self.validDates = "None"
        self.validDates = validDate
                     
        if date is None:
            self.dates = "None"
        self.dates = date
                     
        if buildingSize is None:
            self.buildingSizes = "None"
        self.buildingSizes = buildingSize
                     
        if landSize is None:
            self.landSizes = "None"
        self.landSizes = landSize
                     
        if room is None:
            self.rooms = "None"
        self.rooms = room
                     
        if floor is None:
            self.floors = "None"
        self.floors = floor

        if img is None:
            self.imgs = "None"
        self.imgs = img
                     
    def display(self):
        print("Heimasída: ", self.websites, 
              "\nAddressa: ", self.addresses,
              "\nHúsnummar: ",self.houseNums,
              "\nPostnr: ", self.postNums,
              "\nBýur: ", self.cities,
              "\nPrísur: ", self.prices,
              "\nSeinasti bod: ",self.LatestPrices, 
              "\nGaldandi til dato: ", self.validDates,
              "\nDato: ", self.dates,
              "\nm2 í húsinum: ", self.buildingSizes,"\nm2 á økinum: ", self.landSizes,
              "\nRúm: ", self.rooms,
              "\nHæddir: ", self.floors, 
              "\nURL img ", self.imgs,
              "\n")
    def writeToCSV(self):
        print("test")

    def readInCSV(pathToCSV):
        # properties = []
        # FaroesProperties(websites, address, houseNum, city, postNum,
        #                     priceEntries,latestPriceOfferEntries, priceOfferValidDateEntry,yearBuiltEntry,insideM2Entry,
        #                     outsideM2Entry,roomEntry,floorEntry,imgUrl)

        # properties.append(prop)

        # Create an empty list to store Property objects
        property_list = []

        # Replace 'your_csv_file.csv' with the actual file path of your CSV file
        csv_file_path = pathToCSV #'your_csv_file.csv'

        # Open and read the CSV file
        with open(csv_file_path, mode='r', newline='',encoding='utf-8') as file:
            reader = csv.reader(file)
            
            # Skip the header row if present
            next(reader, None)

            # Iterate through each row in the CSV file
            for row in reader:
                # Create a Property object and append it to the property_list
                property_obj = FaroesProperties(website=row[0], address=row[1], 
                                                houseNum=row[2], city=row[4],
                                                postNum=row[3], price=row[5],
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
        return property_list 
        
    def getImgUrl(self):
        if self.imgs != "None":
            return str(self.imgs)

    def getName(self):
        if self.imgs != "None":
            return str(self.cities+'_'+self.addresses+'_'+self.houseNums)

    def getImgs(self):
        # URL of the image
        image_url = self.getImgUrl()
        img_name = self.getName()
        if img_name == None:
            img_name = "unknown"

        # Send an HTTP GET request to the image URL
        response = requests.get(image_url)
        
        if response.status_code == 200:
            # Read the image content
            image_data = response.content
            
            # Determine the file format (PNG or JPEG) based on the 'Content-Type' header
            content_type = response.headers.get('Content-Type', '').lower()
            if 'image/jpeg' in content_type:
                file_extension = 'jpeg'
            elif 'image/png' in content_type:
                file_extension = 'png'
            else:
                print("Unknown image format")
                file_extension = None
            
            if file_extension:
                image = Image.open(BytesIO(image_data))
                return image 
        else:
            print(image_url," ",img_name," ","Failed to download image. Status code:", response.status_code)  
        