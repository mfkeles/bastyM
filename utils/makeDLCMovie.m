%Quick DLC movie plot to generate

vid_file = 'X:\MK_Migrated\MK_SET\Annotated\20200308_Fly1_F_30FPS_LiquidFood\muscle_relaxtionwhaltere_from_735424_to_782000_reencoded_new.avi';

vidObj = VideoReader(vid_file);

snapPath = 'X:\MK_Migrated\MK_SET\Annotated\20200308_Fly1_F_30FPS_LiquidFood\FlyF1-03082020164520-snap_stft.csv';

%read snapFEATURES
snapArr = AuxFunc.importSnapFeatures(snapPath);






idx_start = 735424+210;
idx_stop = 782000+210;

target_frames = read(vidObj,[1 2]);

subDf = dfPose(idx_start:idx_stop,:);

subSnap = snapArr(idx_start:idx_stop,:);

v = VideoWriter('C:\Users\Mehmet Keles\Desktop\DLCout9.avi','Motion JPEG AVI');
v.Quality = 100;
open(v);
figure(1)
h_img = image(target_frames(:,:,:,1));
axis image off
colormap gray
hold on
h_data = scatter(zeros(1,21),zeros(1,21),15,jet(21),'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold off;
n=1;
for i=idx_start:idx_stop
    h_img.CData = target_frames(:,:,:,n);
    h_data.XData = subDf{n,1:2:42};
    h_data.YData = subDf{n,2:2:42};
    n=n+1;
    drawnow;
    frame = getframe(gca);
    writeVideo(v,frame);
end
close(v)


h.Ticks = (1/21-(1/42)):1/21:(1-1/42);



%read frames one by one and make a figure out of it
%4 and 5 is halt x and y
clf
halt_x = subSnap(:,3) - rect(1);
halt_y = subSnap(:,4) - rect(2);
thor_x = subSnap(:,5) - rect(1);
thor_y = subSnap(:,6) - rect(2);
thor_post_halt = AuxFunc.subtractFirst(subSnap(:,11));
thor_origin = AuxFunc.subtractFirst(subSnap(:,9));
halt_origin = AuxFunc.subtractFirst(subSnap(:,7));

vidObj.CurrentTime = 0;
h_img = readFrame(vidObj);
crop_img = imcrop(h_img,rect);
subplot(1,4,1:3);
h_img = imshow(crop_img);
hold on
h_data = scatter([halt_x(1),thor_x(1)],[halt_y(1),thor_y(1)],15,jet(2),'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
pline = line([halt_x(1),thor_x(1)],[halt_y(1),thor_y(1)]);
hold off
h = subplot(1,4,4);
hl = plot(zeros(length(1:5000),2));
box off
h.YLim =[ min([thor_origin,halt_origin],[],'all'), max([thor_origin,halt_origin],[],'all')];
h.XLim = [1 5000];
n=1;
vidObj.CurrentTime = 0;
while n<5000

    h_img.CData = imcrop(readFrame(vidObj),rect);
    hl(1).YData = thor_origin(1:n,1);
    hl(2).YData = halt_origin(1:n,1);
    h_data.XData = [halt_x(n),thor_x(n)];
    h_data.YData = [halt_y(n),thor_y(n)];
    pline.XData = [halt_x(n),thor_x(n)];
    pline.YData = [halt_y(n),thor_y(n)];
    n=n+1;
end











