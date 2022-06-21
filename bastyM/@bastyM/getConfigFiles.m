function getConfigFiles(obj,varargin)

if nargin < 2
    if ismac
    pathIN = '/Users/mehmetkeles/Desktop/git_projects/ethologger/examples/configuration_examples';
    else
    pathIN = 'C:\Users\Mehmet Keles\Desktop\git_dir\DLC-FlySleep\bastyM\configuration_examples';
    end
else
    pathIN = varargin{1};
end

%TODO add path input

%pathIN = '/Users/mehmetkeles/Desktop/git_projects/ethologger/config_templates' ;

%yamlList = dir(fullfile(pathIN,'*.yaml'));

pose = fullfile(pathIN,'pose_cfg.yaml');
feature = fullfile(pathIN,'feature_cfg.yaml');

obj.pose_cfg = ReadYaml(pose);
obj.feature_cfg = ReadYaml(feature);