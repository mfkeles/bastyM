imageFullFileName = 'Substack (4000-6000).tif';

info = imfinfo(imageFullFileName);
numberOfPages = length(info);
allPages = [];
for k = 1 : numberOfPages
    % Read the kth image in this multipage tiff file.
    allPages(:,:,k) = imread(imageFullFileName, k);
    % Now process thisPage somehow...
end	
cropPages = allPages(100:500,25:680,:);

 t = tiledlayout(6,3);
 p = drawpolygon('LineWidth',5,'Color','cyan');

rois = [p p2 p3 p4];

for i=1:numel(rois)
    tmp_mask = createMask(rois(i));
    tmp_arr = arrayfun(@(x) sum(cropPages(:,:,x).*tmp_mask,'all'),1:size(cropPages,3));
    all_rois(:,i) = tmp_arr;
end

clf
 t = tiledlayout(6,3);
ax = nexttile([4,3]);
colormap gray
h_img = imshow(cropPages(:,:,1));
axis off
caxis([0 1000])

tricolors(1,:) = [255/255,186/255,186/255];
tricolors(2,:) = [255/255,123/255,123/255];
tricolors(3,:) = [255/255,82/255,82/255];
nexttile([2,3])
hold on
yyaxis left
hl = plot(zeros(2001,3));
hl(1).Color = tricolors(1,:);
hl(2).Color = tricolors(2,:);
hl(3).Color = tricolors(3,:);
hl(1).LineWidth = 1.5;
hl(2).LineWidth = 1.5;
hl(3).LineWidth = 1.5;
hl(2).LineStyle = '-';
hl(3).LineStyle = '-';
yyaxis right 
hr = plot(zeros(2001,1));
hr.LineStyle = '-';
hr.Color = [116/255,214/255,0];
h = gca;
h.XLim = [1 2001];
yyaxis left
h.YLim = [256000 500000];
h.YColor = tricolors(2,:);
h.YLabel.String = 'Leg Fluorescence (a.u.)';
yyaxis right
h.YLim = [300000 4600000];
h.YColor = [116/255,214/255,0];
h.YLabel.String = 'Prob. Fluorescence (a.u.)';
h.TickDir = 'out';
h.XColor = 'w';
h.Color = 'k';
h.ZColor = 'w';
hr.LineWidth=1.5;
set(gcf,'color','k')
h.XTick = [0:300:2000];
h.XTickLabel = {'0', '1','2','3','4','5','6'};
h.XLabel.String = 'Time (min)';
box off
hold off


v=VideoWriter('test4.mp4','MPEG-4');
v.Quality = 100;
open(v);

for i=1:size(all_rois,1)
    h_img.CData = cropPages(:,:,i);
    for j=1:numel(hl)
        hl(j).YData = all_rois(1:i,j);
        hl(j).XData = 1:i;
    end
    hr.YData = all_rois(1:i,4);
    hr.XData = 1:i;
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
















