function [dfPose] = median_filter(dfPose,order)
varNames = dfPose.Properties.VariableNames;

for i=1:numel(varNames)
    dfPose.(varNames{i}) = medfilt1(dfPose.(varNames{i}),order);
end

