%use human annotated data to extract the representative traces for
%described behaviors

folderPath = 'X:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

filePath = dir(fullfile(folderPath,'*200000.csv'));

obj = bastyM(fullfile(filePath.folder,filePath.name));

obj.getOrientedPose;

dfPose = obj.runFilter(10,23);

dfPose = AuxFunc.clean_column_names(dfPose);

spats = Spatiotemporal(obj.feature_cfg,30); %30 is the FPS here

[tSnap,sNames ] = spats.extract_snap_features(dfPose);

%load annotated behaviors:
annotFile = 'FlyF15-08182021173222.csv';

behaviorT = readtable(fullfile(folderPath,annotFile));


[G behavior] = findgroups(behaviorT.Behavior);


function plotXYTrace(behaviorT,dfPose,behaviorName,bodyPart,folderPath)
%prob pumps
behIdx = behaviorT{ismember(behaviorT.Behavior,behaviorName),2:3};

bodyPart_x = strcat(bodyPart,'_x');
bodyPart_y = strcat(bodyPart,'_y');

targetFolder = fullfile(folderPath,behaviorName);



if ~isfolder(targetFolder)
    mkdir(targetFolder)
end

clf
figure(1)
Plotter.initiatePlot(12,'w','Myriad Pro')
h=gcf;
hx = plot(0,0,'LineWidth',1);
hold all
hy = plot(0,0,'LineWidth',1);
hold off

hGCA = get(gca);
hGCA.XLabel.String = 'Time (sec)';
hLegend = legend(bodyPart_x,bodyPart_y);
hLegend.Interpreter = 'none';


for i=1:size(behIdx,1)
    hx.YData = dfPose.(bodyPart_x)(behIdx(i,1):behIdx(i,2));
    hx.XData = 1:length(behIdx(i,1):behIdx(i,2));
    hy.YData = dfPose.(bodyPart_y)(behIdx(i,1):behIdx(i,2));
    hy.XData = 1:length(behIdx(i,1):behIdx(i,2));
    cticks = xticks;
    xticks(0:60:max(cticks));
    xticklabels(0:2:max(cticks)/30)
    tString = strcat(behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)));
    title(tString,'Interpreter','none')
    exportgraphics(gcf,fullfile(targetFolder,strcat(tString,'.pdf')),'Resolution',300,'ContentType','vector');
    saveas(gcf,fullfile(targetFolder,strcat(tString,'.svg')));
    savefig(gcf,fullfile(targetFolder,strcat(tString,'.fig')))
end



%plot all parts
for i=1:size(behIdx,1) %bodyPart_x

    clf
    figure(1)
    Plotter.initiatePlot(12,'w','Myriad Pro')
    h = plot(0,0);
    hold on
    hGCA = get(gca);
    hGCA.XLabel.String = 'Time (sec)';

    varNames = dfPose.Properties.VariableNames;
    match  = ["_x","_y"];
    cmap = createColorMap();
    for j=1:numel(varNames)-2
        h = plot(dfPose.(varNames{j})(behIdx(i,1):behIdx(i,2)),'LineWidth',1);
        hold on
        h.XData = 1:length(behIdx(i,1):behIdx(i,2));
        h.YData = dfPose.(varNames{j})(behIdx(i,1):behIdx(i,2));
        h.Color = cmap(string(erase(varNames(j),match)));
        cticks = xticks;
        xticks(0:60:max(cticks));
        xticklabels(0:2:max(cticks)/30)
        tString = strcat(behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)));
        title(tString,'Interpreter','none')
        tString=strcat(tString,'fullset');
        cbar = 0;
        %create the colorbar
        if cbar
            colormap(cmap);
            ch = colorbar;
            ch.Ticks = 0.0119:0.0238:1;
            ch.TickLabels = varNames;
            ch.TickLabelInterpreter = 'none';
            ch.FontName = 'Myriad Pro';
        end
    end

    exportgraphics(gcf,fullfile(targetFolder,strcat(tString,'.pdf')),'Resolution',300,'ContentType','vector');
    saveas(gcf,fullfile(targetFolder,strcat(tString,'.svg')));
    savefig(gcf,fullfile(targetFolder,strcat(tString,'.fig')))
end
end

function plotFeatures(behaviorT,tSnap,behaviorName,bodyPart,folderPath,feat)

behIdx = behaviorT{ismember(behaviorT.Behavior,behaviorName),2:3};

dist_feat = ['distance_',feat];

bodyPart_x = strcat('pose_',bodyPart,'_x');
bodyPart_y = strcat('pose_',bodyPart,'_y');

targetFolder = fullfile(folderPath,behaviorName);



if ~isfolder(targetFolder)
    mkdir(targetFolder)
end

clf
figure(1)
Plotter.initiatePlot(12,'w','Myriad Pro')
h=gcf;
hx = plot(0,0,'LineWidth',0.5);
hold all
hy = plot(0,0,'LineWidth',0.5);
hd = plot(0,0,'LineWidth',0.5);
hold off


