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
            %check if there is an existing file saved
            if ~isfile(fullfile(obj.Folder,'tSnap.mat'))
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

        end

        function save_position(position,obj)
            save(fullfile(obj.Folder,'position.mat'),'position');
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

        function dfPose = clean_column_names(dfPose)
            oldNames = dfPose.Properties.VariableNames;
            dfPose.Properties.VariableNames = cellfun(@(x) erase(x,'Fun_Fun_'),oldNames,'UniformOutput',false);
        end

        function calc_zt_time(idxs)
            %this function assumes FPS is 30 and ZT10 is the start point

        end


        function hour = frame_to_hours(frames,fps)
            x = seconds(frames/fps);
            x.Format = 'hh:mm:ss';
            hour = x;

        end

        function position = calculate_dormant_position(tSnap,snap_feature,bin)
            %calculate_dormant_position determines the position of a given body part
            %during quiescence bouts.

            %calculate velocity
            meanVel = movmean(abs(diff(tSnap.(snap_feature))),30*bin);

            %use GMM to determine when the animal is active/quiescent
            GMModel = fitgmdist(meanVel,2);

            %lower mean would indicate vel close to zero
            [~,idx] = min(GMModel.mu);

            %cluster the data
            clusters = cluster(GMModel,meanVel);
            
            %remove movements that are smaller 1/6th of a seconds
            amask = bwareafilt((clusters~=idx),[1,5]);
            clusters(amask) = idx;

            %filter out bouts less than 1 second
            mask = bwareafilt((clusters==idx),[30,inf]);




            [labeledRegions, ~] = bwlabel(mask);

            regionIdx = unique(labeledRegions,'sorted');
            regionIdx(regionIdx==0) = [];
            res_arr = arrayfun(@(x) sum(labeledRegions==x),regionIdx);

            position.rest_bouts = res_arr;
            position.movmeanbin = bin;
            position.mask = mask;
            position.snap_feature = snap_feature;
            position.labeledRegions = labeledRegions;
        end

        function position = calculate_median_bout(tSnap,position,body_part_name)
            %calculate median bout determines the median position of the
            %fly during a quiescent bout

            body_part_x = ['pose_',body_part_name, '_x'];
            body_part_y = ['pose_',body_part_name, '_y'];

            x_bouts = arrayfun(@(x) tSnap.(body_part_x)(position.labeledRegions==x),1:max(position.labeledRegions),'UniformOutput',false);
            y_bouts = arrayfun(@(x) tSnap.(body_part_y)(position.labeledRegions==x),1:max(position.labeledRegions),'UniformOutput',false);

            %this is for quality control, checks the std of the x,y
            %position. 10 - 20 pixels is acceptable.
            qc_data = [cellfun(@(x) std(x),x_bouts);cellfun(@(x) std(x),y_bouts)];

            position.qc_data = qc_data;

            x_med = cellfun(@(x) median(x),x_bouts);
            y_med = cellfun(@(x) median(x),y_bouts);

            position.med_data = array2table([x_med',y_med',position.rest_bouts],'VariableNames',{'x_pos','y_pos','rest_dur'});

            %get the zt for the quiescent bout
            bout_time = arrayfun(@(x) round(median(find(position.labeledRegions==x))),1:max(position.labeledRegions));
            position.bout_time = bout_time;
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
