classdef FrameExtraction
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        min_dormant;
        tol_duration;
        tol_percent;
        winsize;
        fps;
        threshold_indicator_labels;
        bout_dict;
    end
    
    methods
        function obj = FrameExtraction(min_dormant,tol_duration,tol_percent,winsize)
            %F Construct an instance of this class
            %   Detailed explanation goes here
            obj.min_dormant = min_dormant;
            obj.tol_duration = tol_duration;
            obj.tol_percent = tol_percent;
            obj.winsize = winsize;
      
        end
        
        function val_moving = get_movement_values(obj,tVal,datums)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            tActivity = tVal;
            val_moving = obj.get_frame_values(tActivity,datums);
        end
        
        function labels = get_labels(obj,min_dormant,tol_duration,tol_percent,winsize,s)
            min_dormant = obj.fps*min_dormant;
            tol_duration = obj.fps*tol_duration;
            winsize = obj.fps*winsize;
            tol_percent = obj.fps*tol_percent;
            return_unresolved = 0;
            
            label_win = sliding_window(obj.threshold_indicator_labels,winsize,s); %FINISH THIS FUNCTION
            
            intermediate_labels = zeros(numel(obj.threshold_indicator_labels),1);
            
            for i =1:size(obj.bout_dict,1)
                indicator = obj.bout_dict(i,1);
                 bout_start = obj.bout_dict(i,2);
                    bout_end = obj.bout_dict(i,3);
                
                if indicator == 0 
                    intermediate_labels(bout_start:bout_end) = 0;
                else
                    dur = bout_end-bout_start;
                    short_moving = dur <tol_duration;
                    bout_mid = bput_start + floor(dur/2);
                    mostly_dormant = (sum(label_win(bout_mid)) / winsize) < tol_percent;
                    
                    if short_moving && mostly_dormant
                        intermediate_labels(bout_start:bout_end) = -1 ;%indicates unresolved
                    else
                        intermediate_labels(bout_start:bout_end) = 1;
                    end
                end
            end
            
            obj.intermediate_labels = intermediate_labels;
            
            if ~return_unresolved
                intermediate_labels(intermediate_labels==-1) = 0;
            end
            
            intvls = Aux.cont_intvls(intermediate_labels);
            
            obj.labels = zeros(size(intermediate_labels,1),1);
            
            for i=2:numels(intermediate_labels)
                lbl = intermediate_labeles(intvls(i-1));
                intvl_start = intvls(i-1);
                intvl_end = intvls(i);
                if (intvl_end - intvls_start < min_dormant) && lbl == 0
                    if return_unresolved
                        obj.labels(intvl_start:intlv_end-1)=-1;
                    else
                        obj.labels(intvl_start:intvl_end-1) = 1;
                    end
                else
                    obj.labels(intvl_start:intvl_end-1) = lbl;
                end
            end          
            labels = obj.labels;
        end
        

        function threshold = get_threshold(obj,frame_val,threshold_args)
            num_gmm_comp = threshold_args("n_components");
            threshold_idx = threshold_args("threshold_idx");
            
            [diff_points, cluster_means] = obj.threshold_detection(frame_val,num_gmm_comp);
            
            key = threshold_args("key");
            
            if strcmp(key,"local_min")
                threshold = diff_points(threshold_idx);
            elseif strcmp(key,"local_max")
                threshold = cluster_means(threshold_idx);
            else
                error(["Given threshold key" key "is not defined"])
            end
        end
        
        function obj = set_bouts(obj,frame_val,threshold)
            obj.threshold_indicator_labels = frame_val>threshold;
            obj.bout_dict = obj.get_bouts(obj.threshold_indicator_labels);
        end
    end
    
    methods (Static)
        function frame_val = get_frame_values(tVal,datums)
            if iscell(datums)
            datums = cellflat(cellfun(@(x) cellstr(x),datums,'UniformOutput',false));
            end
              frame_val = sum(tVal{:,datums},2);
            % datum is string char
           
            
        end
        
        function [cluster_boundaries, sorted_means]= threshold_detection(frame_val,num_gmm_comp)%ADD LOG
            X=frame_val;
            GMModel = fitgmdist(frame_val,num_gmm_comp);
            clusters = cluster(GMModel,X);
            [~,idx] = sort(frame_val);
            xc = [frame_val clusters];
            xc_s = xc(idx,:);
            
            X_s = xc_s(:,1);
            clusters_s = xc_s(:,2);
            
            cluster_boundaries = X_s(find(diff(clusters_s))+1);
            sorted_means = sort(GMModel.mu);
        end
        
        function bout_dict = get_bouts(labels)
            intvls = cont_intvls(labels);
            
            for i = 2:numel(intvls)
                indicator = labels(intvls(i-1));
                bout_dict(i,:) = [indicator intvls(i-1), intvls(i)];
            end
        end
    end
end

