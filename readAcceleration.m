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










