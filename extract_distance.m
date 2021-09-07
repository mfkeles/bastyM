
function distance_values = extract_distance(dfPose,pairs)
 distance_values = zeros(size(dfPose,1),numel(pairs));
 
 for i=1:numel(pairs)
     if isstruct(pairs{i})
         names = fieldnames(pairs{i});
         distance_group = extract_distance(dfPose,pairs{i}.(names{1}));
         distance_values(:,i) = get_group_value(distance_group,names{1});
     else
         xy_values = extract_pose(dfPose,pairs{i});
         distance_values(:,i) = cellfun(@(x) norm(x),num2cell(xy_values{:,1:2} - xy_values{:,3:4},2)); %calc euc dist
     end
 end
 
 
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