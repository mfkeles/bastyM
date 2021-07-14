%DLC FlySleep
%This software package is used to analyze and quality check the outputs of
%DLC tracking. 

dfs = DFS;


set(gca, 'TickDir', 'out')


classdef DFS < handle_light
    properties
        
        
    end
    
    properties (Access = private)
        
    end
    
    methods
        
        function  obj = DFS(pathIN)
            
            %if no path
            if nargin == 0 || isempty(pathIN)
                try 
                   [FileName,PathName] = uigetfile('*.avi');
                   obj = getTiffPath(obj, fullfile(PathName, FileName));
                
           