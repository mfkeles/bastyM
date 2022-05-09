classdef AuxFunc
    %Auxiliary Functions used in basty pipeline. 
    properties
        
    end
    
    methods (Static)
        function intvls = cont_intvls(labels)
            intvls = [1; (find(diff(labels))+1);size(labels,1)];
        end
        
        function intvl_locs = rem_overlap_intvls(intvl_locs)
            %removes overlapping intervals when interval indices are
            %provided (i.e. idx1:idx2)
            
            while sum(diff(intvl_locs(:,1))<0)
                idx = find(diff(intvl_locs(:,1))<0,1);
                intvl_locs(idx,1) = intvl_locs(idx+1,1);
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
            keepLocs=setdiff(1:size(intvl_locs,1),cell2mat(repeatedLocs'));
            clean_intvls = intvl_locs(keepLocs,:);
            selectedStartLocs = cellfun(@(x) min(intvl_locs(x,1)),repeatedLocs,'UniformOutput',false);
            selectedEndLocs = cellfun(@(x) unique(intvl_locs(intvl_locs(:,1)==x,2)),selectedStartLocs,'UniformOutput',false);
            add_intvls = [cell2mat(selectedStartLocs)' cell2mat(selectedEndLocs)'];
            clean_intvls =sortrows([clean_intvls;add_intvls]);
            
            while sum(arrayfun(@(x) clean_intvls(x,1)>clean_intvls(x-1,1) && clean_intvls(x,2)<clean_intvls(x-1,2),2:size(clean_intvls,1)))
                rem_intvls = [];
                for i=2:size(clean_intvls,1)
                    if clean_intvls(i,1)>clean_intvls(i-1,1) && clean_intvls(i,2)<clean_intvls(i-1,2)
                        rem_intvls(end+1) = i;
                    end
                end
                clean_intvls(rem_intvls,:) = [];
            end
             intvl_locs = clean_intvls;
        end
        
       
        
        function synthetic_trace = generate_synthetic_set(numOfPeaks)
            %generates a synthetic prob pump trace for given number of peaks, similar to the
            %behavioral data. 
            synth = sinc(-1.8:1/20:1.8);
            synth = synth+abs(min(x));
            synthetic_trace = arrayfun(@(x) repmat(synth,1,x),1:numOfPeaks,'UniformOutput',false);
            
        end
        
        function save_snap_fts(tSnap,sNames,obj,saveascsv)
            %save Snap Features 
            tmp_arr = table2array(tSnap);
            if saveascsv
                writematrix(tmp_arr,fullfile(obj.Folder,'snapfts.csv'));
                writecell(sNames,fullfile(obj.Folder,'snapNames.csv'));
                save(fullfile(obj.Folder,'tSnap.mat'),'tSnap','sNames');
            else
                 save(fullfile(obj.Folder,'tSnap.mat'),'tSnap','sNames');
                
            end
            
        end 
        
        function exportAnnotatedData(lsPath)
            %exports annotated traces from ls file
            ls = load(lsPath);
            [filepath,name,~] = fileparts(lsPath);
            tmpPath = fullfile(filepath,[name '_exported']);
            
            if ~isfolder(tmpPath)
                mkdir(tmpPath)
            end
            varNames = ls.ls.Labels.Properties.VariableNames;
            for i=1:numel(varNames)
                if ~isempty(ls.ls.Labels.(varNames{i}){:})
                    try
                        tmpArr = ls.ls.Labels.(varNames{i}){1}.ROILimits;
                        writematrix(tmpArr,fullfile(tmpPath,[name '_' varNames{i} '.csv']));
                    catch
                        disp(['Skipping ' varNames{i}])
                      
                    end
                end
            end
        end
            
        function snapArr = importSnapFeatures(snapPath)

            snapTable  = readtable(snapPath);
            snapArr = table2array(snapTable);
            snapArr(:,1) = [];
            snapArr(1,:) = [];

        end
        
        function save_labels(ls,obj)
            save(fullfile(obj.Folder,'ls.mat'),'ls');
        end
        
        function calc_zt_time(idxs)
            %this function assumes FPS is 30 and ZT10 is the start point
            
        end
        
        
        function hour = frame_to_hours(frames,fps)
            x = seconds(frames/fps);
            x.Format = 'hh:mm:ss';
            hour = x;
            
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