hGCA = get(gca);
hGCA.XLabel.String = 'Time (sec)';
hLegend = legend(bodyPart_x,bodyPart_y,dist_feat);
hLegend.Interpreter = 'none';

axisFinder ()

for i=1:size(behIdx,1)
    hx.YData = subfirst(tSnap.(bodyPart_x)(behIdx(i,1):behIdx(i,2)));
    hx.XData = 1:length(behIdx(i,1):behIdx(i,2));
    hy.YData = subfirst(tSnap.(bodyPart_y)(behIdx(i,1):behIdx(i,2)));
    hy.XData = 1:length(behIdx(i,1):behIdx(i,2));
    hd.YData = subfirst(tSnap.(dist_feat)(behIdx(i,1):behIdx(i,2)));
    hd.XData = 1:length(behIdx(i,1):behIdx(i,2));
    xlim([0,5*30]);
    cticks = xticks;
    xticks(0:60:max(cticks));
    xticklabels(0:2:max(cticks)/30)
    yticks(-20:20:60)
    ylim([-15,15]);
    xlim;
    tString = strcat(behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)),'_feat');
    title(tString,'Interpreter','none')
    exportgraphics(gcf,fullfile(targetFolder,strcat(tString,'.pdf')),'Resolution',300,'ContentType','vector');
    %saveas(gcf,fullfile(targetFolder,strcat(tString,'.svg')));
    %savefig(gcf,fullfile(targetFolder,strcat(tString,'.fig')))
end


%plot all dist prob in a single plot
for i=1:size(behIdx,1)
    plot(subfirst(tSnap.(dist_feat)(behIdx(i,1):behIdx(i,2))),'k');
    hold all
    %xlim([0,24*30])
    cticks = xticks;
    xticks(0:60:max(cticks));
    xticklabels(0:2:max(cticks)/30)
    xlim([0,5*30]);
    cticks = xticks;
    xticks(0:60:max(cticks));
    xticklabels(0:2:max(cticks)/30)
    yticks(-10:10:10)
    ylim([-15,15]);
    %yticks(-20:20:60)
    %tString = strcat(behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)),'_feat');
    %title(tString,'Interpreter','none')

    %saveas(gcf,fullfile(targetFolder,strcat(tString,'.svg')));
    %savefig(gcf,fullfile(targetFolder,strcat(tString,'.fig')))
end
ylim([-30 45])
yticks(-20:20:40)
exportgraphics(gcf,fullfile(targetFolder,strcat('allOnOne','.pdf')),'Resolution',300,'ContentType','vector');

end


function plotImageswithBodyParts(moviePath,behaviorT,tSnap,behaviorName,bodyPart,folderPath,feat)

behIdx = behaviorT{ismember(behaviorT.Behavior,behaviorName),2:3};
%extract video frames and label with the targeted body parts
moviePath = 'Fly15_F_B_6d_8am-08182021173222.avi';
moviePath = fullfile(folderPath,moviePath);

dist_feat = ['distance_',feat];

clf
figure(1)
Plotter.initiatePlot(12,'w','Myriad Pro')
h=gcf;
hd = plot(0,0,'LineWidth',0.5);
hold off


hGCA = get(gca);
hGCA.XLabel.String = 'Time (sec)';
%hLegend = legend(bodyPart_x,bodyPart_y,dist_feat);
%hLegend.Interpreter = 'none';




for i = 2:size(behIdx,1)
    idxes = behIdx(i,1):behIdx(i,2);
    frames = AuxFunc.loadMovie(moviePath,[behIdx(i,1),behIdx(i,2)],30);
    [imt,rect] = imcrop(frames(:,:,1));

    for j = 1:10:numel(idxes)
        figure(1)
        clf
        subplot(211)
        cropIm = imcrop(frames(:,:,j),rect);
        image(cropIm)
        hold all
        axis equal
        axis off
        colormap gray

        coord_x = dfPose.halt_x(behIdx(i,1):behIdx(i,2)) - rect(1);
        coord_y = dfPose.halt_y(behIdx(i,1):behIdx(i,2)) - rect(2);

        coordHeadX = dfPose.thor_post_x(behIdx(i,1):behIdx(i,2)) - rect(1);
        coordHeadY = dfPose.thor_post_y(behIdx(i,1):behIdx(i,2)) - rect(2);

        scatter([coord_x(j) coordHeadX(j)],[coord_y(j) coordHeadY(j)],100,'filled','MarkerFaceAlpha',0.4);
        hold off

        hs = subplot(212);
        snapFeat = subfirst(tSnap.(dist_feat)(behIdx(i,1):behIdx(i,2)));
        box off
        plot(snapFeat,'k');
        hold all
        plot(j,snapFeat(j),'.r','MarkerSize',20)
        hold off
        Plotter.modSubPlot(hs,12,'w')
        tString = strcat('imgcomb_',behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)),'_feat','_frame_',num2str(j));
        title(tString,'Interpreter','none')
        exportgraphics(gcf,fullfile(targetFolder,strcat(tString,'.pdf')),'Resolution',300,'ContentType','vector');

    end
end
end












