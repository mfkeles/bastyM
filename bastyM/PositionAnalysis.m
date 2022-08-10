%create objarrays using bastyM



%each folder contains single experiments with associated .csv and .avi
folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';

%go through each folder to find .avi
folderList = dir(fullfile(folderPath,'20*'));

obj =[];
for i = 1:numel(folderList)
    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*.csv'));
    if size(filePath,1) == 1

        obj{i} = bastyM(fullfile(filePath.folder,filePath.name));

        obj{i}.getOrientedPose;

        dfPose = obj{i}.runFilter(10,23); %filter the traces

        dfPose = AuxFunc.clean_column_names(dfPose);

        spats = Spatiotemporal(obj{i}.feature_cfg,30); %30 is the FPS here

        [tSnap,sNames ] = spats.extract_snap_features(dfPose);

        [tDelta,dNames] = spats.extract_delta_features(dfPose);

        position = AuxFunc.calculate_dormant_position(tSnap,'distance_origin_thor_post',30);

        %save tsnap features
        AuxFunc.save_snap_fts(tSnap,obj,0);

        %save position features
        

        config = 'C:\Users\Mehmet Keles\Desktop\git_dir\DLC-FlySleep\bastyM\config.mat'; %load CFG with structures



        load(config)
        
        frameExt = FrameExtraction(CFG.DORMANT_INTERVALS_ARGS('min_rest'),CFG.REST_INTERVALS_ARGS('tol_duration'),CFG.REST_INTERVALS_ARGS('tol_percent'),CFG.REST_INTERVALS_ARGS('winsize'));



        val_moving = frameExt.get_movement_values(tDelta,tDelta.Properties.VariableNames);


    else
        continue
    end
end



[labeledRegions, numberOfRegions] = bwlabel(bwareafilt((clusters==1),[1,inf]));

scatter(1:numel(val_moving),val_moving,10,clusters,'filled');

%try removing when the values equal to 1
