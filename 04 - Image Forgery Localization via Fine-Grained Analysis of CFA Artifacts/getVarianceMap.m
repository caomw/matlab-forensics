% Copyright (C) 2011 Signal Processing and Communications Laboratory (LESC),       
% Dipartimento di Elettronica e Telecomunicazioni - Università di Firenze                        
% via S. Marta 3 - I-50139 - Firenze, Italy                   
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function [var_map] = getVarianceMap(im,Bayer,dim)

% extend pattern over all image
pattern = kron(ones(dim(1)/2,dim(2)/2), Bayer);

% separate acquired and interpolate pixels for a 7x7 window
mask = [1, 0, 1, 0, 1, 0, 1;
        0, 1, 0, 1, 0, 1, 0;
        1, 0, 1, 0, 1, 0, 1;
        0, 1, 0, 1, 0, 1, 0;
        1, 0, 1, 0, 1, 0, 1;
        0, 1, 0, 1, 0, 1, 0;
        1, 0, 1, 0, 1, 0, 1];

% gaussian window fo mean and variance
window = gaussian_window().*mask;
mc = sum(sum(window));
vc = 1 - (sum(sum((window.^2))));
window_mean = window./mc;

% local variance of acquired pixels
acquired = im.*(pattern);
mean_map_acquired = imfilter(acquired,window_mean,'replicate').*pattern;
sqmean_map_acquired = imfilter(acquired.^2,window_mean,'replicate').*pattern;
var_map_acquired =  (sqmean_map_acquired - (mean_map_acquired.^2))/vc;

% local variance of interpolated pixels
interpolated = im.*(1-pattern);
mean_map_interpolated = imfilter(interpolated,window_mean,'replicate').*(1-pattern);
sqmean_map_interpolated = imfilter(interpolated.^2,window_mean,'replicate').*(1-pattern);
var_map_interpolated = (sqmean_map_interpolated - (mean_map_interpolated.^2))/vc;


var_map = var_map_acquired + var_map_interpolated;

return