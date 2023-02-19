import glob, os
import subprocess
import pathlib
import pandas as pd
from datetime import timedelta
import math

target_folder = r'X:\DeepSleepPaperData\Annotated\WT\20200305_Fly4_30FPS_LiquidFood'

vidname = glob.glob(os.path.join(target_folder, '*.avi'))
fix_fmt = True

if len(vidname) > 1:
    print('More videos than expected, getting the largest file')
    size = 0
    for vids in vidname:
        file_size = os.path.getsize(vids)
        if file_size > size:
            size = file_size
            video = vids
else:
    video = vidname[0]

annot_folder = glob.glob(os.path.join(target_folder,'*_exported'))[0]

csv_files = glob.glob(os.path.join(annot_folder,'*.csv'))

for csv in csv_files:
    df = pd.read_csv(csv, header=None)
    bout = 0
    fps = 30

    name = pathlib.Path(csv).stem
    name = name[name.rfind('_')+1:]
    subfolder = os.path.join(os.path.dirname(csv),'SplitVids' + name)
    os.mkdir(subfolder)

    for start, finish in zip(df.iloc[:, 0], df.iloc[:, 1]):
        idx1 = str(timedelta(seconds = math.floor(start / fps)))
        idx2 = str(timedelta(seconds = math.ceil(finish / fps)))
        tempname = name + "_" + str(bout) + "_" + str(start) + "_" + str(finish)
        outputname = os.path.join(subfolder, tempname + ".avi")
        bout += 1
        if fix_fmt:
            command = (
                f"ffmpeg -n -i {video} -ss {idx1} -to {idx2} " f"-c:v libx264 -crf 22 -c:a copy {outputname}"
                #f"ffmpeg -n -i {video} -ss {idx1} -to {idx2} " f"-c:v libx264 -crf 18 -preset fast -pix_fmt yuv420p {outputname}"
            )
        else:
            command = (
                f"ffmpeg -i {video} -ss {idx1} -to {idx2} " f"-c copy {outputname}"
            )

        subprocess.call(command, shell=True)

