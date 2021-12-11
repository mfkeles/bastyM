%load processed probs

folder = uigetdir;

folder_list = dir(folder);
folder_list = folder_list(~ismember({folder_list.name},{'.','..'}));

fly_table = table;
prob_table = table;
for i=1:numel(folder_list)
    sub_fold = dir(fullfile(folder_list(i).folder,folder_list(i).name,'*.csv'));
    col_name = strsplit(folder_list(i).name,'-');
    snap_stft = sub_fold(ismember({sub_fold.name},{'snap_stft.csv'}));
    
    %load snap_stft.csv
    temp_data = readtable(fullfile(snap_stft.folder,snap_stft.name));
    temp_arr = table2array(temp_data);
    %load prob position, this is a CSV file containing positions of the
    %prob pumps
    prob_csv = sub_fold(contains({sub_fold.name},'prob','IgnoreCase',true));
    prob_dat = readtable(fullfile(prob_csv.folder,prob_csv.name));
    
    %slice 1,2,8,10
    for j = 1:size(prob_dat,1)
        idx = prob_dat{j,:};
        
        indv_event = temp_arr(idx(1):idx(2),[1,2,8,10]); %indices to the desired proboscis pumps
        indv_event = indv_event - indv_event(1,:);
        %flip the downward signals
        if max(indv_event(:,3)) < max(abs(indv_event(:,3)))
            indv_event(:,3) = gnegate(indv_event(:,3));
        end
        fly_table{j,i} = {indv_event};
        
    end
    fly_table.Properties.VariableNames(i) = col_name(1);
    prob_dat.Properties.VariableNames = {'index_start', 'index_end'};
    prob_table{:,i} = {prob_dat};
    prob_table.Properties.VariableNames(i) = col_name(1);
end

%the above code slices col 1 prob_x,2 prob_y, 3 origin-prob and 4 head-prob distance

