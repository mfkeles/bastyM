function hour = frame_to_hour(frames,fps)
x = seconds(frames/fps);

x.Format = 'hh:mm:ss';

hour  = x;