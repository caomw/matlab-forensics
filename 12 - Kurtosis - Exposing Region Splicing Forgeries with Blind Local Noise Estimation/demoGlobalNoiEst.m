% demonstration of global noise estimation
% based on the work of
%   X.Pan, X.Zhang and S.Lyu, Exposing Image Splicing with
%   Inconsistent Local Noise Variances, IEEE International
%   Conference on Computational Photography, Seattle, WA, 2012
%
% Siwei Lyu, 07/26/2012

clear;
sz = 2;
im = double(imread('lena.png'));
flt = ones(sz,1);
flt = flt*flt'/sz^2;
im = conv2(im,flt,'same');
sig = 1;
noi = randn(size(im))*sig;
disp(std(noi(:)));

noiIm = im + noi;
estV = globalNoiVarEstimate(noiIm,'dct',4);
%estV = globalNoiVarEstimate(noiIm,'haar',4);
%estV = globalNoiVarEstimate(noiIm,'rand',4);

disp(sqrt(estV));

return
