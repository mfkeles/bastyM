function obj = getConfigFiles(obj,pathIN)

%TODO add path input

pathIN = '/Users/mehmetkeles/Desktop/git_projects/ethologger/config_templates/pose_cfg.yaml' ;

obj.pose_cfg = ReadYaml(pathIN);