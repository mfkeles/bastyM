function getSensorData(obj)
%GETSENSORDATA Loads the .log file collected during experiments containing
%time, humidity, light and accelerometer data.


%Incomplete code. Load manully for now


% Prompt user for input
qstring = 'Could not find sensor file automatically.';
title = 'Browse for sensor file?';
str1 = 'Open file browser';
str2 = 'Continue without sensor file';
default = str2;
button = questdlg(qstring,title,str1,str2,default);

if strcmp(button, str2)
    disp('Continue without sensor file.')
    obj.Sensor = [];
    return
end



% Open a file browser for manual selection of DAQ file
try
    [FileName] = uigetfile('*.log;*.txt',['Select the sensor file for ' obj.DateInt ' at ' obj.TimeInt],obj.Folder);
    obj.DaqFile = FileName;
    

catch % Avoids an error when file browser is closed before selecting a file
    obj.Sensor = [];
    return
end
