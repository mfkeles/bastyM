
function delta_y = calculate_delta(x,win_length_in_sec,fps)


win_length = ceil(win_length_in_sec*fps);

get_movmean = @(x) movmean(x, win_length);

y = varfun(get_movmean,x);

get_gradient = @(x) gradient(x,2);

delta_y = varfun(get_gradient,y);

end