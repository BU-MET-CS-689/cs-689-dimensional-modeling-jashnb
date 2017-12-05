import cs689_utils
import psycopg2
import pandas
import csv

stateQuery = 'select numeric_id, us_state_terr, abbreviation, is_state from us_national_statistics.states'

connDB = psycopg2.connect("dbname=postgres user=postgres host=localhost port=54321 password=bitnami")

dbCur = connDB.cursor()

dbCur.execute(stateQuery)

stateInfo = dbCur.fetchall()

# declare a dictionary
stateIsState = {}
stateNameIsState = {}

for thisState in stateInfo:
    # print (thisState[2])
    stateIsState[thisState[2]] = thisState[3]

for thisState in stateInfo:
    # print (thisState[1])
    stateNameIsState[thisState[1]] = thisState[3]

datFrame = pandas.read_sql(stateQuery, connDB)

# for statename in datFrame.us_state_terr:
#     print (statename)

def is_it_a_state_modified(stateValue):
    if len(stateValue) == 2:
       #Check the abbreviation dictionary since I assumed that the abbreviations are of two characters
       if stateIsState.keys().__contains__(stateValue):
           if stateIsState[stateValue] == "State":
               return ("yes, the abbreviated " + stateValue + " is a state")
           else:
               return ("no, the abbreviated " + stateValue + " is not a state")
       else:
           return("Error in abbreviation " + stateValue)
    else:
        # Check the full name dictionary
        if stateNameIsState.keys().__contains__(stateValue):
            if stateNameIsState[stateValue] == "State":
                return ("yes, the full name " + stateValue + " is a state")
            else:
                return ("no, the full name " + stateValue + " is not a state")
        else:
            return ("Error in Full name " + stateValue)

cs689_utils.log(is_it_a_state_modified('Guam'))
cs689_utils.log(is_it_a_state_modified('Delaware'))
cs689_utils.log(is_it_a_state_modified('NY'))
cs689_utils.log(is_it_a_state_modified('AS'))
cs689_utils.log(is_it_a_state_modified('Guam1'))
cs689_utils.log(is_it_a_state_modified('AB'))


householdQuery = "select house.id, house.city, house.zip_code, house.state_name, state.us_state_terr, state.is_state from us_national_statistics.household_income as house INNER JOIN us_national_statistics.states as state on house.state_name = state.us_state_terr where state.is_state <> 'State'"

dbCur.execute(householdQuery)

houseHoldInfo = dbCur.fetchall()

with open('Put your outputs here!/HouseholdQueryOutput.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(houseHoldInfo)

cs689_utils.log("The number of entries in the household query are {}".format(len(houseHoldInfo)))