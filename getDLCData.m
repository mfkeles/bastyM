function getDLCData(obj)
%GETDLCDATA Loads the .csv files associated with the DeepLabCut analysis
%and temporarily store the data. 
%
%


toLoad=1;
%Check if the .CSV is found automatically upon object creation. 

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
        opts = detectImportOptions(obj.DLC);
        opts.VariableNamesLine = 2;
        obj.Data = readtable(obj.DLC,opts,'ReadVariableNames',true);
    case 2
        opts = detectImportOptions(obj.DLCFiltered);
        opts.VariableNamesLine = 2;
        obj.Data = readtable(obj.DLC,opts,'ReadVariableNames',true);
    case 3
        disp(['No data loaded for ' obj.File]);
end
