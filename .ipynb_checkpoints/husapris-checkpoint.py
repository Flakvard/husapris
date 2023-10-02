from bs4 import BeautifulSoup
import requests
import re
import csv
from datetime import datetime
import os
import faroeseProps as fp

from PIL import Image
from io import BytesIO

import time
# from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

betriURL = 'https://www.betriheim.fo/'
skynURL = 'https://www.skyn.fo/ognir-til-soelu'
skynimgs = []
betriimgs = []
def scrape_page(driver,website):
    url = f"{website}"
    driver.get(url)
    time.sleep(2)  # Give the page time to load
    return driver.page_source

# Starts up chrome
# driver = webdriver.Chrome()  

options = Options()
options.add_argument("--headless")
options.add_argument("--window-size=1920x1080")
driver = webdriver.Chrome(options=options)

try:  
    betriResponse = scrape_page(driver,betriURL)
    skynResponse = scrape_page(driver,skynURL)
finally:
    driver.quit()     

# betriResponse = requests.get(betriURL)
betriSoup = BeautifulSoup(betriResponse, 'html.parser')


# skynResponse = requests.get(skynURL)
skynSoup = BeautifulSoup(skynResponse, 'html.parser')

properties = []


BetriPropertyWrappers = betriSoup.find_all('article', class_="c-property c-card grid")

SkynPropertyWrappers = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn")
SkynPropertyWrappersNewbid = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn newbid")
SkynPropertyWrappersNewProp = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn newprop")
SkynPropertyWrappersNewPrice = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn newprice")
SkynPropertyWrappersSold = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn sold")
SkynPropertyWrappersFixedPrice = skynSoup.find_all('div', class_="col-md-6 col-sm-6 col-xs-12 col-lg-4 ogn fixedprice")

def CheckValueText(property, attribute, classVal):
    value = property.find(attribute, class_=classVal)
    if value is not None:
        value = value.text
    else:
        value = None
    return value

def addressParse(addresses):
    if str(addresses):
        pattern1 = r"((\w+ )(\w+$))"
        pattern2 = r"(\w+[ ]?[^0-9]+[ ]?[^0-9]+)"
        pattern3 = r"([0-9]+\w?)"
        match1 = re.search(pattern1, addresses)
        match2 = re.search(pattern2, addresses)
        match3 = re.search(pattern3, addresses)
        if match1:
            city = match1.group(3)
            yield city
            postNum = match1.group(2)
            yield postNum
        if match2:
            address = match2.group(1)
            yield address
        if match3:
            houseNum = match3.group(1)
            yield houseNum     

def priceParse(prices):
    if prices:
        pattern = r"(Kr. )"
        match = re.sub(pattern, "", prices)
        pattern = r"(\.)"
        match = re.sub(pattern, "", match)
        return int(match)

def latestPriceOfferParse(latestPriceOffer):
    if latestPriceOffer:
        pattern = r"(Seinasta boð: Kr. )"
        match = re.sub(pattern, "", latestPriceOffer)
        pattern = r"(\.)"
        match = re.sub(pattern, "", match)
        return int(match)

def convert_to_date(last_two_words):
    if last_two_words:
        try:
            # Assuming the last two words are in the format "dd-mm-yyyy, kl HH:MM"
            date_obj = datetime.strptime(last_two_words, "%d-%m-%Y, kl %H:%M")
            return date_obj
        except ValueError:
            return "Invalid date format"

def priceOfferValidDateParse(priceOfferValidDate):
    if priceOfferValidDate:
        pattern = r"(Galdandi til )"
        match = re.sub(pattern, "", priceOfferValidDate)
        formatted_date = convert_to_date(match)
        return formatted_date
        
def priceOfferValidDateParseSkyn(priceOfferValidDate):
    if priceOfferValidDate:
        pattern = r"(galdandi til )"
        match = re.sub(pattern, "", priceOfferValidDate)
        # formatted_date = convert_to_date(match)
        if match:
            try:
                # Assuming the last two words are in the format "dd-mm-yyyy, kl HH:MM"
                date_obj = datetime.strptime(match, "%d.%m.%Y %H:%M")
                return date_obj
            except ValueError:
                return "Invalid date format"
            return formatted_date

