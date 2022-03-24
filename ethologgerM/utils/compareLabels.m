folder = 'Y:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

ip_ls = dir(fullfile(folder,'*ip.mat'));
mk_ls = dir(fullfile(folder,'*mk.mat'));


ip_ls = load(fullfile(folder,ip_ls.name));
mk_ls = load(fullfile(folder,mk_ls.name));

ip_ls = ip_ls.ls;
mk_ls = mk_ls.ls;

%grab haltere
halt_ip = ip_ls.Labels.halt;
halt_mk = mk_ls.Labels.halt;


halt_ip_arr = halt_ip{1}.ROILimits;
halt_mk_arr = halt_mk{1}.ROILimits;


target_arr = arrayfun(@(x) halt_ip_arr(x,1):halt_ip_arr(x,2),1:size(halt_ip_arr,1),'UniformOutput',false);
overlap = [];
n=1;
for i=1:size(halt_mk_arr,1)
    base = halt_mk_arr(i,1):halt_mk_arr(i,2);
    results = cellfun(@(x) intersect(base,x),target_arr,'UniformOutput',false);
    if ~sum(cellfun(@(x) ~isempty(x),results))
        overlap(n,:) = [i 0];
        n=n+1;
    end
end



%generate histogram's for each 