prob_zt = table;
target_col = 3;
fps = 30;
bin_plot = 0;
for i=1:size(fly_table,2)
    %ugly code!
    clf
    idxes = find(cellfun(@(x) ~isempty(x),fly_table{:,i}));
    %change this if another column is desired
    maxes = max(ceil(cellfun(@(x) max(x(:,target_col)),fly_table{idxes,i}))); %used for plotting
    mins = min(floor(cellfun(@(x) min(x(:,target_col)),fly_table{idxes,i}))); %used for plotting
    prob_locs = table2array(prob_table{:,i}{1});
    ztTime =[];
    trueZT =[];
    pump_strength=[];
    for j=1:numel(idxes)
        if bin_plot
            subplot(6,5,j)
            pl_arr = cell2mat(fly_table{idxes(j),i});
            plot(pl_arr(:,target_col),'LineWidth',1,'Color',[0.8500 0.3250 0.0980]);
            box off
            make_it_black;
            set(gca,'TickDir','out')
            ticss = [0 ceil(size(pl_arr,1)/30)*30];
            xlim([ticss]);
            xticks(ticss);
            xticklabels([0 ticss(end)/30]);
            ylim([mins maxes]);
            tmp_ticks = yticks;
            yticks([tmp_ticks(1) tmp_ticks(end)])
            set(gca, 'FontName','Verdana')
            %calc table name
        end
        dur = AuxFunc.frame_to_hours(round(mean([prob_locs(j,1) prob_locs(j,2)])),fps);
        ztTime(j) =round(rem(10 + hours(dur),24),2); %10 because these vids have starting point of ZT10
        trueZT(j) = round(10+hours(dur),2);
        pump_strength(j) = ceil(length(pl_arr(:,3))/90); %90 because fps*expected duration of a single bout might be overestimating a bit
        title(['\color{white}' 'ZT' num2str(ztTime(j))],'FontName','Verdana')
    end
    prob_zt{:,i} = {[trueZT ; pump_strength]'};
    prob_zt.Properties.VariableNames(i) = fly_table.Properties.VariableNames(i);
    sgtitle(['\color{white}' fly_table.Properties.VariableNames(i)],'FontName','Verdana')
    %exportgraphics(gcf,string(strcat(fly_table.Properties.VariableNames(i),'_pumps_head_prob.pdf')),'Resolution',300,'ContentType','vector','BackgroundColor','k');
end

%prob_zt: col zt and strength

%plot zt + strength
cmap = brewermap(12,'Set3');
clf
n=1;
clear idxses
clear values
for i=1:size(prob_zt,2)
    if i==1
        all_data = [prob_zt{:,i}{1} ones(size(prob_zt{:,i}{1},1),1)*i ones(size(prob_zt{:,i}{1},1),1)*contains(prob_zt.Properties.VariableNames(i),'yF')]; %repmat(cmap(i,:),size(prob_zt{:,i}{1},1),1)];
    else
        all_data = [all_data;prob_zt{:,i}{1} ones(size(prob_zt{:,i}{1},1),1)*i ones(size(prob_zt{:,i}{1},1),1)*contains(prob_zt.Properties.VariableNames(i),'yF')]; %repmat(cmap(i,:),size(prob_zt{:,i}{1},1),1)];
    end
    if  i ~= 11 && contains(prob_zt.Properties.VariableNames(i),'yF')
        subplot(11,1,n)
        pl_data = prob_zt{:,i}{1};
        pl_data((pl_data(:,2)==0),2)=1;
        pl_data= sortrows(pl_data);
        plot(pl_data(:,1),pl_data(:,2),'--','Color','w','LineWidth',1)
        hold all
        scatter(pl_data(:,1),pl_data(:,2),pl_data(:,2)*10,'filled')
        box off
        ylabel('PE Count');
        xlabel('Time (ZT)');
        xlim([10 26])
        xticks([10:2:26])
        xticklabels([10:2:22 0 2])
        set(gca,'FontName','Verdana')
        set(gca,'TickDir','out')
        make_it_black
        grid on
        xlabel('Time (ZT)');
        xticklabels([10:2:22 0 2])
        ylim([0 15])
        h = histogram(pl_data(:,1));
        h.BinEdges = target_edges;
        female_bins(n,:) = h.Values;
        idxses{n}(:) = discretize(pl_data(:,1),target_edges);
        values{n}(:) = pl_data(:,2);
        n=n+1; 
    end
end
clf
all_idx = cell2mat(cat(1,idxses));
all_vals = cell2mat(cat(1,values));
ax = axes('NextPlot','add','FontSize',16,'TickDir','out','FontName','Verdana');
notBoxPlot(all_vals,all_idx)
set(gca,'FontName','Verdana')
make_it_black
xlabel('Time (ZT)');
ylabel('PE Count');
xticklabels([10:2:22 0 2])

all_data(find(all_data(:,2)==0),2)=1;

swarmchart(ones(206,1),all_data(:,1),all_data(:,2)*5,[0.8500 0.3250 0.0980],'filled','MarkerFaceAlpha',0.85,'MarkerEdgeColor','none')
make_it_black
xticklabels([]);
yticks([10:2:26])
yticklabels([10:2:22 0 2])
xticks(1);
camroll(270)
ylabel('Time (ZT)');
set(gca,'FontName','Verdana')
set(gca,'TickDir','out')


%boxplots

boxplot(female_bins)
ax = axes('NextPlot','add','FontSize',16,'TickDir','out');
all_lines = findobj(ax,'Type','Line');
arrayfun(@(x) set(x,'LineStyle','-','Color','w','LineWidth',1),all_lines)
make_it_black
arrayfun(@(box) patch(box.XData, box.YData, [0.8500 0.3250 0.0980], 'FaceAlpha',0.5),myboxes(1:8))
myboxes = findobj(ax,'Tag','Box')

clear fly_mean
%plot means
for i=1:numel(idxses)
    fly_mean(i,1:8) = zeros(8,1);
    
    fly_mean(i,sort(unique(idxses{i}))) = grpstats(values{i},idxses{i},{'mean'});
end


