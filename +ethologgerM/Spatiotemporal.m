classdef Spatiotemporal
    %SPATIOTEMPORAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        feature_cfg;
        fps;
        feature_set;
        extraction_functions
        get_delta
        get_mvMean
        get_mvStd
    end
    
    methods
        function obj = Spatiotemporal(feature_cfg,fps)
            %SPATIOTEMPORAL Construct an instance of this class
            %   Detailed explanation goes here
            obj.feature_cfg = feature_cfg;
            obj.fps = fps;
            obj.feature_set = {'pose','distance','angle'};
            obj.extraction_functions = containers.Map(obj.feature_set,{str2func("extract_pose"),str2func("extract_distance"),str2func("extract_angle")});
            
            obj.get_delta = @(x) calculate_delta(x, scale, fps);
            obj.get_mvMean = @(x) calculate_mvMean(x, winsize, fps);
            obj.get_mvStd = @(x) calculate_mvStd(x, winsize, fps);
        end
        
        function tDelta = extract_delta_features(obj,dfPose)
            %returns table
            ft_cfg = obj.feature_cfg;
            delta_scales = ft_cfg.("delta_scales");
            
            tDelta = table;
            
            for i=1:numel(obj.feature_set)
                ft_set_dt = strcat(obj.feature_set{i},"_delta");
                %                 feature_cfg.(feature_set{i}) = obj.feature_cfg.(feature_set{i});
                %                 feature_cfg.(ft_set_dt) = obj.feature_cfg.(ft_set_dt);
                
                extract = obj.extraction_functions(obj.feature_set{i});
                if ~isempty(ft_cfg(ft_set_dt))
                    temp_snap = extract(dfPose,ft.(ft_set_dt));
                    
                    if ~istable(temp_snap)
                        temp_snap = array2table(temp_snap);
                    end
                    
                    temp_delta = calculate_delta(temp_snap,obj.delta_scales,obj.fps);  %ADD OPTION TO DO MORE THAN 1 SCALE
                    
                    temp_delta.Properties.VariableNames = get_column_names(obj.feature_cfg,ft_set_dt);
                    
                    tDelta = [tDelta temp_delta];
                end
                
            end
            
        end
        
        function tSnap = extract_snap_features(obj,dfPose)
            
            ft_cfg = obj.feature_cfg;
            tSnap = table;
            
            for i=1:numel(obj.feature_set)
                extract = extractiont_functions(obj.feature_set{i});
                
                if ~isempty(ft_cfg.(obj.feature_set{i}))
                    temp_snap = extract(dfPose,ft_cfg.(obj.feature_set{i}));
                    if ~istable(temp_snape)
                        temp_snap = array2table(temp_snap);
                    end
                    temp_snap.Properties.VariableNames = get_column_names(ft_cfg,obj.feature_set{i});
                    tSnap = [tSnap temp_snap];
                end
            end
        end
        
        function xy_pose_values = extract_pose(dfPose, body_parts) %returns table
            
            %xy_pose_values = zeros(size(dfLlh,1),numel(body_parts));
            xy_pose_values = table;
            for i=1:numel(body_parts)
                col_names = [strcat(body_parts{i},"_x"),strcat(body_parts{i},"_y")];
                tmp = dfPose(:,col_names);
                if i ==1
                    xy_pose_values = tmp;
                else
                    xy_pose_values = [xy_pose_values tmp];
                end
            end
        end
        
        function name_column = get_column_names(obj,feature_set)
            name_column = [];
            ft_cfg = obj.feature_cfg;
            %     if strcmp(feature_set,'pose')
            %
            %         catStrings = @(x) strjoin([ft_set_dt,x,['s' num2str(obj.deltaScale)]],{'.'});
            %         colNames = cellfun(@catStrings,getColNames(temp_snap));
            %     elseif strcmp(feature_set,'distance')
            %
            %
            %     end
            try
                tmp_cfg = obj.feature_cfg.(feature_set);
            catch
                error("Unknown feature set is given")
            end
            
            if contains(feature_set,"pose")
                ft_names = cellfun(@(x) [strcat(x,"_x"), strcat(x,"_y")],ft_cfg.(feature_set),'UniformOutput',false);
                ft_names = cellflat(ft_names);
                
            else
                ft_names = ft_cfg.(feature_set);
            end
            
            if ~contains(feature_set,"delta")
                try
                    name_column = cellfun(@(x) strcat(feature_set,'.',get_feature_name(cellstr(x))),ft_names,'UniformOutput',false);
                catch
                    name_column = cellfun(@(x) strcat(feature_set,'.',get_feature_name(x)),ft_names,'UniformOutput',false);
                end
            else
                scales = ft_cfg.delta_scales;
                name_column = cellfun(@(x) strcat(feature_set, '.' , get_feature_name(x), ".s",num2str(scales))); %TODO ADD MULTIPLE SCALE SUPPORT
            end
            
            function name = get_feature_name(definition)
                if isstruct(definition)
                    fname = fieldnames(definition);
                    name = cell2mat(strcat(fieldnames(definition),'(',strjoin(cellfun(@(x) strjoin(x,'-'),definition.(fname{1}),'UniformOutput',false), ','), ')' ));
                else
                    name = strjoin(definition,'-');
                end
            end
            
        end
        
        function distance_values = extract_distance(obj,dfPose,pairs) %returns array
            distance_values = zeros(size(dfPose,1),numel(pairs));
            
            for i=1:numel(pairs)
                if isstruct(pairs{i})
                    names = fieldnames(pairs{i});
                    distance_group = obj.extract_distance(dfPose,pairs{i}.(names{1}));
                    distance_values(:,i) = obj.get_group_value(distance_group,names{1});
                else
                    xy_values = obj.extract_pose(dfPose,pairs{i});
                    distance_values(:,i) = cellfun(@(x) norm(x),num2cell(xy_values{:,1:2} - xy_values{:,3:4},2)); %calc euc dist
                end
            end
        end
        
        
        function angle_values = extract_angle(dfPose,triplets) %returns array
            
            angle_values = zeros(size(dfPose,1),numel(triplets));
            f_angle = @(x) angle_between_atan2(x(:,1:2)-x(:,3:4),x(:,5:6)-x(:,3:4)); %TODO Check normalization
            
            for i=1:numel(triplets)
                if isstruct(triplets{i})
                    names = fieldnames(triplets{i});
                    angle_group = extract_angle(dfPose,triplets{i}.(names{1}));
                    angle_values(:,i) = get_group_value(angle_group,names{1});
                else
                    xy_values = table2array(extract_pose(dfPose,triplets));
                    for j=1:size(xy_values,1)
                        angle_values(j,i) = f_angle(xy_values(j,:));
                    end
                end
            end
            
        end
        
    end
    
    methods (Static)
        
        function angle = angle_between_atan2(v1,v2)
            %https://www.mathworks.com/matlabcentral/answers/331017-calculating-angle-between-three-points
            %calculate angle at joint1
            angle = atan2(norm(det([v1;v2])),dot(v1,v2));
        end
        
        function group_values = get_group_value(feature_group,opt)
            if strcmp(opt,'avg')
                group_values = mean(feature_group,2);
            elseif strcmp (opt,'min')
                group_values = min(feature_group,[],2);
            elseif strcmp(opt,'max')
                group_values = max(feature_group,[],2);
            else
                error('No matching option found...')
            end
        end
        
        function delta_y = calculate_delta(x,win_length_in_sec,fps) %returns table
            
            win_length = ceil(win_length_in_sec*fps);
            
            get_movmean = @(x) movmean(x, win_length);
            
            y = varfun(get_movmean,x);
            
            get_gradient = @(x) gradient(x,2);
            
            delta_y = varfun(get_gradient,y);
            
        end
    end
end


