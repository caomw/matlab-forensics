function [D,n] = genDisk(radius)
%generate a disk-shaped structuring element
%  [D,n] = genDisk(radius)
% 

    [X,Y] = meshgrid(-radius:radius,-radius:radius);
    D = double((X.^2+Y.^2)<=(radius^2));
    n = sum(D(:));