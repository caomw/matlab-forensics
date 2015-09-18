function dist2 = MPFspacedist2(mpf_y,mpf_x)
%Compute the square of spatial distance
% dist2 = MPFspacedist2(mpf_y,mpf_x)
%
%   mpf_x   column indexes;
%   mpf_y   row indexes;
%

    [Nr, Nc] = size(mpf_y);
    [xp, yp] = meshgrid(0:(Nc-1),0:(Nr-1));
    dist2    = abs(mpf_y-yp).^2 + abs(mpf_x-xp).^2;