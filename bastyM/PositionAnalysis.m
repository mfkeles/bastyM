%create objarrays using bastyM

%each folder contains single experiments with associated .csv and .avi
folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';

%go through each folder to find .avi
folderList = dir(fullfile(folderpath,'20*'));

obj =[];
for i = 1:numel(folderList)
    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*.csv'));
    if size(filePath,1) == 1
        obj(i) = bastyM(fullfile(filePath.folder,filePath.name));
    else
        continue
    end
end