def convertToDigits(yearBuilt):
    if yearBuilt:
        pattern = r"([0-9]+)"
        formatted_year = re.search(pattern, yearBuilt)
        # pattern = r"()"
        # formatted_year = re.sub(pattern, "", match)
        return int(formatted_year.group(1))

for property in BetriPropertyWrappers:
    websites = "Betri"
    
    addresses = CheckValueText(property, 'address', "medium")
    addressEntries = addressParse(addresses)
    city = next(addressEntries, None)
    postNum = next(addressEntries, None)
    address = next(addressEntries, None)
    houseNum = next(addressEntries, None)
    # print(houseNum, "---", postNum)
    
    
    prices = CheckValueText(property, 'div', "price")
    priceEntries = int(priceParse(prices))
    
    latestPriceOffer = CheckValueText(property, 'div', "latest-offer")
    latestPriceOfferEntries = latestPriceOfferParse(latestPriceOffer)
    
    priceOfferValidDate = CheckValueText(property, 'div', "valid")
    priceOfferValidDateEntry = priceOfferValidDateParse(priceOfferValidDate)
    
    yearBuilt = CheckValueText(property, 'div', "date")
    yearBuiltEntry = convertToDigits(yearBuilt)
    
    insideM2 = CheckValueText(property, 'div',"building-size")
    insideM2Entry = convertToDigits(insideM2)
    
    outsideM2 = CheckValueText(property, 'div', "land-size")
    outsideM2Entry = convertToDigits(outsideM2)
    
    rooms = CheckValueText(property, 'div', "rooms")
    roomEntry = convertToDigits(rooms)
    
    floors = CheckValueText(property, 'div', "floors")
    floorEntry = convertToDigits(floors) 
    
    # print(address,"-",houseNum,"-",postNum,"-",city,"-",priceEntries,"-"
    #           ,latestPriceOfferEntries,"-",priceOfferValidDateEntry,"-",yearBuiltEntry
    #           ,"-",insideM2Entry,"-",outsideM2Entry,"-",roomEntry,"-",floorEntry)
    
    # Find the first <li> element with class "slide"
    first_slide = property.find('li', class_='slide')
    if first_slide:
    #     # Find the <img> element within the first slide
        img_element = first_slide.find('img')
        if img_element:
            # Extract the 'src' attribute from the <img> element
            image_url = img_element['src']
            betriimgs.append(image_url)

    prop = fp.FaroesProperties(websites, address, houseNum, city, postNum,
                            priceEntries,latestPriceOfferEntries, priceOfferValidDateEntry,yearBuiltEntry,insideM2Entry,
                            outsideM2Entry,roomEntry,floorEntry,image_url)
    
    
    properties.append(prop)


def addressParseSkyn(addresses):
    if addresses:
        pattern1 = r"(\w+[ ]?[^0-9]+[ ]?[^0-9]+)"
        pattern2 = r"([0-9]+\w?)"
        match1 = re.search(pattern1, addresses)
        match2 = re.search(pattern2, addresses)
        if match1:
            address = match1.group(1)   
            yield str(address) 
        if match2:
            houseNum = match2.group(1)
            yield str(houseNum)
        
def removedot(price):
    if price:
        pattern = r"(\.)"
        match = re.sub(pattern, "",price)
        if match:
            prices = match
            return int(prices)

def removeM2(sizeinM2):
    if sizeinM2 == '−':
        return None
    if sizeinM2 == '−                \t\t':
        return None
    if sizeinM2:
        pattern = r"( m2)"
        match = re.sub(pattern, "",sizeinM2)
        if match:
            size = match
            return int(size)

