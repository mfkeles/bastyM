from glob import glob
import pandas as pd
import os

folderPath = r'X:\DeepSleepPaperData\Annotated\WT\Fly03052020_M_9am\Analyzed\CSVs'

paths = glob(os.path.join(folderPath, '*00.csv'))
paths.sort()

n = 1
for path in paths:
    if n == 1:
        newFrames = pd.read_csv(path, low_memory=False)

        n=n+1
    else:
        newFrames = pd.concat([newFrames,pd.read_csv(path,low_memory=False,skiprows=[1,2])])

newFrames.to_csv(os.path.join(folderPath, 'concatNew.csv'), index=False)


