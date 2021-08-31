function [dateCreated,dateModified] = getfileinfo(filename)
% This function search for the numbre of files written or created on 
% specific date and plot a bargraph. The filename is a string variable as
% below.
% filename = 'S:\Support Operations\Support Data\SRS MapCHECK';
% Then, type in Matlab command prompt as below
% >> getfileinfo('S:\SO\Support Data\Product1')
% This function is not idiot proof - Erros can occur if used outside of
% scope.

%This function was modified from 
%https://www.mathworks.com/matlabcentral/answers/100248-is-it-possible-to-obtain-the-creation-date-of-a-directory-or-file-in-matlab-7-5-r2007b
%
tic
% DOS string for "FILE WRITTEN" data indicating /tw. 
% For 'File Creation Date', use /tc
dosStr = char(strcat({'dir /s /tc '}, {'"'}, filename,{'"'}));
% Reading DOS results
[~,results] = dos(dosStr);
c = textscan(results,'%s');
% Extract file size (fileSize) and date created (dateCreated)
i = 1;
for k = 1:length(c{1})
    if (isequal(c{1}{k},'PM')||isequal(c{1}{k},'AM'))&&(~isequal(c{1}{k+1},'<DIR>'))
        dateCreated(i,1) = datetime(cell2mat(strcat(c{1}{k-2},{' '},c{1}{k-1},{' '},c{1}{k})),'InputFormat','MM/dd/uuuu hh:mm aa');
        n = length(str2num(c{1}{k+1}));
        fileSize(i,1) = sum(fliplr(str2num(c{1}{k+1})).*(10.^(3.*((0:n-1)))));
        i = i + 1;
    end
end
dosStr = char(strcat({'dir /s /tw '}, {'"'}, filename,{'"'}));
[~,results] = dos(dosStr);
c = textscan(results,'%s');
% Extract file size (fileSize) and date created (dateCreated)
i = 1;
for k = 1:length(c{1})
    if (isequal(c{1}{k},'PM')||isequal(c{1}{k},'AM'))&&(~isequal(c{1}{k+1},'<DIR>'))
        dateModified(i,1) = datetime(cell2mat(strcat(c{1}{k-2},{' '},c{1}{k-1},{' '},c{1}{k})),'InputFormat','MM/dd/uuuu hh:mm aa');
        n = length(str2num(c{1}{k+1}));
        fileSize(i,1) = sum(fliplr(str2num(c{1}{k+1})).*(10.^(3.*((0:n-1)))));
        i = i + 1;
    end
end



end