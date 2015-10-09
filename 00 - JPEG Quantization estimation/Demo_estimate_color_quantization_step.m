% Demonstration of quantization table estimation based on factor histogram
% 2015-04-15
close all;
clear;

img_name = 'lena.bmp';
QF = 70;

pathstr =  fileparts(mfilename('fullpath'));
addpath(pathstr);
addpath([pathstr, '/jpeg_toolbox/']);

% generate a decompressed bitmap
uncps_3=imread([pathstr, '/', img_name]);
imwrite(uncps_3, [pathstr, '/', name, '.jpg'], 'quality', QF);
decps_3 = imread([pathstr, '/', name, '.jpg']);
uncps_3ycbcr=rgb2ycbcr(uncps_3);

for ii=1:3
uncps_bitmap = uncps_3ycbcr(:,:,ii);
[tmp, name, ext] =  fileparts(img_name);
imwrite(uncps_bitmap, [pathstr, '/', name, '.jpg'], 'quality', QF);
decps_bitmap = imread([pathstr, '/', name, '.jpg']);

% estimate the quantization steps
qt_true = jpeg_qtable(QF);

threshold = 0.7;
qt_est = fh_jpgstep(decps_bitmap, threshold)

correct_label = (qt_est==qt_true)


