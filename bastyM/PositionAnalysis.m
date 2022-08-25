%create objarrays using bastyM



%each folder contains single experiments with associated .csv and .avi
folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';

%folderPath = 'Y:\MK_Migrated\MK_SET4';

%go through each folder to find .avi
folderList = dir(fullfile(folderPath,'20*'));

obj =[];
for i = 1:numel(folderList)
    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*200000.csv'));
    if size(filePath,1) == 1
        %check if tSnap exists
        if ~isfile(fullfile(filePath.folder, 'tSnap.mat'))

            obj{i} = bastyM(fullfile(filePath.folder,filePath.name));

            obj{i}.getOrientedPose;

            dfPose = obj{i}.runFilter(10,23); %filter the traces

            dfPose = AuxFunc.clean_column_names(dfPose);

            spats = Spatiotemporal(obj{i}.feature_cfg,30); %30 is the FPS here

            [tSnap,sNames ] = spats.extract_snap_features(dfPose);

            [tDelta,dNames] = spats.extract_delta_features(dfPose);

            %from that.

            position = AuxFunc.calculate_dormant_position(tSnap,'distance_origin_thor_post',5);

            position = AuxFunc.calculate_median_bout(tSnap,position,'thor_post');


            %save tsnap features
            AuxFunc.save_snap_fts(tSnap,sNames,obj{i},0);

            %save position features
            AuxFunc.save_position(position,obj{i})

            %display the finished
            disp([obj{i}.File ' finished'])
        else
            load(fullfile(filePath.folder,'tSnap.mat'));

            clear position

            position = AuxFunc.calculate_dormant_position(tSnap,'distance_origin_thor_post',5);

            position = AuxFunc.calculate_median_bout(tSnap,position,'thor_post');

            save(fullfile(filePath.folder,'position.mat'),'position')

        end

        %check if tSnap exists, if it does, then calculate dormant position

        %         config = 'C:\Users\Mehmet Keles\Desktop\git_dir\DLC-FlySleep\bastyM\config.mat'; %load CFG with structures
        %
        %         load(config)
        %
        %         frameExt = FrameExtraction(CFG.DORMANT_INTERVALS_ARGS('min_rest'),CFG.REST_INTERVALS_ARGS('tol_duration'),CFG.REST_INTERVALS_ARGS('tol_percent'),CFG.REST_INTERVALS_ARGS('winsize'));
        %
        %
        %
        %         val_moving = frameExt.get_movement_values(tDelta,tDelta.Properties.VariableNames);
        %
dun
    else

        continue
    end
end

clear pos
n=1;
for i = 1:numel(folderList)
    filePath = dir(fullfile(folderList(i).folder,folderList(i).name,'*200000.csv'));
    if size(filePath,1) == 1
        %check if tSnap exists
        if isfile(fullfile(filePath.folder, 'tSnap.mat'))

            load(fullfile(filePath.folder,'position.mat'));

            pos{n} = position;

            clear position
            n=n+1;
        end

        %check if tSnap exists, if it does, then calculate dormant position

        %         config = 'C:\Users\Mehmet Keles\Desktop\git_dir\DLC-FlySleep\bastyM\config.mat'; %load CFG with structures
        %
        %         load(config)
        %
        %         frameExt = FrameExtraction(CFG.DORMANT_INTERVALS_ARGS('min_rest'),CFG.REST_INTERVALS_ARGS('tol_duration'),CFG.REST_INTERVALS_ARGS('tol_percent'),CFG.REST_INTERVALS_ARGS('winsize'));
        %
        %
        %
        %         val_moving = frameExt.get_movement_values(tDelta,tDelta.Properties.VariableNames);
        %

    else

        continue
    end
end

blue = [0,68,136]/255;
red =  [187,85,102]/255;
yellow = [221,170,51]/255;
col = [blue;yellow;red];

clf
for i=1:numel(pos)
    h = subplot(211);
    f1{i} = cdfplot(pos{i}.rest_bouts);
    f1{i}.LineWidth = 0.5;
    f1{i}.Color = [1 1 1];
    hold all


    pos{i}.color = zeros(numel(pos{i}.rest_bouts),1);
    pos{i}.color(pos{i}.rest_bouts<30*60) = 1;
    pos{i}.color(pos{i}.rest_bouts>=30*60) = 2;
    pos{i}.color(pos{i}.rest_bouts>=30*60*5) = 3;

    for j=1:3
        subplot(2,3,j+3)
        scatter(pos{i}.med_data.x_pos(pos{i}.color==j),pos{i}.med_data.y_pos(pos{i}.color==j),5,col(j,:),'filled','MarkerFaceAlpha',0.7)
        hold all
        axis equal
        box off
        xlim([0 1100])
        ylim([0 800])

    end



end

subplot(211)
Plotter.modGcaBlack(gca,10)
h=gca;
set(h,'XTick',[0:10*30*60:max(gca().XTick)])
set(h,'XTickLabel',[0:10:100])
xlabel('Time (min)')
%xlim([0 20*60*40])
[t,s] = title('\color{white}Cumulative Distribution Function for {\itiso^{31}} n=22');

for m=1:3
    subplot(2,3,m+3)
    box on
    Plotter.modGcaBlack(gca,10)
    set(gca,'ydir','reverse')
    Plotter.removeTicks(gca)
end

subplot(2,3,4)
[t,s] = title('\color{white}< 1 min');
t.FontSize = 8;
subplot(2,3,5)
[t,s] = title('\color{white}1 min < bout < 5 min');
t.FontSize = 8;
subplot(2,3,6)
[t,s] = title('\color{white}> 5 min')
t.FontSize = 8;

%folderPath = 'Z:\mfk\DeepLabCut_Videos\MK_Non_WT';
exportgraphics(gcf,fullfile(folderPath,'cdf_pos_analysis.pdf'),'Resolution',300,'ContentType','vector','BackgroundColor','k');




clf
for i=1:numel(pos)
    f1{i} = cdfplot(pos{i}.rest_bouts(pos{i}.rest_bouts>30*60*5));
    f1{i}.LineWidth = 0.5;
    f1{i}.Color = [187,85,102]/255;
    hold all

end

for i=1:numel(wt)
    f1{i} = cdfplot(wt{i}.rest_bouts(wt{i}.rest_bouts>30*60*5));
    f1{i}.LineWidth = 0.5;
    f1{i}.Color = [0,68,136]/255;
    hold all
end

Plotter.modGcaBlack(gca,10)
h=gca;
set(h,'XTick',[0:10*30*60:max(gca().XTick)])
set(h,'XTickLabel',[0:10:130])
xlabel('Time (min)')

clf
%plot ZT throughout time
for i=1:numel(pos)
    scatter(pos{i}.bout_time,pos{i}.rest_bouts,pos{i}.rest_bouts/(30*60),'w','filled')
    hold all
end
Plotter.modGcaBlack(gca,10)
h = gca;
h.XTick = [0:30*60*60*2:1728000] 
h.XTickLabel = {'ZT10','ZT12','ZT14','ZT16','ZT18','ZT20','ZT22','ZT0','ZT2','ZT4'};
h.YTickLabel = round(h.YTick/(30*60));
ylabel('Bout Time (min)');

clf
%plot ZT throughout time
for i=1:numel(pos)
    scatter(pos{i}.bout_time,pos{i}.rest_bouts,pos{i}.rest_bouts/(30*60),'w','filled')
    hold all
end


