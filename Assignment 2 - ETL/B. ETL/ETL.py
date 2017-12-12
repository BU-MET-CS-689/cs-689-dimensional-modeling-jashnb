import cs689_utils
import psycopg2
import pandas as pd
import random

entriesInDatabase = 0
connDB = psycopg2.connect("dbname=postgres user=postgres host=localhost port=54321 password=bitnami")

dbCur = connDB.cursor()

file = "Energy Census and Economic Data US 2010-2014.csv"

#Reading the provided CSV file using pandas
CSVContents = pd.read_csv(file)

newDataFrame = pd.DataFrame(CSVContents, columns = ['StateCodes', 'State', 'Region', 'Division'])

#Drop the constraint
# dropFactConstraint = "ALTER TABLE us_national_statistics.fact_person_economic_info DROP CONSTRAINT IF EXISTS location_key_const"
# dbCur.execute(dropFactConstraint)
# connDB.commit()

#Dropping the location dimension table if exists
dropTable = "DROP TABLE IF EXISTS us_national_statistics.Location_Dim CASCADE"
dbCur.execute(dropTable)
connDB.commit()


#Create the location dimension table
createQuery = "CREATE TABLE IF NOT EXISTS us_national_statistics.Location_Dim(ID INT PRIMARY KEY, StateCode TEXT, State TEXT, Region REAL, Division REAL);"

dbCur.execute(createQuery)
connDB.commit()

#Insert records in the location dimension table
for index, row in newDataFrame.iterrows():
    insertQuery = "INSERT INTO us_national_statistics.Location_Dim(ID,StateCode,State,Region,Division) VALUES (%s,%s,%s,%s,%s);"
    dbCur.execute(insertQuery, (index, row['StateCodes'], row['State'], row['Region'], row['Division']))
    connDB.commit()
    entriesInDatabase += 1
    if index%50 == 0:
        cs689_utils.log("Inserted record number {} in location_dim".format(index))

#Get relevant columns from the person info table
selectPersonQuery = "SELECT age,marital_status,income,wireless,internet,own_smartphone,read_newspapers from us_national_statistics.person_economic_info"
dbCur.execute(selectPersonQuery)

personInfoDataFrame = pd.read_sql(selectPersonQuery, connDB)
# print(personInfoDataFrame)

#Drop fact table if exists
dropTable = "DROP TABLE IF EXISTS us_national_statistics.fact_person_economic_info CASCADE"
dbCur.execute(dropTable)
connDB.commit()

#Create new fact table
createFactTableQuery = "CREATE TABLE IF NOT EXISTS us_national_statistics.fact_person_economic_info(FACT_ID INT PRIMARY KEY, age INT, marital_status INT, income REAL, wireless INT, own_smartphone INT, read_newspapers INT, location_key INT)"
dbCur.execute(createFactTableQuery)
connDB.commit()

#Add a foreign key reference
alterFactTableQuery = "ALTER TABLE us_national_statistics.fact_person_economic_info ADD CONSTRAINT location_key_const FOREIGN KEY(location_key) REFERENCES us_national_statistics.location_dim(ID)"
dbCur.execute(alterFactTableQuery)
connDB.commit()

#Add values in the fact table by generating a random integer between 0 and 51 for the location_key column
for index, row in personInfoDataFrame.iterrows():
    insertQuery = "INSERT INTO us_national_statistics.fact_person_economic_info(FACT_ID,age,marital_status,income,wireless,own_smartphone,read_newspapers,location_key) VALUES (%s,%s,%s,%s,%s,%s,%s,%s);"
    dbCur.execute(insertQuery, (index, row['age'], row['marital_status'], row['income'], row['wireless'], row['own_smartphone'], row['read_newspapers'],random.randint(0,51)))
    connDB.commit()
    entriesInDatabase += 1
    if index%50 == 0:
        cs689_utils.log("Inserted record number {} in fact table".format(index))

print("The total number of entries made in database are {}".format(entriesInDatabase))



#Count by state how many persons have access to wireless.
ownQuery = "SELECT loc.statecode, count(*) as total from us_national_statistics.fact_person_economic_info fpei, us_national_statistics.location_dim as loc where fpei.wireless = 1 and fpei.location_key = loc.ID GROUP BY loc.statecode ORDER BY total ASC;"


ownQueryResult = pd.read_sql(ownQuery, connDB)
print('The output of the query is: ')
print(ownQueryResult)