% A function to calculate vector sum of accelerations. Data from ADXL337 is
% used. 
function output = vectcalc(x,y,z)
output = sqrt(x.^2 + y.^2 + z.^2);
end