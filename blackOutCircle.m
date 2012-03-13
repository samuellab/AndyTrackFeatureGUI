
function out=blackOutCircle(x_p,y_p,im,r)
%function out=blackOutCircle(x_p,y_p,im,r)

%Takes an image and blacks out a circle of radius r at location x_p and
%y_p.

[x, y] = meshgrid(1:size(im,2), 1:size(im,1));

circles = zeros(size(im));

circles = circles + (floor((x - x_p).^2 + (y - y_p).^2) <= r);


% normalize circles
circles = not(  logical(circles/max(max(circles))) );

out = double(im).* circles;