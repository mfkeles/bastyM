function intvls = cont_intvls(labels)
intvls = [1; (find(diff(labels))+1);size(labels,1)];
end
