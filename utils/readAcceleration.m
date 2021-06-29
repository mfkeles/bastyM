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

for i=1:numel(tested)
    
    vectsum(i) = sumabs(diff(vectcalc(T.X1(T.Motor==tested(i)),T.Y1(T.Motor==tested(i)),T.Z1(T.Motor==tested(i)))));
    %first 300 ms is the 
end
clf
for i=1:numel(tested)
    subplot(211) %platform A
    vectsum = vectcalc(T.X1(T.Motor==tested(i)),T.Y1(T.Motor==tested(i)),T.Z1(T.Motor==tested(i))) ;
    plot(T.X1(T.Motor==tested(i)))
    hold all
    plot(T.Y1(T.Motor==tested(i)))
    plot(T.Z1(T.Motor==tested(i)))
    make_it_black
    subplot(212)
    plot(T.X2(T.Motor==tested(i)))
    hold all
    plot(T.Y2(T.Motor==tested(i)))
    plot(T.Z2(T.Motor==tested(i)))
    make_it_black;
    pause
    clf
end


sum(abs(diff(vectcalc(T.X1(T.Motor==tested(i)),T.Y1(T.Motor==tested(i)),T.Z1(T.Motor==tested(i))))));






