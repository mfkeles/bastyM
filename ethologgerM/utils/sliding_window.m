function ret = sliding_window(seq,n,s)
n= fix(n/2);

for i=1:s:n
    p1(i) = {seq(1:i+(n-1))};
end
%crude code below...
z=1;
sub=1;
for i=n:s:numel(seq)-1
    
    try
        p2(z) = {seq(1+i-n:i+n)};
        
    catch
        p2(z) = {seq(1+i-n:i+n-sub)};
        sub=sub+1;
    end
    z=z+1;
    
end
ret = [p1 p2];
end


