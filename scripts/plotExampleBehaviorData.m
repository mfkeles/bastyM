%use human annotated data to extract the representative traces for
%described behaviors

folderPath = 'Y:\MK_Migrated\MK_SET4\20210818_Fly15_F_B_6d_8am';

filePath = dir(fullfile(folderPath,'*200000.csv'));

obj = bastyM(fullfile(filePath.folder,filePath.name));

obj.getOrientedPose;

dfPose = obj.runFilter(10,23);

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

    cmap = brewermap(42,'Spectral');
    for j=1:numel(varNames)-2
        h = plot(dfPose.(varNames{j})(behIdx(i,1):behIdx(i,2)),'LineWidth',1);
        hold on
        h.XData = 1:length(behIdx(i,1):behIdx(i,2));
        h.YData = dfPose.(varNames{j})(behIdx(i,1):behIdx(i,2));
        h.Color = cmap(j,:);
        cticks = xticks;
        xticks(0:60:max(cticks));
        xticklabels(0:2:max(cticks)/30)
        tString = strcat(behaviorName,'_',num2str(behIdx(i,1)),'-',num2str(behIdx(i,2)));
        title(tString,'Interpreter','none')
        tString=strcat(tString,'fullset');
        cbar = 1;
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



