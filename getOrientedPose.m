function obj = getOrientedPose(obj, threshold)


llh = getSubCoord(obj,'likelihood');
x = getSubCoord(obj,'x');
y = getSubCoord(obj,'y');

counterparts = obj.pose_cfg.("counterparts");
connected_parts = obj.pose_cfg.("connected_parts");
defined_points = obj.pose_cfg.("defined_points");

names = fieldnames(counterparts);

pose_table = table;
llh_table = table;

isTableCol = @(t, thisCol) ismember(thisCol, t.Properties.VariableNames);

for i = 1:numel(names)
    left_part = counterparts.(names{i}){1};
    right_part = counterparts.(names{i}){2};
    
    connected_left = in_nested_list(connected_parts, left_part);
    connected_right = in_nested_list(connected_parts,right_part);
    
    if isempty(connected_left)
       left_llh = mean(llh{:,connected_left},2);
    else
        left_llh = llh{:,left_part};
    end
    
    if isempty(connected_right)
       right_llh = mean(llh{:,connected_right},2);
    else
        right_llh = llh{:,right_part};
    end
    
    orientations.left = [];
    orientations.right = [];
    orientations.idx = 1:size(llh,1);
    
    orientations = threshold_orientation(orientations,threshold,left_llh,right_llh);
    
    orientations = finalize_orientation(orientations, left_llh, right_llh);
    
    if ~isempty(orientations.idx)
        error('Orientaton could not be determined for some frames.');
    end
    
    x_oriented =  zeros(size(x,1),1);
    y_oriented = zeros(size(y,1),1);
    llh_oriented = zeros(size(llh,1),1);
    
    x_oriented(orientations.left) = x.(left_part)(orientations.left);
    y_oriented(orientations.left) = y.(left_part)(orientations.left);
    llh_oriented(orientations.left) = llh.(left_part)(orientations.left);
    
    x_oriented(orientations.right) = x.(right_part)(orientations.right);
    y.oriented(orientations.right) = y.(right_part)(orientations.right);
    llh_oriented(orientations.right) = llh.(right_part)(orientatons.right);
    
    pose_table.([names{i} "_x"]) = x_oriented;
    pose_table.([names{i} "_y"]) = y_oriented;
    llh_table.([names{i}]) = llh_oriented;
end


def_names = fieldnames(defined_points);

for i = 1:numel(def_names)
    def_xval = [];
    def_yval = [];
    def_llhval = [];
    components = defined_points.(def_names{i});
    for k = 1:numel(components)
        if isTableCol(x,components{k}) && isTableCol(y,components{k})
            def_xval(:,end+1) = x.(components{k});
            def_yval(:,end+1) = y.(components{k});
            def_llhval(:,end+1) = llh.(components{k});
        end
        if isTableCol(pose_table,strcat(components{k},"_x")) && isTableCol(pose_table,strcat(components{k},"_y"))
            def_xval(:,end+1) = pose_table.(strcat(components{k},"_x"));
            def_yval(:,end+1) = pose_table.(strcat(components{k},"_y"));
            def_llhval(:,end+1) = llh_table.(components{k});
        end
        
        pose_table.(strcat(def_names{i},"_x")) = mean(def_xval,2);
        pose_table.(strcat(def_names{i},"_y")) = mean(def_yval,2);
        llh_table.(def_names{i}) = mean(def_llhval,2);
    end
end



            
        
    



    function subData = getSubCoord(obj,ind)
        
        IndexC = strfind(obj.Data.Properties.VariableUnits,ind);
        Index = find(not(cellfun('isempty',IndexC)));
        subData = obj.Data(:,Index);
        subData.Properties.VariableNames = obj.Data.Properties.VariableDescriptions(Index);
        
    end

    function return_list = in_nested_list(my_list,item)
        return_list = {};
       for j=1:numel(my_list)
           if sum(ismember(my_list{j},{item}))
               return_list = my_list{j};
           end
       end 
    end


    function orientations = threshold_orientation(orientations, threshold, left_llh, right_llh)
        left_idx = find((left_llh - right_llh)>threshold);
        right_idx = find((right_llh - left_llh)>threshold);
        
        orientations.left = union(orientations.left,left_idx);
        orientations.right = union(orientations.right,right_idx);
        orientations.idx = setdiff(orientations.idx,orientations.left);
        orientations.idx = setdiff(orientations.idx,orientations.right);
    end

    function orientations = finalize_orientation(orientations,left_llh,right_llh)
        left_idx = find(left_llh > right_llh);
        right_idx = find(right_llh >= left_llh);
        
        orientations.left = union(orientations.left,left_idx);
        orientations.right = union(orientations.right,right_idx);
        orientations.idx = setdiff(orientations.idx,orientations.left);
        orientations.idx = setdiff(orientations.idx,orientations.right);
    end


        

