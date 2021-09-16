function name = get_feature_name(definition)
                if isstruct(definition)
                    fname = fieldnames(definition);
                    name = cell2mat(strcat(fieldnames(definition),'(',strjoin(cellfun(@(x) strjoin(x,'-'),definition.(fname{1}),'UniformOutput',false), ','), ')' ));
                else
                    if ~iscellstr(definition)
                        name = strjoin(cellstr(definition),'-');
                    else
                        name = strjoin(definition,'-');
                    end
                end
            end