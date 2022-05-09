folder = 'Y:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

ip_ls = dir(fullfile(folder,'*cb.mat'));
mk_ls = dir(fullfile(folder,'*ip.mat'));


ip_ls = load(fullfile(folder,ip_ls.name));
mk_ls = load(fullfile(folder,mk_ls.name));

ip_ls = ip_ls.ls;
mk_ls = mk_ls.ls;
clear total
compare_labels = {'halt','prob'};


for m=1:numel(compare_labels)
    %grab haltere
    part_ip = ip_ls.Labels.(compare_labels{m});
    part_mk = mk_ls.Labels.(compare_labels{m});
    
    part_ip_arr = part_ip{1}.ROILimits;
    part_mk_arr = part_mk{1}.ROILimits;
    
    %create arrays for the target labels, this allows to take intersection
    target_arr = arrayfun(@(x) part_ip_arr(x,1):part_ip_arr(x,2),1:size(part_ip_arr,1),'UniformOutput',false);
    overlap = [];
    n=1;
    for i=1:size(part_mk_arr,1)
        base = part_mk_arr(i,1):part_mk_arr(i,2);
        results = cellfun(@(x) intersect(base,x),target_arr,'UniformOutput',false);
        if ~sum(cellfun(@(x) ~isempty(x),results))
            overlap(n,:) = [i 0];
            n=n+1;
        else
            overlap(n,:) = [i find(cellfun(@(x) ~isempty(x),results))];
            n=n+1;
        end
    end
    
    %check if there is any labeled by ip but not mk
    ipnotmk = setdiff(1:size(target_arr,2),overlap(:,2));
    if ipnotmk
        %not found in mk's set
        overlap = [overlap ; [zeros(numel(ipnotmk),1)' ;ipnotmk]'];
    end
    
    total.(compare_labels{m}) = overlap;
    total.(compare_labels{m}) = [total.(compare_labels{m}) zeros(size(total.(compare_labels{m}),1),4)];
    
    inds2 = find(total.(compare_labels{m})(:,2));
    inds1 = find(total.(compare_labels{m})(:,1));
    total.(compare_labels{m})(inds2,5:6) = part_ip_arr(total.(compare_labels{m})(inds2,2),:);
    total.(compare_labels{m})(inds1,3:4) = part_mk_arr(total.(compare_labels{m})(inds1,1),:);
end

%compare prob and haltere traces
trace_pos = [11 8];

bparts = fieldnames(total);

snap_fts = ip_ls.Source{:,:};


clf
for i=1:numel(bparts)
    compare_labels = {'halt','prob'};
    plot_arr = total.(bparts{i});
    for j=1:size(plot_arr,1)
        subplot(211)
        if plot_arr(j,1)
            plot(snap_fts(plot_arr(j,3):plot_arr(j,4),trace_pos(i)));
            title(['Start: ',num2str(plot_arr(j,3)),'-',num2str(plot_arr(j,4))]);
        end
        subplot(212)
        if plot_arr(j,2)
            plot(snap_fts(plot_arr(j,5):plot_arr(j,6),trace_pos(i)));
            title(['Start: ',num2str(plot_arr(j,5)),'-',num2str(plot_arr(j,6))]);
        end
            pause
    end

end





%generate histogram's for each labeler (duration etc)





