%DLC FlySleep
%This software package is used to analyze and quality check the outputs of
%DLC tracking. 

dfs = DFS;


set(gca, 'TickDir', 'out')


classdef DFS < handle_light
    properties
        Fly
        File
        Folder
        DLC
        DLCfiltered
        Path
        DateInt
        TimeInt
        Created
        Modified
        
    end
    
    properties (Transient)
        Data
        Sensor
        Frames
    end
    
    
    properties (SetAccess = private)
        
    end
    
    methods %Constructor - creates object
        
        function  obj = DFS(pathIN)
            
            %if no path
            if nargin == 0 || isempty(pathIN)
                try 
                   [FileName,PathName] = uigetfile('*.avi');
                   obj = getAviPath(obj, fullfile(PathName, FileName));
                catch
                end
            end
            
            %if path is specified:
            
            if nargin>0 && ~isempty(pathIN)
                if isa(pathIN,'char')
                    obj = getAviPath(obj,pathIN);
                else
                    error('Path is not a string');
                end
            end
            
            
            if ~isempty(obj.File)
                getDateTime(obj);
            
        end
    end
    
    methods (Access=public)
        
    end
    
    
end



        
            
           