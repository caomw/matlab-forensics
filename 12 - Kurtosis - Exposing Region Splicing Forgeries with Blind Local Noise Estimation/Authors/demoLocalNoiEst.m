% demonstration of local noise estimation
% based on the work of
%   X.Pan, X.Zhang and S.Lyu, Exposing Image Splicing with
%   Inconsistent Local Noise Variances, IEEE International
%   Conference on Computational Photography, Seattle, WA, 2012

clear;
sz = 3;
im = double(imread('cameraman.tif'));
flt = ones(sz,1);
flt = flt*flt'/sz^2;
im = conv2(im,flt,'same');
sig1 = 2;
noi1 = im+randn(size(im))*sig1;
sig2 = 5;
noi2 = im+randn(size(im))*sig2;


% half the image have different noise level
noiIm = noi1;
noiIm(200:end,:) = noi2(200:end,:);

sigs = 2; % size of sliding window
estV = zeros([size(im),length(sigs)]);
for k = 1:length(sigs)
    estV(:,:,k) = localNoiVarEstimate(noiIm,'dct',4,sigs(k));
    %estV(:,:,k) = localNoiVarEstimate(noiIm,'haar',4,sigs(k));
    %estV(:,:,k) = localNoiVarEstimate(noiIm,'rand',4,sigs(k));
end

% display the log of the estimated local variances
subplot(121); imagesc(noiIm); truesize
subplot(122)
imagesc(log10(sqrt(mean(estV,3)))); axis equal; axis image
colorbar;
colormap(gray);
title('log_{10}(estimated local variance)')
return
