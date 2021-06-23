%A small program to read .txt file containing acceleration data. 

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
    trials(i).data = dat_line(idx(i)+1:idx(end));
    trials(i).power = str2double(cell2mat(regexp(dat_line{idx(i)},'\d*','Match')));
    end
end

%turn strings to doubles, and create an array for x,y,z values
vals=[];
for i =1:numel(trials)
    clear heads vals
    vals=[];
    n=1;
    proc_trials = cellfun(@(x) strsplit(x,','), trials(1).data, 'UniformOutput', false);
    for j=1:2:11
        heads(n) = unique(cellfun(@(x) x{j}, proc_trials, 'UniformOutput', false));
        vals(:,n)= cellfun(@str2double,(cellfun(@(x) x{j+1}, proc_trials, 'UniformOutput', false)));
        n = n+1;
    end
    heads = [{'Motor'} heads];
    mpower = trials(i).power;
    mpower = ones(size(vals,1),1)*mpower;
    vals = [mpower vals];
    if ~exist('T')
       T = array2table(vals,'VariableNames',heads);
    else
       nT =  array2table(vals,'VariableNames',heads);
       T = [T;nT];
    end
end

%T is the final table

mapxmat(x, in_min, in_max, out_min, out_max):
    return int((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)






