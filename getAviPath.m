function obj = getAviPath(obj,pathIN)

%find file name, extension and the path

if isa(pathIN,'char')
    
    aviPath = [pathIN];
    
    %get the file name
    aviStr = '.avi';
    PathExtCut = aviPath(1:strfind(aviPath,aviStr)-1);
    PathParts = strsplit(PathExtCut,filesep);
    
    % Save filename (no extension) and folder path
    obj.File = PathParts{end};
    obj.Folder = [ fileparts(aviPath) filesep ];
    
    % Check if the file is DLC analyzed
    csvList = dir([Folder File 'DLC*.csv']);
    
    if isempty(csvList)
        %DLC not analyzed
        disp('Video is not analyzed...')
    elseif size(csvList,1)>2
        %DLC analyzed multiple snapshot might exist
        %TODO integrate multiple snapshot/network comparison
        disp('In construction..')
    else
        if size(csvList,1)==1
            %single csv file exist.
            obj.DLC = fullfile(csvList.folder,csvList.name);
        else
            if isempty(strfind(csvList(1).name,'filtered'))
                obj.DLC = fullfile(csvList(1).folder,csvList(1).name);
                obj.DLCfiltered = fullfile(csvList(2).folder,csvList(2).name);
            else
                obj.DLC = fullfile(csvList(2).folder,csvList(2).name);
                obj.DLCfiltered = fullfile(csvList(1).folder,csvList(1).name);
            end
        end
    end
    
else
    error('Path is not a string')
end
