imageFullFileName = '/Users/mehmetkeles/Documents/lab_meeting_prep_81922/Fly2/Substack (12001-18000).tif';

info = imfinfo(imageFullFileName);
numberOfPages = length(info);
allPages = [];
for k = 1 : numberOfPages
    % Read the kth image in this multipage tiff file.
    allPages(:,:,k) = imread(imageFullFileName, k);
    % Now process thisPage somehow...
end	
cropPages = allPages(:,:,1:3800);

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
hl = plot(zeros(size(cropPages,3),2));
hl(1).Color = tricolors(1,:);
hl(2).Color = tricolors(2,:);
hl(1).LineWidth = 1.5;
hl(2).LineWidth = 1.5;
hl(2).LineStyle = '-';
yyaxis right 
hr = plot(zeros(2001,1));
hr.LineStyle = '-';
hr.Color = [116/255,214/255,0];
h = gca;
h.XLim = [1 size(cropPages,3)-1];
yyaxis left
h.YLim = [min(all_rois(:,1:2),[],'all') max(all_rois(:,1:2),[],'all')];
h.YColor = tricolors(2,:);
h.YLabel.String = 'Leg Fluorescence (a.u.)';
yyaxis right
h.YLim = [min(all_rois(:,4),[],'all') max(all_rois(:,4),[],'all')];
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
h.LineWidth = 1.5;
h.YLim = [min(all_rois(:,3)) max(all_rois(:,3))];
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



%just plot
hl(1).YData = (all_rois(:,1) - mean(all_rois(883:908,1)))./mean(all_rois(883:908,1));
hl(2).YData = (all_rois(:,2) - mean(all_rois(883:908,2)))./mean(all_rois(883:908,2));
hl(3).YData = (all_rois(:,3) - mean(all_rois(883:908,3)))./mean(all_rois(883:908,3));
yyaxis left
h.YLim = [-0.05 1];
yyaxis right
hr.YData = (all_rois(:,4) - mean(all_rois(883:908,4)))./mean(all_rois(883:908,4));

