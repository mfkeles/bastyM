function obj = getOrientedPose(obj, threshold)


llh = getSubCoord(obj,'likelihood');
x = getSubCoord(obj,'x');
y = getSubCoord(obj,'y');

counterparts = obj.pose_cfg.("counterparts");
connected_parts = obj.pose_cfg.("connected_parts");

names = fieldnames(counterparts);
for i = 1:numel(names)
    left_part = counterparts.(names{i}){1};
    right_part = counterparts.(names{i}){2};
    
    connected_left = 
    
end
function subData = getSubCoord(obj,ind)

IndexC = strfind(obj.Data.Properties.VariableUnits,ind);
Index = find(not(cellfun('isempty',IndexC)));
subData = obj.Data(:,Index);
subData.Properties.VariableNames = obj.Data.Properties.VariableDescriptions(Index);

end


end

