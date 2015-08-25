% demonstration of local noise estimation
% based on the work of
%   X.Pan, X.Zhang and S.Lyu, Exposing Image Splicing with
%   Inconsistent Local Noise Variances, IEEE International
%   Conference on Computational Photography, Seattle, WA, 2012

clear all;
sz = 3;
im = double(imread('canonxt_kodakdcs330_sub_01.tif'));
%Markos: convert to grayscale
im=rgb2ycbcr(im);
im=im(:,:,1);
    
flt = ones(sz,1);
flt = flt*flt'/sz^2;
im = conv2(im,flt,'same');
sig1 = 0;%2;
noi1 = im+randn(size(im))*sig1;
sig2 = 0;%5;
noi2 = im+randn(size(im))*sig2;


% half the image have different noise level
noiIm = noi1;
noiIm(200:end,:) = noi2(200:end,:);

sigs = [2 4 8]; % size of sliding window
estVDCT = zeros([size(im),length(sigs)]);
estVHaar = zeros([size(im),length(sigs)]);
estVRand = zeros([size(im),length(sigs)]);
for k = 1:length(sigs)
    estVDCT(:,:,k) = localNoiVarEstimate(noiIm,'dct',4,sigs(k));
    estVHaar(:,:,k) = localNoiVarEstimate(noiIm,'haar',4,sigs(k));
    estVRand(:,:,k) = localNoiVarEstimate(noiIm,'rand',4,sigs(k));
end

estVDCT(estVDCT<=0.001)=mean(mean(mean(estVDCT)));
estVHaar(estVHaar<=0.001)=mean(mean(mean(estVHaar)));
estVRand(estVRand<=0.001)=mean(mean(mean(estVRand)));

figure(1)
% display the log of the estimated local variances
subplot(1,2,1); imagesc(noiIm); axis equal; axis image; %truesize
colormap(gray);
subplot(1,2,2)
imagesc(log10(mean(estVDCT,3))); axis equal; axis image
colorbar;
colormap(gray);
title('log_{10}(estimated local variance (DCT))')

figure(2)
% display the log of the estimated local variances
subplot(1,2,1); imagesc(noiIm); axis equal; axis image; %truesize
colormap(gray);
subplot(1,2,2)
imagesc(log10(mean(estVHaar,3))); axis equal; axis image
colorbar;
colormap(gray);
title('log_{10}(estimated local variance (Haar))')

figure(3)
% display the log of the estimated local variances
subplot(1,2,1); imagesc(noiIm); axis equal; axis image; %truesize
colormap(gray);
subplot(1,2,2)
imagesc(log10(mean(estVRand,3))); axis equal; axis image
colorbar;
colormap(gray);
title('log_{10}(estimated local variance (Random filters))')


