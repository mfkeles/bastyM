%add DLC body part labels to a given image using the training dataset

folderPath = 'Z:\mfk\backup_maDLC\BackUp_8_30_22\LiquidFoodDLC-Mehmet-2020-03-23\labeled-data\20210816_Fly12_M_B_6d_8am-08162021175307';


labelFile = dir(fullfile(folderPath,'Collected*.csv'));

opts = detectImportOptions(fullfile(labelFile.folder,labelFile.name));

opts.VariableDescriptionsLine = 2;

opts.VariableUnitsLine = 3;

labelData = readtable(fullfile(labelFile.folder,labelFile.name),opts,'ReadVariableNames',true);

underscore_arr = cell(1,numel(labelData.Properties.VariableUnits));

underscore_arr(:) = {'_'};

varNames = strcat(labelData.Properties.VariableDescriptions,underscore_arr,labelData.Properties.VariableUnits);

varNames{2} = '__';

labelData.Properties.VariableNames = varNames;

idx = cellfun(@(x) strcmp(x,'_'),labelData.Properties.VariableNames);

flyName = cellfun(@(x) strcmp(x,'__'),labelData.Properties.VariableNames);

labelData.Properties.VariableNames{idx} = 'imgPath';

labelData.Properties.VariableNames{flyName} = 'flyName';


%load images
for i = 1:height(labelData)
clf
img = imread(fullfile(labelFile.folder,labelData.imgPath{i}));
img = rgb2gray(img);
image(img)
axis image off
colormap gray
hold on
subTX = labelData(:,4:2:end);
subTY = labelData(:,5:2:end);
h_data = scatter(zeros(1,size(subTX,2)),zeros(1,size(subTY,2)),15,jet(size(subTY,2)),'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold off;

h_data.XData = subTX{i,:};
h_data.YData = subTY{i,:};
drawnow;

[~,name,~] = fileparts(labelData.imgPath{i});

exportgraphics(gcf,fullfile(labelFile.folder,strcat(name,'_labeled.pdf')),'Resolution',300);
end

