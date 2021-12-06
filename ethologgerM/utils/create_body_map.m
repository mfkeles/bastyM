function create_body_map(config_path,target_path,boxsize)
%creates zoomed in images of labeled training set body parts. Used to
%identify uniformity in the frames.
%check if target path exists
if ~isfolder(target_path)
    mkdir(target_path);
end

[filepath,~,~] = fileparts(config_path);

%enter labeled data folder
labeled_data_dir = dir(fullfile(filepath,'labeled-data'));
mainfolder = labeled_data_dir(1).folder;
labeled_data_folders = {labeled_data_dir([labeled_data_dir.isdir]).name};
labeled_data_folders = labeled_data_folders(~ismember(labeled_data_folders ,{'.','..'})); %remove junk
labeled_data_folders = labeled_data_folders(~endsWith(labeled_data_folders ,'labeled')); %remove "labeled" folders from list

imageData = table;
nameData = table;
for i=1:numel(labeled_data_folders)
    csvFile = dir(fullfile(mainfolder,labeled_data_folders{i},"CollectedData*.csv"));
    if ~isempty(csvFile)
        if numel(csvFile)>1
            pickIdx = ~contains({csvFile.name},"windows");
            csvFile = csvFile(pickIdx);
        end
        csvFilePath = fullfile(csvFile.folder,csvFile.name);
        opts = detectImportOptions(csvFilePath);
        opts.VariableDescriptionsLine = 2;
        opts.VariableUnitsLine = 3;
        tempName = readtable(csvFilePath,opts);
        tempName = tempName(:,1);
        opts = setvartype(opts,'double');
        tempData = readtable(csvFilePath,opts);
        if i==1
            imageData = tempData;
            nameData = tempName;
        else
            imageData = [imageData ;tempData];
            nameData = [nameData ;tempName];
        end
    end
end

imageData.scorer = nameData.scorer;

bpList = imageData.Properties.VariableDescriptions;
temp_arr = imageData.Properties.VariableDescriptions;
bpList = bpList(2:2:end);

%find ~nan images for each body part
missingVals = ~ismissing(imageData);
missingVals = missingVals(:,2:2:end);

%create a structure with fields that contain x,y and image path for each
%bodypart

for i=1:numel(bpList)
    chooseCol = strcmp(temp_arr,bpList{i});
    chooseRow = missingVals(:,i);
    filtValues = imageData{chooseRow,chooseCol};
    pathValues = imageData{chooseRow,1};
    cleanImage.(bpList{i}) = table(pathValues,filtValues(:,1),filtValues(:,2),'VariableNames',{'Path',strcat(bpList{i},'_x'),strcat(bpList{i},'_y')});
end

%cleanImage contains all the necessary data to plot
%load .png
for i=1:numel(fieldnames(cleanImage))
    subdir = fullfile(target_path,bpList{i});
    
    if ~isfolder(subdir)
        mkdir(subdir);
    end
    
    for m=1:numel(cleanImage.(bpList{i}).Path)
        clf
        imname = fullfile(filepath,cleanImage.(bpList{i}).Path{m});
        names = strsplit(imname,filesep);
         names = strjoin([names(end-1),names(end)],'-');
        im = imread(imname);
        coord_x = cleanImage.(bpList{i}).(strcat(bpList{i},'_x'))(m);
        coord_y = cleanImage.(bpList{i}).(strcat(bpList{i},'_y'))(m);
        bounds = size(im);
        [xmin,ymin,coord_x,coord_y] = calc_box_bound(coord_x,coord_y,boxsize,bounds);
        imshow(imcrop(im,[xmin,ymin,boxsize,boxsize]));
        hold all
        scatter(coord_x,coord_y,200,'MarkerFaceColor','r','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
        title(bpList{i})
        saveas(gcf,fullfile(subdir,names),'png')
    end
end

    function [xmin,ymin,nx,ny] = calc_box_bound(x,y,slength,bounds)
        xmin = x - slength/2;
        nx = slength/2;
        ymin = y - slength/2;
        ny = slength/2;
        if x - slength/2<1
            xmin = 1;
            nx = x;
        end
        if x+slength/2>bounds(2)
         difference = (x+slength/2) - bounds(2);
            xmin = bounds(2) - slength;
            nx = slength/2 + difference;
        end
        if y - slength/2<1
            ymin = 1;
            ny = y;
        end
        if y + slength/2>bounds(1)
            difference = (y+slength/2) - bounds(1);
            ymin = bounds(1) - slength;
            ny = slength/2 + difference;
        end
    end
end