def skynPropertyScraper(SkynPropertyWrappers,slag):
    for property in SkynPropertyWrappers:
        websites = slag
        addresses = CheckValueText(property, 'div', "ogn_headline")    
        addressEntries = addressParseSkyn(addresses)
        address = next(addressEntries, None)
        houseNum = next(addressEntries, None)
        city = CheckValueText(property, 'div', "ogn_adress")  
        postNum = None
        
        prices = CheckValueText(property, 'div', "listprice")
        priceEntries = int(priceParse(prices))
        
        
        LatestPrices = CheckValueText(property, 'div', "latestoffer")
        latestPriceOfferEntries = removedot(LatestPrices)
        
        validDates = CheckValueText(property, 'div', "validto")
        priceOfferValidDateEntry = priceOfferValidDateParseSkyn(validDates)
        
        # Find all div elements with class "col-xs-2 text-justify"
        buildingSizes = CheckValueText(property, 'div',"col-xs-2 col-xs-offset-1 text-justify")
        insideM2Entry = removeM2(buildingSizes)
        
        div_elements = property.find_all('div', class_='col-xs-2 text-justify')
        
        outsideM2Entry = removeM2(div_elements[0].get_text(strip=True))
        rooms = div_elements[1].get_text(strip=True)
        roomEntry = None if rooms == '−' else rooms
        floors = div_elements[2].get_text(strip=True)
        floorEntry = None if floors == '−' else floors
        yearBuilt = div_elements[3].get_text(strip=True)
        yearBuiltEntry = None if yearBuilt == '−' else yearBuilt

        # Find the first <li> element with class "slide"
        first_slide = property.find('div', class_='ogn_thumb')
        if first_slide:
        #     # Find the <img> element within the first slide
            img_element = first_slide.find('img')
        if img_element:
            # Extract the 'src' attribute from the <img> element
            image_url = img_element['src']
            imgUrl = str("https://www.skyn.fo"+image_url)
            # betriimgs.append(image_url)
            skynimgs.append("https://www.skyn.fo"+image_url)
        
        
        prop = fp.FaroesProperties(websites, address, houseNum, city, postNum,
                            priceEntries,latestPriceOfferEntries, priceOfferValidDateEntry,yearBuiltEntry,insideM2Entry,
                            outsideM2Entry,roomEntry,floorEntry,imgUrl)

        properties.append(prop)

       

skynPropertyScraper(SkynPropertyWrappers,"Skyn")
skynPropertyScraper(SkynPropertyWrappersSold,"Skyn: Selt")
skynPropertyScraper(SkynPropertyWrappersNewbid,"Skyn: Nyggj bod")
skynPropertyScraper(SkynPropertyWrappersNewProp, "Skyn: Nyggj ogn")
skynPropertyScraper(SkynPropertyWrappersNewPrice, "Skyn: Nytt bod")
skynPropertyScraper(SkynPropertyWrappersFixedPrice, "Skyn: Fasturprisur")


datenow = datetime.today().strftime('%Y-%m-%d')
file = open(datenow+'_export_data.csv', 'w', newline='')
writer = csv.writer(file)
headers = ['website', 
           'address', 
           'houseNr',
           'postnum',
           'city', 
           'suggest_price',
           'latest_price',
           'priceOfferDueDate',
           'yearbuilt', 
           'insidem2', 
           'outsidem2', 
           'roomqty', 
           'floorlevels',
           'img_urls'
          ]
writer.writerow(headers)
for prop in properties:
    file = open(datenow+'_export_data.csv', 'a', newline='', encoding='utf-8')
    writer = csv.writer(file)
    headers = ([prop.websites, 
                prop.addresses, 
                prop.houseNums, 
                prop.postNums, 
                prop.cities,
                prop.prices, 
                prop.LatestPrices,
                prop.validDates,
                prop.dates, 
                prop.buildingSizes, 
                prop.landSizes, 
                prop.rooms, 
                prop.floors,
                prop.imgs
               ])
    writer.writerow(headers)
    file.close()


