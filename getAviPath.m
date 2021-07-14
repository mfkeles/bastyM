function obj = getAviPath(obj,pathIN)

%find file name, extension and the path


if isa(pathIN,'char')
    
    aviPath = [pathIN];
    
    %get the file name
    aviStr = '.avi';
    PathExtCut = aviPath(1:strfind(aviPath,aviStr)-1);
    PathParts = strsplit(PathExtCut,filesep);
    
    % Save filename (no extension) and folder path
    obj.File = PathParts{end,:};
    obj.Folder = [ fileparts(aviPath) filesep ];
    
    % Depending on whether file is registered or not
    pathExpr = '(\.?_reg.tif\>|.tiff?\>)';
    PathExt = char(regexpi(tifPath,pathExpr,'match'));
    
    
else
    error('Path is not a string')
end
