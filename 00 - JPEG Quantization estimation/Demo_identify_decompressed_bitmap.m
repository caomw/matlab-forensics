% Demonstration of decompressed identification based on factor histogram
% 2015-04-15

close all;
clear;

img_name = 'lena.bmp';
QF = 70;

pathstr =  fileparts(mfilename('fullpath'));
addpath(pathstr);

% the factor histogram based feature of uncompressed bitmap
uncps_bitmap = imread([pathstr, '/', img_name]);
uncps_Sac = fh_jpgdetect(uncps_bitmap);

% the factor histogram based feature of decompressed bitmap
[tmp, name, ext] =  fileparts(img_name);
imwrite(uncps_bitmap, [pathstr, '/', name, '.jpg'], 'quality', QF);
decps_bitmap = imread([pathstr, '/', name, '.jpg']);
decps_Sac = fh_jpgdetect(decps_bitmap);

fprintf('Sac of uncompressed bitmap: %.6f\nSac of decompressed bitmap: %.6f\n', uncps_Sac, decps_Sac);

