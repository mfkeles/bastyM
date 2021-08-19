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


        

