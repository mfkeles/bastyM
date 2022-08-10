folder = 'Y:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

target = dir(fullfile(folder,'*SR.mat'));
base = dir(fullfile(folder,'*CB.mat'));


target = load(fullfile(folder,target.name));
base = load(fullfile(folder,base.name));

target = target.ls;
base = base.ls;
clear total
compare_labels = {'halt','prob'};


for m=1:numel(compare_labels)
    %grab haltere
    part_target = target.Labels.(compare_labels{m});
    part_base = base.Labels.(compare_labels{m});
    
    part_target_arr = part_target{1}.ROILimits;
    part_base_arr = part_base{1}.ROILimits;
    
    %create arrays for the target labels, this allows to take intersection
    target_arr = arrayfun(@(x) part_target_arr(x,1):part_target_arr(x,2),1:size(part_target_arr,1),'UniformOutput',false);
    
    %quality check
    if ~all(diff(part_target_arr,1,2))
        disp('labels contain 0 length bout')
        target_arr(diff(part_target_arr,1,2)==0) = [];
        part_target_arr(diff(part_target_arr,1,2)==0,:) =[];
    end
    
    overlap = [];
    n=1;
    for i=1:size(part_base_arr,1)
        comp = part_base_arr(i,1):part_base_arr(i,2);
        results = cellfun(@(x) intersect(comp,x),target_arr,'UniformOutput',false);
        if ~sum(cellfun(@(x) ~isempty(x),results))
            overlap(n,:) = [i 0];
            n=n+1;
        elseif sum(cellfun(@(x) ~isempty(x),results))>1
            disp('double labeled bout')
            match = find(cellfun(@(x) ~isempty(x),results));
            [~, idx] = max(arrayfun(@(x) length(results{x}),match));
            overlap(n,:) = [i match(idx)];
            n=n+1;
        else
            overlap(n,:) = [i find(cellfun(@(x) ~isempty(x),results))];
            n=n+1;
        end
    end
    
    %check if there is any labeled by target but not basecl
    targetnotbase = setdiff(1:size(target_arr,2),overlap(:,2));
    if targetnotbase
        %not found in mk's set
        overlap = [overlap ; [zeros(numel(targetnotbase),1)' ;targetnotbase]'];
    end
    
    total.(compare_labels{m}) = overlap;
    total.(compare_labels{m}) = [total.(compare_labels{m}) zeros(size(total.(compare_labels{m}),1),4)];
    
    inds2 = find(total.(compare_labels{m})(:,2));
    inds1 = find(total.(compare_labels{m})(:,1));
    total.(compare_labels{m})(inds2,5:6) = part_target_arr(total.(compare_labels{m})(inds2,2),:);
    total.(compare_labels{m})(inds1,3:4) = part_base_arr(total.(compare_labels{m})(inds1,1),:);
end

%compare prob and haltere traces
trace_pos = [11 8];

bparts = fieldnames(total);

snap_fts = target.Source{:,:};


clf
for i=1:numel(bparts)
    compare_labels = {'halt','prob'};
    plot_arr = total.(bparts{i});
    for j=1:size(plot_arr,1)
        subplot(211)
        if plot_arr(j,1)
            plot(snap_fts(plot_arr(j,3):plot_arr(j,4),trace_pos(i)));
            title(['Base - Start: ',num2str(plot_arr(j,3)),'-',num2str(plot_arr(j,4))]);
        end
        subplot(212)
        if plot_arr(j,2)
            plot(snap_fts(plot_arr(j,5):plot_arr(j,6),trace_pos(i)));
            title(['Target - Start: ',num2str(plot_arr(j,5)),'-',num2str(plot_arr(j,6))]);
        end
        pause
    end
    
end





