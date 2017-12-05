import pandas as pd
import cs689_utils
import numpy as np

titanicfile = "titanic.csv"

titanic_ppl = pd.read_csv (titanicfile)

newDataFrame = pd.DataFrame(titanic_ppl, columns = ['PassengerId', 'Name', 'Sex', 'Age', 'Fare', 'Pclass'])

fareArray = np.floor(np.asarray(newDataFrame.Fare)).astype(int)

newDataFrame['FareUpdated'] = np.floor(fareArray/3).astype(int)
newDataFrame['Fare'] = fareArray

newDataFrame = newDataFrame.set_index(['Pclass', 'FareUpdated', 'Fare'], drop = False)
newDataFrame['Rank'] = newDataFrame.index
newDataFrame.to_html('Put your outputs here!/Load_Titanic.html')

for index, row in newDataFrame.iterrows():
    if int(row['PassengerId']) % 20 == 0:
        cs689_utils.log("The passenger Id {0} has a rank value of {1}".format(row["PassengerId"], row['Rank']))

cs689_utils.log("The length is {}".format(newDataFrame.shape[0]))

# for ttnc_person in titanic_ppl.Name:
#     famname = ttnc_person.split(',')[0]
#     print (ttnc_person + " was on the Titanic and the family name was " + famname)

