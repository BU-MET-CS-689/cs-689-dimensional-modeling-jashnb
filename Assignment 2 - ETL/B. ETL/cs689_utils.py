import time, os, inspect
####  This file contains simple versions of some 

# Global variables... we will refine this later

global startTime
global outputDir
global topFile

# initialize the global variables

startTime = time.localtime()
stk = inspect.stack()   # not global
topFile = stk[len(stk)-1].filename
if os.getlogin() == "awolfe":
	outputDir = "TempTester"
	os.makedirs(outputDir, exist_ok = True)
else:
	outputDir = "Put your outputs here!"

def log (message):
	simpleLog = open (outputDir + "/ETL_log.txt", "a+")
	simpleLog.write (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + 
		"\t" + os.getlogin() +
		"\t" + topFile + 
		"\t" + message +
		"\n")
	simpleLog.close()

log ("Started at " + time.strftime("%Y-%m-%d %H:%M:%S", startTime))