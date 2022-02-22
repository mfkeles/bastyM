%Quick DLC movie plot to generate

vid_file = 'Z:\mfk\DeepLabCut_Videos\MK_Deprive\New_Batch\Good RB\20211105_Fly19_F_A_SD_5D_8am\20211105_Fly19_F_A_SD_5D_8am-11052021164243.avi';

vidObj = VideoReader(vid_file);



idx_start = 1599146;
idx_stop = (idx_start+30*20);

target_frames = read(vidObj,[idx_start idx_stop]);

subDf = dfPose(idx_start:idx_stop,:); 



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