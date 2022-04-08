

varNames = ls.Labels.Properties.VariableNames;
for i=1:numel(varNames)
    try
        size(ls.Labels.(varNames{i}){1}.ROILimits)
        if ~isempty(ls.Labels.(varNames{i}){1}.ROILimits)
            writematrix(round(ls.Labels.(varNames{i}){1}.ROILimits),strcat('Fly19SDLabels_',varNames{i},'.csv'));
        end
    catch


    end
end