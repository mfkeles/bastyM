%[file ,path] = uigetfile;
%fullpath = fullfile(path,file);
moviepath = "/Users/mehmetkeles/Desktop/MK/Work/Wu Lab/Fly Movies/winnie_spedup.mp4";

v = VideoReader(moviepath);
%speed up the process by loading up the data scaling it and saving it as
%small filtered.
data = zeros(v.Height,v.Width,v.NumFrames);

tic
n=1;
v.CurrentTime = 0;

while hasFrame(v)
   data(:,:,n) = rgb2gray(readFrame(v));
    n=n+1;
end

toc

 numOfRois = 3;

 for i=1:numOfRois
 rois(i) = drawpolygon('LineWidth',5,'Color','cyan');
 end




for i=1:numel(rois)
    tmp_mask = createMask(rois(i));
    tmp_arr = arrayfun(@(x) sum(data(:,:,x).*tmp_mask,'all'),1:size(data,3));
    all_rois(:,i) = tmp_arr;
end


%%
%use the values to plot
dirpaths = dir(fullfile(newfolder_motion,'*.mat'));

%load and combine all
tot_vals = [];
for i =1:length(dirpaths)
    load(fullfile(dirpaths(i).folder,dirpaths(i).name))
    vals(end-1) = vals(end);
    if i==1
        tot_vals = vals;
    else
        tot_vals = [tot_vals vals];
    end
end

dep_start = 226912;
dep_end = 1526860;

%find dep peaks and remove
sub_vals = tot_vals(dep_start:dep_end);
[pks,locs] =  findpeaks(tot_vals,'MinPeakHeight',12000,'MinPeakDistance',1200);
nlocs = locs;
nlocs(locs>dep_end) = [];
nlocs(locs<dep_start) = [];

expected_peaks = length(nlocs)*2;
%try
for i=1:length(nlocs)
    tmp_peak = tot_vals(nlocs(i)-100:nlocs(i)+100);
    [ipt,residual] =findchangepts(movstd(cumsum(tmp_peak),5),'MaxNumChanges',2);
    ipt =nlocs(i) - 100 + ipt;
    if i ==1
        tipt = ipt;
    else
        tipt = [tipt ;ipt];
    end
end

tipt>2000
%catch
disp('alternative method,assumes the first one was correct')

tipt(1,1) = tipt(1,1)-4;
tipt(


%tipt (1) is 7pm go back two hours.
tipt(:,1) = tipt(:,1)-4;
tipt(:,2) = tipt(:,2)+4;
nan_vals= tot_vals;
for i=1:size(tipt,1)
    nan_vals(tipt(i,1):tipt(i,2)) = 0;
end


begin_ind = tipt(1,1)-1*60*60*30;

%ZT10
bin_vals = [];
clean_vals = tot_vals(begin_ind:end);
clean_vals = nan_vals(begin_ind:end);
shuffle_array = 1:30*60:floor(size(clean_vals,2)/(30*60))*30*60;
for i=1:length(shuffle_array)-1
    bin_vals(i) = sum(clean_vals(shuffle_array(i):shuffle_array(i+1)-1));
end
%plot bin_vals most of this could've been done with movsum.
[b a] = butter(2,0.5);
plot(filtfilt(b,a,bin_vals),'LineWidth',1.5)
xticks(60:120:floor(length(bin_vals)/60)*60)
for i=1:length(xticks)
    x_label{i} = ['ZT' num2str(rem((10+i*2),24))];
end
xticklabels(x_label)
yticks([])
grid on
ax = gca;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.5;
xlim([0 length(bin_vals)])
set(gca, 'FontName','Verdana')
make_it_black

exportgraphics(gcf,fullfile(newfolder_motion,'motion_trace.pdf'),'Resolution',150,'ContentType','vector','BackgroundColor','black');




