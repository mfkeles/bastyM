function obj = getDateTime(obj)

%find the date and the time for associated file over time, couple different
%naming conventions used. Hopefully this encapsulates all. 
    flyExpr = '(?<=Fly)[0-9]{1,3}';
    obj.Fly = cell2mat(regexpi(obj.File,flyExpr,'match'));
    [obj.Created,obj.Modified] = getfileinfo(obj.Path);
    [y,m,d] = ymd(obj.Created);
    obj.DateInt = [y,m,d];
    [h,m,s] = hms(obj.Created);
    obj.TimeInt = [h,m,s];
end