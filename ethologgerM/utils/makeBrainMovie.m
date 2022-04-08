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
 t = tiledlayout(3,4);
ax = nexttile([2,4]);
colormap gray
h_img = imshow(M2(:,:,1));
axis off
caxis([0 500])

tricolors = [255/255,186/255,186/255];
nexttile([1,4])
hold on
hl = plot(zeros(50,1));
hl(1).Color = tricolors;
hl(1).LineWidth = 1.5; 
h = gca;
h.XLim = [-50 50];
h.YLim = [min(all_rois(:,1),[],'all') max(all_rois(:,1),[],'all')];
h.YLabel.String = 'Head Fluorescence (a.u.)';
h.TickDir = 'out';
h.XColor = 'w';
h.YColor = 'w';
h.Color = 'k';
h.ZColor = 'w';
hl.LineWidth=1.5;
set(gcf,'color','k')
box off
hold off


v=VideoWriter('test4.mp4','MPEG-4');
v.Quality = 100;
open(v);
n=1;
for i=50:size(all_rois,1)
    h_img.CData = M2(:,:,n);

    hl.YData = all_rois(n:i,1);
    hl.XData = n:i;
    h.XLim = [n-50 n+50];
    %frame = getframe(gcf);
    %writeVideo(v,frame);
    n=n+1;
    pause
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

