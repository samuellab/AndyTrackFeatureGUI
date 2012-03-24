
function [x, y, blurred]= findBrightest(I,radiusExclusion,radiusSmooth,N)
%Find the N brightest regions in an image
%radiusExclusion specifices the size of the region to exclude after a
%bright point has been found. 
%radiusSmooth specifices the radius for smoothing purpuoses.

Iorig=I;    
    
h = fspecial('gaussian',2.*[radiusSmooth radiusSmooth], radiusSmooth^.5);

for k=1:N
    blurred=imfilter(I,h,'replicate'); 
    max_v = max(max(blurred));
    
    
    % find the position of pixels having this value.
    [tempr, tempc] = find(blurred == max_v);
    %If two pixels have the same intensity, only take the first one
    y(k)=tempr(1);
    x(k)=tempc(1);
    
    
    %Black out a region aroudn the brightest point
    I=blackOutCircle(x(k),y(k),I,radiusExclusion);
end


blurred=imfilter(Iorig,h,'replicate');





