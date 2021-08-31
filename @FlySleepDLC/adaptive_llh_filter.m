function [dfPose, pfilt] = adaptive_llh_filter(dfPose,dfLlh)

varNames = dfLlh.Properties.VariableNames;

pfilt = table;
for i=1:numel(varNames)
    llh = dfLlh.(varNames{i});
    h = histogram(llh,10,'BinLimit',[min(llh) max(llh)]);
    a = h.Values;
    b = h.BinEdges;
    rise_a = find(diff(a)>=0);
    
    if isempty(rise_a)
        t_llh = b(1);
    elseif numel(rise_a)<2
            if rise_a(1) <1
                t_llh = b(rise_a(1));
            else
                t_llh = (b(rise_a(1)) + b(rise_a(1)-1))/2;
            end
    else
        t_llh = (b(rise_a(2)) + b(rise_a(2)-1))/2;
    end
    
    if t_llh < 0.9
        pfilt.(varNames{i})  = round(sum(llh < t_llh)/ numel(llh),5);
        
        x_arr = dfPose.(strcat(varNames{i},"_x"));
        y_arr = dfPose.(strcat(varNames{i},"_y"));
        
        bt_idx = find(llh<t_llh);
        
        for j=1:numel(bt_idx)
            if j==1
                continue
            else
                x_arr(j) = x_arr(j-1);
                y_arr(j) = y_arr(j-1);
            end
        end
        
        dfPose.(strcat(varNames{i},"_x")) = x_arr;
        dfPose.(strcat(varNames{i},"_y")) = y_arr;
    end
end

        
        

