%DLC FlySleep
%This software package is used to analyze and quality check the outputs of
%DLC tracking. 

classdef FlySleepDLC < handle_light
    properties
        Fly;
        File;
        Folder;
        DLC;
        DLCfiltered;
        Path;
        DateInt;
        TimeInt;
        Created;
        Modified;
        ChooseFiltered =0;
        pose_cfg
        dfPoseFinal
        dfLlhFinal
        
    end
    
    properties (Transient)
        Data
        Sensor
        Frames
    end
    
    properties (Hidden)
        threshold
        adaptive_llh_threshold
        median_filter_size
    end
    
    
    properties (SetAccess = private)
        
    end
    
    methods %Constructor - creates object
        
        function  obj = FlySleepDLC(pathIN)
            
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
            
            
%             if ~isempty(obj.File)
%                 getDateTime(obj);
%             end
            
        end
    end
    
    methods (Access=public)
        getDLCData(obj)
        getDateTime(obj)
        [dfPose, dfLlh] = getOrientedPose(obj,threshold)
        [dfPFilt] = adaptive_llh_filter(dfPose,dfLlh,llh_threshold)
        
    end
    
    methods (Static)
    end
    
    
end



        
            
           