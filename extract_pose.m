
function xy_pose_values = extract_pose(dfPose, body_parts)

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