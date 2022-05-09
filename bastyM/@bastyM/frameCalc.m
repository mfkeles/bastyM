%frame calculator

fps=30;

t='14:03:10';
seconds=sum(sscanf(t,'%f:%f:%f').*[3600;60;1]);
frame = fps*seconds;
frame