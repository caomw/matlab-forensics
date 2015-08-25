function [V] = globalNoiVarEstimate(noi,ft,fz,gs) 
% globalNoiVarEstimate: global noise variance estimation using kurtosis
%
% [estVar] = globalNoiVarEstimate(noisyIm,filter_type,filter_size)
% 
% input arguments:
%	noisyIm: input noisy image 
%	filter_type: the type of band-pass filter used 
%        supported types, "dct", "haar", "rand"
%   filter_size: the size of the support of the filter
% output arguments:
%	estVar: estimated global noise variance
%
% reference:
%   X.Pan, X.Zhang and S.Lyu, Exposing Image Splicing with
%   Inconsistent Local Noise Variances, IEEE International
%   Conference on Computational Photography, Seattle, WA, 2012
%
% disclaimer:
%	Please refer to the ReadMe.txt
%
% Xunyu Pan, Xing Zhang and Siwei Lyu -- 07/26/2012             

switch ft
	case 'dct',
		fltrs = dct2mtx(fz,'grid');
	case 'haar',
		fltrs = haar2mtx(fz);
	case 'rand',
		fltrs = rnd2mtx(fz);
	otherwise,
		error('unknown filter');
end

% decompose into channels
ch = zeros([size(noi)-fz+1,fz*fz-1]);
for k = 2:(fz*fz)
	ch(:,:,k-1) = conv2(noi,fltrs(:,:,k),'valid');
end

% collect raw moments
mu1 = squeeze(sum(sum(ch,1),2))/prod(size(noi));
mu2 = squeeze(sum(sum(ch.^2,1),2))/prod(size(noi));
mu3 = squeeze(sum(sum(ch.^3,1),2))/prod(size(noi));
mu4 = squeeze(sum(sum(ch.^4,1),2))/prod(size(noi));

% variance & sqrt of kurtosis
noiV = mu2 - mu1.^2;
noiK = (mu4 - 4*mu1.*mu3 + 6*mu1.^2.*mu2 - 3*mu1.^4)./(noiV.^2)-3; 

% estimate noise variance
a = mean(sqrt(noiK));
b = mean(1./noiV);
c = mean(1./noiV.^2);
d = mean(sqrt(noiK)./noiV);
sqrtK = (a*c - b*d)/(c-b*b);
V = (1 - a/sqrtK)/b;

return
