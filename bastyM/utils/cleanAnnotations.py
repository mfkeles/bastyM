import glob, os
import subprocess
from pathlib import Path
import pandas as pd
import re

target_folder = r'X:\DeepSleepPaperData\Annotated\WT\Fly03052020_F_9am\ls4_exported'

sub_folder = [os.path.join(target_folder, name) for name in os.listdir(target_folder) if
              os.path.isdir(os.path.join(target_folder, name))]

csv_files = glob.glob(os.path.join(target_folder, '*.csv'))

minimum_window = 45

for folder in sub_folder:
    folderName = Path(folder).stem

    behavior = folderName.split("Vids", 1)[1]

    # load the csv files
    csvpath = [sub for sub in csv_files if (behavior in sub)]

    # read the csv
    df = pd.read_csv(csvpath[0], header=None)

    # avi list
    # avi_list = glob.glob(os.path.join(folder, '*.avi'))

    wrongPath = os.path.join(folder, 'wrong')

    if os.path.exists(wrongPath) and os.listdir(wrongPath):

        # read the clips to be removed
        avi_list = glob.glob(os.path.join(wrongPath, '*.avi'))

        for avi in avi_list:
            rem_idx = Path(avi).stem.split('_')[-1]

            df.drop(df.loc[df.iloc[:, 1] == int(rem_idx)].index, inplace=True)

    if re.search('halt', behavior, re.IGNORECASE):
        idx = df.iloc[:, 1] - df.iloc[:, 0] <= minimum_window

        addnumber = round((minimum_window - (df.loc[idx, 1] - df.loc[idx, 0])) / 2)

        df.loc[idx, 0] = df.loc[idx, 0] - addnumber
        df.loc[idx, 1] = df.loc[idx, 1] + addnumber

    df.to_csv(os.path.splitext(csvpath[0])[0] + '_clean.csv', index=False, header=False)
