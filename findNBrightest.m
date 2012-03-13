
function [x, y, blurred]= findBrightest(I,radius,N)
%Find the N brightest regions in an image

Iorig=I;    
    
r=radius;
h = fspecial('gaussian',2.*[r r], r^.5);

for k=1:N
    blurred=imfilter(I,h,'replicate'); 
    max_v = max(max(blurred));
    
    
    % find the position of pixels having this value.
    [tempr, tempc] = find(blurred == max_v);
    %If two pixels have the same intensity, only take the first one
    y(k)=tempr(1);
    x(k)=tempc(1);
    
    
    %Black out a region aroudn the brightest point
    I=blackOutCircle(x(k),y(k),I,r+1);
end


blurred=imfilter(Iorig,h,'replicate');





