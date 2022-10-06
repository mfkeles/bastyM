imageFullFileName = '/Users/mehmetkeles/Documents/lab_meeting_prep_81922/Fly2/Substack (12001-18000).tif';


[path,file,ext] = fileparts(imageFullFileName);
info = imfinfo(imageFullFileName);
numberOfPages = length(info);
allPages = [];
for k = 1 : numberOfPages
    % Read the kth image in this multipage tiff file.
    allPages(:,:,k) = imread(imageFullFileName, k);
    % Now process thisPage somehow...
end	
cropPages = allPages(:,:,1:2400);

 numOfRois = 4;

 for i=1:numOfRois
 rois(i) = drawpolygon('LineWidth',5,'Color','cyan');
 end


for i=1:numel(rois)
    tmp_mask = createMask(rois(i));
    tmp_arr = arrayfun(@(x) sum(cropPages(:,:,x).*tmp_mask,'all'),1:size(cropPages,3));
    all_rois(:,i) = tmp_arr;
end

clf
 t = tiledlayout(12,3);
ax = nexttile([8,3]);
colormap gray
h_img = imshow(cropPages(:,:,1));
axis off
caxis([0 1000])

blue = [0,68,136]/255;
red =  [187,85,102]/255;
yellow = [221,170,51]/255;
col = [blue;yellow;red];


tricolors(1,:) = [255/255,186/255,186/255];
tricolors(2,:) = [255/255,123/255,123/255];
tricolors(3,:) = [255/255,82/255,82/255];
tricolors(4,:) = [221,170,51]/255;

nexttile([2,3])
hold on
yyaxis left
hl = plot(zeros(size(cropPages,3),3));
hl(1).Color = tricolors(1,:);
hl(2).Color = tricolors(2,:);
hl(3).Color = tricolors(3,:);
hl(1).LineWidth = 1.5;
hl(2).LineWidth = 1.5;
hl(3).LineWidth = 1.5;
hl(2).LineStyle = '-';
hl(1).LineStyle = '-';
hl(3).LineStyle = '-';
yyaxis right 
hr = plot(zeros(2001,1));
hr.LineStyle = '-';
hr.Color = [116/255,214/255,0];
h = gca;
h.XLim = [1 size(cropPages,3)-1];
yyaxis left
h.YLim = [min(all_rois(:,1:3),[],'all') max(all_rois(:,1:3),[],'all')];
h.YColor = tricolors(2,:);
h.YLabel.String = 'Leg Fluorescence (a.u.)';
yyaxis right
h.YLim = [min(all_rois(:,5),[],'all') max(all_rois(:,5),[],'all')];
h.YColor = [116/255,214/255,0];
h.YLabel.String = 'Prob. Fluorescence (a.u.)';
h.TickDir = 'out';
h.XColor = 'w';
h.Color = 'k';
h.ZColor = 'w';
hr.LineWidth=1.5;
set(gcf,'color','k')
h.XTick = [0:300:size(cropPages,3)-1];
h.XTickLabel = [0:1:numel(h.XTick)];
h.XLabel.String = 'Time (min)';
box off
hold off


nexttile([2,3])
hold on
ht = plot(zeros(size(cropPages,3),1));
ht.Color = tricolors(4,:);
h=gca;
ht.LineWidth = 1.5;
h.YLim = [min(all_rois(:,4)) max(all_rois(:,4))];
h.YColor = tricolors(4,:);
h.YLabel.String = 'Thorax Fluorescence (a.u.)';
h.TickDir = 'out';
h.XColor = 'w';
h.Color = 'k';
h.ZColor = 'w';
h.XTick = [0:300:size(cropPages,3)-1];
h.XTickLabel = [0:1:numel(h.XTick)];
h.XLabel.String = 'Time (min)';
h.XLim = [1 size(cropPages,3)-1];
h.XTick = [0:300:size(cropPages,3)-1];
h.XTickLabel = [0:1:numel(h.XTick)];



v=VideoWriter(fullfile(path,'outMPEG.avi'),'MPEG-4');
v.Quality = 100;
open(v);

for i=1:size(all_rois,1)
    h_img.CData = cropPages(:,:,i);
    for j=1:numel(hl)
        hl(j).YData = all_rois(1:i,j);
        hl(j).XData = 1:i;
    end
    hr.YData = all_rois(1:i,5);
    hr.XData = 1:i;
    ht.YData = all_rois(1:i,4);
    ht.XData = 1:i;
    frame = getframe(gcf);
    writeVideo(v,frame);
end

close(v)


%just plot
hl(1).YData = (all_rois(:,1) - mean(all_rois(883:908,1)))./mean(all_rois(883:908,1));
hl(2).YData = (all_rois(:,2) - mean(all_rois(883:908,2)))./mean(all_rois(883:908,2));
hl(3).YData = (all_rois(:,3) - mean(all_rois(883:908,3)))./mean(all_rois(883:908,3));
yyaxis left
h.YLim = [-0.05 1];
yyaxis right
hr.YData = (all_rois(:,4) - mean(all_rois(883:908,4)))./mean(all_rois(883:908,4));



clf
h=subplot(211)
endTime = 300;
plot(all_rois(1:endTime,1))
hold all
plot(all_rois(1:endTime,2))
plot(all_rois(1:endTime,3))
Plotter.modSubPlot(h,8,'w')
xticks(0:50:300)
xticklabels(0:10:60)
xlabel('Time (sec)')
box off
h = subplot(212)
plot(all_rois(1:endTime,4),'Color',tricolors(4,:));
Plotter.modSubPlot(h,8,'w')
box off
xlabel('Time (sec)')
xticks(0:50:300)
xticklabels(0:10:60)
h = subplot(414);
plot(all_rois(1:endTime,5));
Plotter.modSubPlot(h,8,'w')

