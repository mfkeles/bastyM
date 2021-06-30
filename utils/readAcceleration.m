%A small program to read .txt file containing acceleration data.
clear
%get the desired file
[file,path] = uigetfile;

%open the file
fileID = fopen(fullfile(path,file),'r');

%will read each line as a string then process
formatSpec = '%s';

%rewind the position in case. prob not necessary
frewind(fileID);

%read all lines and save it in a cell array
n=1;
while ~feof(fileID)
    dat_line{n} = fgetl(fileID);
    n=n+1;
end

%remove the empty lines
dat_line = dat_line(~cellfun('isempty',dat_line));

%find where each trial starts "Motor Started..." is the key phrase
idx = find(contains(dat_line,'Motor Started'));

%remove the last line
dat_line(end)=[];

%split trials
for i=1:numel(idx)
    if idx(end) ~= idx(i)
        trials(i).data = dat_line(idx(i)+1:idx(i+1)-1);
        trials(i).power = str2double(cell2mat(regexp(dat_line{idx(i)},'\d*','Match')));
    else
        trials(i).data = dat_line(idx(i)+1:end);
        trials(i).power = str2double(cell2mat(regexp(dat_line{idx(i)},'\d*','Match')));
    end
end

%turn strings to doubles, and create an array for x,y,z values
vals=[];
for i =1:numel(trials)
    clear heads vals time
    vals=[];
    n=1;
    proc_trials = cellfun(@(x) strsplit(x,','), trials(i).data, 'UniformOutput', false);
    for j=1:2:11
        heads(n) = unique(cellfun(@(x) x{j}, proc_trials, 'UniformOutput', false));
        vals(:,n)= cellfun(@str2double,(cellfun(@(x) x{j+1}, proc_trials, 'UniformOutput', false)));
        n = n+1;
    end
    heads = [{'Motor'} heads {'Time'}];
    mpower = trials(i).power;
    mpower = ones(size(vals,1),1)*mpower;
    vals = [mpower vals];
    time = cellfun(@str2double,(cellfun(@(x) x{13}, proc_trials, 'UniformOutput', false)));
    vals = [vals time'];
    if ~exist('T')
        T = array2table(vals,'VariableNames',heads);
    else
        nT =  array2table(vals,'VariableNames',heads);
        T = [T;nT];
    end
end

%T is the final table, convert from V readings to -G/G values don't grab
%time here
newT= mapfun(table2array(T(:,2:end-1)),0,1023,-3000,3000);
%take moving avg
T{:,2:end-1} = movmean(newT,10,1);
%downsample
nT = downsample(T{:,:},10);
nT = array2table(nT,'VariableNames',heads);
T= nT;

%Plotting
tested = unique(T.Motor);

%plot without any mods
clf
y = [-3000 ,-3000,3000,3000];



clf
for i=1:numel(tested)
    tloc = [];
    subplot(211) %platform A
    pT = T(T.Motor==tested(i),:);
    for j=100:100:500
        tloc(end+1) = find(pT.Time==j & pT.Motor==tested(i),1);
    end
    vectsum = vectcalc(T.X1(T.Motor==tested(i)),T.Y1(T.Motor==tested(i)),T.Z1(T.Motor==tested(i))) ;
    endloc = find(pT.Time==300 & pT.Motor==tested(i),1);
    x=[0,endloc,endloc,0];
    plot(T.X1(T.Motor==tested(i)),'LineWidth',1)
    hold all
    plot(T.Y1(T.Motor==tested(i)),'LineWidth',1)
    plot(T.Z1(T.Motor==tested(i)),'LineWidth',1)
    ylabel('Acceleration (G)')
    patch(x,y,'white','FaceAlpha',.15,'EdgeColor','none')
    l = legend([{'X'} {'Y'} {'Z'}]);
    l.TextColor = 'white';
    l.Color = 'black';
    title(['\color{white}Platform A \newlinePWM out: ' num2str(tested(i))])
    box off
    make_it_black
    ylim([-3000 3000]);
    yticklabels(cellfun(@num2str,num2cell(-3:1:3),'un',0));
    xticks(tloc);
    xticklabels(cellfun(@num2str,num2cell(100:100:500),'un',0));
    xlabel('Time (ms)');
    subplot(212)
    plot(T.X2(T.Motor==tested(i)),'LineWidth',1)
    hold all
    plot(T.Y2(T.Motor==tested(i)),'LineWidth',1)
    plot(T.Z2(T.Motor==tested(i)),'LineWidth',1)
    ylim([-3000 3000]);
    yticklabels(cellfun(@num2str,num2cell(-3:1:3),'un',0));
    patch(x,y,'white','FaceAlpha',.15,'EdgeColor','none')
    ylabel('Acceleration (G)')
    box off
    title('\color{white}Platform B')
       xticks(tloc);
    xticklabels(cellfun(@num2str,num2cell(100:100:500),'un',0));
    make_it_black;
     xlabel('Time (ms)');
    exportgraphics(gcf,['vibrate_at_' num2str(tested(i)) '.pdf'],'Resolution',300,'ContentType','vector','BackgroundColor','k');
    clf
end

for i=1:numel(tested)
    %Platform A
    plot(
    vectsum(i) = sumabs(diff(vectcalc(T.X1(T.Motor==tested(i)),T.Y1(T.Motor==tested(i)),T.Z1(T.Motor==tested(i)))));
    %Platform B
    
end




