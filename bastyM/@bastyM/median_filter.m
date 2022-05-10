function [dfPose] = median_filter(dfPose,order)

dfPose = varfun(@(x) medfilt1(x,order),dfPose);

end

