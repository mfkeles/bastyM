%DLC FlySleep
%This software package is used to analyze and quality check the outputs of
%DLC tracking.

%TODO replace t with df!!!!

classdef bastyM < handle_light
    properties
        File;
        Folder;
        DLC;
        DLCfiltered;
        DateInt;
        TimeInt;
        Created;
        Modified;
        ChooseFiltered =0;
    end
    
    properties (Transient)
        Data
        OrientedData
        Sensor
        Frames
    end
    
    properties (Hidden)
        threshold
        adaptive_llh_threshold
        median_filter_size
        pose_cfg %TODO: SINGLE CFG STRUCT, AUTO CONFIG LOAD
        feature_cfg
        position_cfg;
        hampelWindow = 10
        rloessWindow = 10
    end
    
    
    properties (SetAccess = private)
        
    end
    
    methods %Constructor - creates object
        
        function  obj = bastyM(pathIN)
            
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
                [filename, name, ext] = fileparts(pathIN);
                if strcmp(ext,".avi")
                    if isa(pathIN,'char')
                        obj = getAviPath(obj,pathIN);
                    else
                        error('Path is not a string')
                    end
                elseif strcmp(ext,".csv")
                    disp("Creating the object using the csv file...")
                    obj.DLC = pathIN;
                    getDLCData(obj);
                    obj.File = name;
                    obj.Folder = filename;
                else
                    error("File extensions need to be either .csv or .avi")
                end
                
            end
            
            try
                getConfigFiles(obj);
            catch
                disp("config file couldn't found")
            end
            %             if ~isempty(obj.File)
            %                 getDateTime(obj);
            %             end
            
        end
    end
    
    methods (Access=public)
        getDLCData(obj)
        getDateTime(obj)
        getAviPath(obj)
        [dfPose, dfLlh] = getOrientedPose(obj,threshold)
        [dfPose] = runFilter(obj,hampelWindow,rloessWindow)
        
    end
    
    methods (Static)
        [dfTemp] = median_filter(dfPose,order)
        [cfg] = read_config(pathIN)
        [dfTemp,pfilt] = adaptive_llh_filter(dfPose,dfLlh,llh_adaptive_filter);

    end
    
    
end





