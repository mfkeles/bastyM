function [dfPose] = runFilter(obj,hampelWindow,rloessWindow)

dfPose = obj.OrientedData;

if nargin < 3
    if isprop(obj,'threshold') && ~isempty(obj.hampelWindow)
        threshold = obj.threshold;
    else
        threshold = 0.5;
    end
end

hdfPose = varfun(@(x) hampel(x,hampelWindow),dfPose);
dfPose  = varfun(@(x) smoothdata(hdfPose,'rloess',rloessWindow));
end
