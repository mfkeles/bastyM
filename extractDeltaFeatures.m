function extractDeltaFeatures(obj)

if isempty(obj.feature_cfg)
    disp('Feature configuration not found, attempting to load')
end

feature_set = {'pose','distance','angle'};


extraction_functions = containers.Map(feature_set,{str2func("extract_pose"),str2func("extract_distance"),str2func("extract_angle")});

getColNames = @(x) x.Properties.VariableNames;




get_delta = @(x) calculate_delta(x, scale, fps);
get_mvMean = @(x) calculate_mvMean(x, winsize, fps);
get_mvStd = @(x) calculate_mvStd(x, winsize, fps);

tDelta = table;

for i=1:numel(feature_set)
    ft_set_dt = strcat(feature_set{i},"_delta");
    feature_cfg.(feature_set{i}) = obj.feature_cfg.(feature_set{i});
    feature_cfg.(ft_set_dt) = obj.feature_cfg.(ft_set_dt);
    
    extract = extraction_functions(feature_set{i});
    
    temp_snap = extract(obj.dfPose,feature_cfg.(ft_set_dt));
    
    temp_delta = calculate_delta(temp_snap,obj.deltaScale,obj.FPS);  %ADD OPTION TO DO MORE THAN 1 SCALE
    
    catStrings = @(x) strjoin([ft_set_dt,x,['s' num2str(obj.deltaScale)]],{'.'});
    
    temp_delta.Properties.VariableNames = cellfun(@catStrings,getColNames(temp_snap));
    
    tDelta = [tDelta temp_delta];
    
end


obj.tDelta = tDelta;



end

function xy_pose_values = extract_pose(dfPose, body_parts)

%xy_pose_values = zeros(size(dfLlh,1),numel(body_parts));
xy_pose_values = table;
for i=1:numel(body_parts)
    col_names = {strcat(body_parts{i},"_x"),strcat(body_parts{i},"_y")};
    tmp = dfPose(:,col_names);
    if i ==1
        xy_pose_values = tmp;	
    else
        xy_pose_values = [xy_pose_values tmp];
    end
end    
end



function delta_y = calculate_delta(x,win_length_in_sec,fps)


win_length = ceil(win_length_in_sec*fps);

get_movmean = @(x) movmean(x, win_length);

y = varfun(get_movmean,x);

get_gradient = @(x) gradient(x,2);

delta_y = varfun(get_gradient,y);

end

function extract_distance(dfPose,pairs)
 distance_values = table;
 
 for i=1:numel(pairs)
     
     if isstruct(pairs{i})
         names = fieldnames(pairs{i});
         distance_group = extract_distance(dfPose,pairs{i}.(names));
         distance_values = 
     else
         xy_values = extract_pose(dfPose,pairs{i});
         
         
         
 
 



end


function calculate_mvMean
end

function calculate_mvStd
end
