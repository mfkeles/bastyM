%create objarrays using bastyM

%each folder contains single experiments with associated .csv and .avi
folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';

%go through each folder to find .avi
folderList = dir(fullfile(folderPath,'20*'));

obj =[];
for i = 1:numel(folderList)
    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*.csv'));
    if size(filePath,1) == 1
        obj(i) = bastyM(fullfile(filePath.folder,filePath.name));
        obj{i}.getOrientedPose;
        dfPose = ethologgerM.median_filter(dfPose,9); %13 seems to work best, can be modified depending on fps
        spats = Spatiotemporal(obj.feature_cfg,30); %30 is the FPS here
        oldNames = dfPose.Properties.VariableNames;
        dfPose.Properties.VariableNames = cellfun(@(x) erase(x,'Fun_Fun_'),oldNames,'UniformOutput',false);
        [tSnap,sNames ] = spats.extract_snap_features(dfPose);
        
        
    else
        continue
    end
end