import cs689_utils
import psycopg2
import pandas as pd
import csv

connDB = psycopg2.connect("dbname=postgres user=postgres host=localhost port=54321 password=bitnami")

file = "Energy Census and Economic Data US 2010-2014.csv"

CSVContents = pd.read_csv (file)

newDataFrame = pd.DataFrame(CSVContents, columns = ['StateCodes', 'State', 'Region', 'Division'])

newDataFrame = newDataFrame.set_index(['Region', 'Division'], drop = False)
newDataFrame["Rank"] = newDataFrame.index

print(newDataFrame)