function [cfg] = read_config(pathIN)

yaml_files = dir(fullfile(pathIN,"*.yaml"));

for i=1:numel(yaml_files)
    [ ~,name,~] = fileparts(yaml_files(i).name);
    cfg.(name) = ReadYaml(fullfile(yaml_files(i).folder,yaml_files(i).name));
end

    

