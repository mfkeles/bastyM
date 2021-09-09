classdef FrameExtraction
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = F(inputArg1,inputArg2)
            %F Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function val_moving = get_movement_values(obj,tVal,datums)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            tActivity = tVal;
            val_moving = obj.get_frame_values(tActivity,datums);
        end
        
        function threshold = get_threshold(obj,frame_val,threshold_args)
            num_gmm_comp = threshold_args("n_components");
            threshold_idx = threshold_args("threshold_idx");
            
            [diff_points, cluster_means] = obj.threshold_detection(frame_val,num_gmm_comp);
            
            key = threshold_ars("key");
            
            if strcmp(key,"local_min")
                threshold = diff_points(threshold_idx);
            elseif strcmp(key,"local_max")
                threshold = cluster_means(threshold_idx);
            else
                error(["Given threshold key" key "is not defined"])
            end
        end
    end
    methods (Static)
        function frame_val = get_frame_values(tVal,datums)
            % datum is string char
            frame_val = sum(tVal{:,datums},2);
        end
        
        function cluster_boundaries = threshold_detection(frame_val,num_gmm_comp)%ADD LOG
            GMModel = fitgmdist(frame_val,num_gmm_comp);
            clusters = cluster
            
        end
        
    end
    
