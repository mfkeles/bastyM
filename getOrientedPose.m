function obj = getOrientedPose(obj, threshold)


llh = getSubCoord(obj,'likelihood');
x = getSubCoord(obj,'x');
y = getSubCoord(obj,'y');


function subData = getSubCoord(obj,ind)

IndexC = strfind(obj.Data.Properties.VariableUnits,ind);
Index = find(not(cellfun('isempty',IndexC)));
subData = obj.Data(:,Index);
subData.Properties.VariableNames = obj.Data.Properties.VariableDescriptions(Index);

end
