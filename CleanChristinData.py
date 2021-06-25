import os
import pandas as pd
from pathlib import Path
path = "/Users/mehmetkeles/Downloads/Labeled"

directory_contents = os.listdir(path)

filt_list = []

for item in directory_contents:
    nitem = path + "/" + item
    if os.path.isdir(nitem):
        subdir = os.listdir(nitem)
        for subitem in subdir:
            if subitem.endswith(".h5"):
                filt_list.append(os.path.join(nitem,subitem))


separator = "/"

for file in filt_list:
    Data = pd.read_hdf(file)
    old_index = Data.index
    d = {}
    for ind in old_index:
        lind = ind.split("/")
        if "drive" in lind[1]:
            del lind[1]
            edind = separator.join(lind)
            d[ind] = edind
        else:
            d[ind] = separator.join(lind)
    Data.rename(index=d,inplace=True)
    Data.to_hdf(file,"df_with_missing",format = "table", mode = "w")
    Data.to_csv(file[0:-3]+ ".csv")






