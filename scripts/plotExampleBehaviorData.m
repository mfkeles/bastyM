%use human annotated data to extract the representative traces for
%described behaviors

folderPath = 'Y:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

filePath = dir(fullfile(folderPath,'*200000.csv'));

obj = bastyM(fullfile(filePath.folder,filePath.name));

obj.getOrientedPose;

dfPose = obj.runFilter(10,23);

spats = Spatiotemporal(obj.feature_cfg,30); %30 is the FPS here

[tSnap,sNames ] = spats.extract_snap_features(dfPose);

%load annotated behaviors:
annotFile = 'FlyF15-08182021173222.csv';

behaviorT = readtable(fullfile(folderPath,annotFile));

