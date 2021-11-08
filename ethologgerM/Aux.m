classdef Aux
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Static)
        function intvls = cont_intvls(labels)
            intvls = [1; (find(diff(labels))+1);size(labels,1)];
        end
        
        function intvl_locs = rem_overlap_intvls(intvl_locs,col)
            while sum(diff(intvl_locs(:,col))<0)
                idx = find(diff(intvl_locs(:,col))<0,1);
                intvl_locs(idx,col) = intvl_locs(idx+1,col);
            end
            
            while sum(arrayfun(@(x) intvl_locs(x,2)<intvl_locs(x+1,2) && intvl_locs(x,2)>intvl_locs(x+1,1),1:size(intvl_locs,1)-1))
                for i=1:size(intvl_locs,1)-1
                    if intvl_locs(i,2)<intvl_locs(i+1,2) && intvl_locs(i,2)>intvl_locs(i+1,1)
                        intvl_locs(i,2) = intvl_locs(i+1,2);
                    end
                end
            end
        intvl_locs = unique(intvl_locs,'rows');
        
        
        [counts, values] = histcounts(intvl_locs(:,2),min(intvl_locs(:,2))-1:max(intvl_locs(:,2)+1));
        repeatedElements = values(counts >= 2);
        repeatedLocs = arrayfun(@(x) find(intvl_locs(:,2)==x),repeatedElements,'UniformOutput',false);
        keepLocs=setDiff(1:size(intvl_locs,1),cell2mat(repeatedLocs'));
        clean_intvls = intvl_locs(keepLocs,:);
        selectedStartLocs = cellfun(@(x) min(intvl_locs(x,1)),repeatedLocs,'UniformOutput',false);
        selectedEndLocs = cellfun(@(x) unique(intvl_locs(intvl_locs(:,1)==x,2)),selectedStartLocs,'UniformOutput',false);
        add_intvls = [cell2mat(selectedStartLocs)' cell2mat(selectedEndLocs)'];
        clean_intvls = [clean_intvls;add_intvls];
            
        
        end
        
        
        function ret = sliding_window(seq,n,s)
            n= fix(n/2);
            
            for i=1:s:n
                p1(i) = {seq(1:i+(n-1))};
            end
            %crude code below...
            z=1;
            sub=1;
            for i=n:s:numel(seq)-1
                try
                    p2(z) = {seq(1+i-n:i+n)};
                catch
                    p2(z) = {seq(1+i-n:i+n-sub)};
                    sub=sub+1;
                end
                z=z+1;
            end
            ret = [p1 p2];
        end
    end
end

