from datetime import datetime
from dateutil.relativedelta import relativedelta
import cs689_utils

def gendates(days_back, days_total):
    totalRecords = 0
    totalLogEntries = 0

    startDt = (datetime.today() + relativedelta(days=+(-1 * days_back))).replace(hour = 0, minute = 0, second = 0, microsecond = 0)

    for dateOff in range(days_total*24):
        dimDate = startDt + relativedelta(hours=+dateOff)
        string = 'key ' + str(dateOff) + ', fulldate ' + str(dimDate) + ', year '+ str(dimDate.year) + ', quarter ' + str((dimDate.month-1)//3+1) + ', month ' + str(dimDate.month) + ', week '+ str(dimDate.isoweekday()) + ', day ' + str(dimDate.day) + ', hour ' + str(dimDate.hour)

        print (string)
        totalRecords += 1

        if dimDate.hour == 1 and dimDate.day == 1:
            totalLogEntries += 1
            cs689_utils.log(string)

    cs689_utils.log("Total number of rows is {}".format(totalRecords))
    print ("Total number of rows is {}".format(totalRecords))

    cs689_utils.log("Total number of rows in Log is {}".format(totalLogEntries))
    print ("Total number of rows in Log is {}".format(totalLogEntries))

gendates(200,500)