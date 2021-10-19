function getDLCData(obj)
%GETDLCDATA Loads the .csv files associated with the DeepLabCut analysis
%and temporarily stores the data.
%
%


%Check if the .CSV is found automatically upon object creation.
if isempty(obj.DLC)
    disp("DLC path is empty")
    return
end

%DLC Filtered file will be attempted to load by default.
toLoad=1;

if obj.ChooseFiltered
    if isempty(obj.DLCFiltered)
        disp(['No DLC filtered file found switching to DLC for ' obj.File])
        if isempty(obj.DLC)
            disp(['No Analysis file found for ' obj.File])
            toLoad=3;
        else
            toLoad=1;
        end
    else
        toLoad=2;
    end
else
    if isempty(obj.DLC)
        disp(['No analysis file found for' obj.File])
        toLoad=3;
    else
        toLoad=1;
    end
end


switch toLoad
    case 1
        loadData;
        disp('Reading CSV file (no filtering)')
    case 2
        loadData;
        disp('Reading CSV file (filtered)')
    case 3
        disp(['No data loaded for ' obj.File]);
end


    function loadData
        opts = detectImportOptions(obj.DLC);
        opts.VariableDescriptionsLine = 2;
        opts.VariableUnitsLine = 3;
        obj.Data = readtable(obj.DLC,opts,'ReadVariableNames',true);
        underscore_arr = cell(1,numel(obj.Data.Properties.VariableUnits));
        underscore_arr(:) = {'_'};
        obj.Data.Properties.VariableNames =  strcat(obj.Data.Properties.VariableDescriptions,underscore_arr,obj.Data.Properties.VariableUnits);
        
    end
end

