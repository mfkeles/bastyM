%Plot Positional Data for Given Folders



folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';

agg = aggregatePosData(folderPath);

plotAggPosData(agg,folderPath)


function agg = aggregatePosData(folderPath,position_cfg)

if nargin<2
    pathIN = 'C:\Users\Mehmet Keles\Desktop\git_dir\DLC-FlySleep\bastyM\configuration_examples\position_cfg.yaml';
    position_cfg = ReadYaml(pathIN);
end

folderList = dir(fullfile(folderPath,'20*'));


n=1;
for i=1:numel(folderList)

    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*200000.csv'));

    if isfile(fullfile(filePath.folder,'tSnap.mat'))


        load(fullfile(filePath.folder,'tSnap.mat'));

        pos = PositionExtraction(position_cfg,5,tSnap,30,sNames);

        pos.calculate_dormant_position;

        pos.calculate_median_bout('thor_post');

        pos.extract_bout_distance_feat('thor_post_halt');

        pos.extract_bout_distance_feat('origin_prob');

        pos.extract_bout_distance_feat('origin_thor_post');

        save(fullfile(filePath.folder,'poswtsnap.mat'),'pos');

        clf
        PositionExtraction.plotPositionVaryDur(pos.median_bouts.thor_post,'w',12)

        exportgraphics(gcf,fullfile(filePath.folder,'positionBoutDur.pdf'),'Resolution',300,'ContentType','vector')

        agg{n}.med_data = pos.median_bouts;
        agg{n}.distance_feat = pos.distance_feat;

        %     else
        %         load(fullfile(filePath.folder,'poswtsnap.mat'));

        n=n+1;
    end
end
end

function plotAggPosData(agg,folderPath)


clf
for j =1:numel(agg)
    med_data = agg{j}.med_data.thor_post;
    x_col = find(cellfun(@(x) contains(x,'_x'),med_data.Properties.VariableNames));
    y_col = find(cellfun(@(x) contains(x,'_y'),med_data.Properties.VariableNames));

    col = Plotter.tricolors();

    boutFilter = zeros(numel(med_data.rest_dur),1);
    boutFilter(med_data.rest_dur<30*60) = 1;
    boutFilter(med_data.rest_dur>=30*60) = 2;
    boutFilter(med_data.rest_dur>=30*60*5) = 3;

    titles{1} = '\color{black}< 1 min';
    titles{2} = '\color{black}1 min < bout < 5 min';
    titles{3} = '\color{black}> 5 min';


    for i=1:3
        h=subplot(1,3,i);
        hold all
        Plotter.modSubPlot(h,12,'w')
        scatter(med_data{boutFilter==i,x_col},med_data{boutFilter==i,y_col},20,col(i,:),'filled','MarkerFaceAlpha',0.7)

    end

end

for i=1:3
    h=subplot(1,3,i);
    axis equal
    box on
    grid on
    [t,~] = title(titles{i});
    t.FontSize = 8;
    set(gca,'ydir','reverse')
    set(gca,'XTick',0:200:1100);
    set(gca,'YTick',0:200:800);
    Plotter.removeTickLabels(gca)
    ylim([0 800])
    xlim([0 1100])
end


exportgraphics(gcf,fullfile(folderPath,'aggPosBoutDur.pdf'),'Resolution',300,'ContentType','vector')

end
