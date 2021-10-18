classdef Aux
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Static)
        function intvls = cont_intvls(labels)
            intvls = [1; (find(diff(labels))+1);size(labels,1)];
        end
        
        
        function pf = sliding_window(seq,n,s)
            n = fix(n,2);
            p1 = 
        end
    end
end

