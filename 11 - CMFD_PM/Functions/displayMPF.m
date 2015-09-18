function [vh,h] = displayMPF(img,mpf_x,mpf_y,bsize,mask)
% display the offsets field
% displayMPF(img,mpf_x,mpf_y,bsize[,mask])
%   img     the image;
%   mpf_x   column indexes;
%   mpf_y   row indexes;
%   bsize   sampling;
%   mask    selective mask, with same dimensions of mpf_x
%

[rowImg, colImg, K] = size(img);
[rowMpf, colMpf]    = size(mpf_x);
rowBlock = rowImg-rowMpf+1;
colBlock = colImg-colMpf+1;



[xp, yp] = meshgrid(0:(colMpf-1),0:(rowMpf-1));
mvf_x = mpf_x-xp;
mvf_y = mpf_y-yp;
xp = xp + ceil((colBlock+1)/2);
yp = yp + ceil((rowBlock+1)/2);

% Takes a vector for block
mvf_x = mvf_x(1:bsize(1):rowMpf,1:bsize(2):colMpf);
mvf_y = mvf_y(1:bsize(1):rowMpf,1:bsize(2):colMpf);
xp = xp(1:bsize(1):rowMpf,1:bsize(2):colMpf);
yp = yp(1:bsize(1):rowMpf,1:bsize(2):colMpf);

if  exist('mask','var') && not(isempty(mask)),
    mask = mask(1:bsize(1):rowMpf,1:bsize(2):colMpf);
    xp = xp(mask);
    yp = yp(mask);
    mvf_x = mvf_x(mask);
    mvf_y = mvf_y(mask);
end;

% show figure
h = imshow(img,'Parent',gca()); hold on;
vh = quiver(xp,yp,mvf_x,mvf_y, 0,'r');
set(vh, 'Linewidth', 2,'ShowArrowHead','off');
hold off; axis off;