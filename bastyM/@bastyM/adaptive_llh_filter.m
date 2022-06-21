function [dfPose, pfilt] = adaptive_llh_filter(dfPose,dfLlh,apply_right_skewed)

varNames = dfLlh.Properties.VariableNames;

pfilt = table;
for i=1:numel(varNames)
    llh = dfLlh.(varNames{i});
    h = histogram(llh,10,'BinLimit',[min(llh) max(llh)]);
    a = h.Values;
    b = h.BinEdges;
    rise_a = find(diff(a)>=0);
    right_skewed = ~apply_right_skewed;
    
    if numel(rise_a)<2
        t_llh = b(1);
        disp(strcat("Right skewed histogram, llh threshold: ",num2str(t_llh)," for ",varNames{i})); 
        
    elseif numel(rise_a)<3
            if rise_a(1) <2
                t_llh = b(rise_a(1));
            else
                t_llh = (b(rise_a(1)) + b(rise_a(1)-1))/2;
            end
            disp(strcat("Almost right skewed histogram, llh threshold: ",num2str(t_llh)," for ",varNames{i})); 
            right_skewed = false;
    else
        t_llh = (b(rise_a(2)) + b(rise_a(2)-1))/2;
        right_skewed = false;
    end
    
    if t_llh < 0.8 && right_skewed
        pfilt.(varNames{i})  = round(sum(llh < t_llh)/ numel(llh),5);
        
        x_arr = dfPose.(strcat(varNames{i},"_x"));
        y_arr = dfPose.(strcat(varNames{i},"_y"));
        
        bt_idx = find(llh(2:end)<t_llh)+1;
        
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

        
        

