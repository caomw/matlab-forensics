function [V] = localNoiVarEstimate(noi,ft,fz,br) 
% localNoiVarEstimate: local noise variance estimation using kurtosis
%
% [estVar] = localNoiVarEstimate(noisyIm,filter_type,filter_size,block_size)
% 
% input arguments:
%	noisyIm: input noisy image 
%	filter_type: the type of band-pass filter used 
%        supported types, "dct", "haar", "rand"
%   filter_size: the size of the support of the filter
%   block_rad: the size of the local blocks
% output arguments:
%	estVar: estimated local noise variance
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
		fltrs = dct2mtx(fz,'snake');
	case 'haar',
		fltrs = haar2mtx(fz);
	case 'rand',
		fltrs = rnd2mtx(fz);
	otherwise,
		error('unknown filter');
end

% decompose into channels
ch = zeros([size(noi),fz*fz-1],'single');
for k = 2:(fz*fz)
	ch(:,:,k-1) = conv2(noi,fltrs(:,:,k),'same');
end

% collect raw moments
blksz = (2*br+1)*(2*br+1);
mu1 = block_avg(ch,br,'mi');
save('mu1.mat','mu1');
clear mu1
mu2 = block_avg(ch.^2,br,'mi');
save('mu2.mat','mu2');
clear mu2
mu3 = block_avg(ch.^3,br,'mi');
save('mu3.mat','mu3');
mu4 = block_avg(ch.^4,br,'mi');

load('mu3.mat');
load('mu1.mat');
delete('mu1.mat','mu3.mat');

%[r,w] = unix('free | grep Mem');
%stats = str2double(regexp(w, '[0-9]*', 'match'));
%memsize = stats(1)/1e6;
%freemem = (stats(3)+stats(end))/1e6;
%disp(['All four BlockAvgs done:' num2str(freemem)]);

% variance & sqrt of kurtosis

Factor34=mu4 - 4*mu1.*mu3;
clear('mu4','mu3');

load('mu2.mat');
delete('mu2.mat');

noiV = mu2 - mu1.^2;
noiK = (Factor34 + 6*mu1.^2.*mu2 - 3*mu1.^4)./(noiV.^2)-3; 
noiK = max(0,noiK);



%[r,w] = unix('free | grep Mem');
%stats = str2double(regexp(w, '[0-9]*', 'match'));
%memsize = stats(1)/1e6;
%freemem = (stats(3)+stats(end))/1e6;
%disp(['doneNoiK: ' num2str(freemem)]);

a = mean(sqrt(noiK),3);
b = mean(1./noiV,3);
c = mean(1./noiV.^2,3);
d = mean(sqrt(noiK)./noiV,3);
e = mean(noiV,3);

sqrtK = (a.*c - b.*d)./(c-b.*b);

V = single((1 - a./sqrtK)./b);
idx = sqrtK<median(sqrtK(:));
V(idx) = 1./b(idx);
idx = V<0;
V(idx) = 1./b(idx);

%[r,w] = unix('free | grep Mem');
%stats = str2double(regexp(w, '[0-9]*', 'match'));
%memsize = stats(1)/1e6;
%freemem = (stats(3)+stats(end))/1e6;
%disp(['doneDone: ' num2str(freemem)]);
%disp('---');

return
