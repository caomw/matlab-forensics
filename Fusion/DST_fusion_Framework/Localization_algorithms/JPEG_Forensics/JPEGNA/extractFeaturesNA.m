function [f] = extractFeaturesNA(filename, siz)

im = jpeg_read(filename);
[f(1) f(2)] = minHNA(im, 1);

return