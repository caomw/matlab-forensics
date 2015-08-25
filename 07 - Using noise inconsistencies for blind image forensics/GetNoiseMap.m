function [ Map ] = GetNoiseMap( im , BlockSize)
%GETNOISEMAP Summary of this function goes here
%   Detailed explanation goes here
YCbCr=double(rgb2ycbcr(im));
Y=YCbCr(:,:,1);

[cA1,cH,cV,cD] = dwt2(Y,'db8'); %'haar', 'db2'...'db45', 'coif1'..'coif5','sym2'..'sym45', 'bior1.1'..'bior6.8'
%Tried to isolate noise using complex dual-tree wavelets instead, didn't get it right yet
%NoiseThresh=1;
%Depth=3;
%Denoised=DTWDenoise(Y,NoiseThresh,Depth);
%cD=Y-Denoised;

cD=cD(1:floor(size(cD,1)/BlockSize)*BlockSize,1:floor(size(cD,2)/BlockSize)*BlockSize);
Block=zeros(floor(size(cD,1)/BlockSize),floor(size(cD,2)/BlockSize),BlockSize.^2);

for ii=1:BlockSize:size(cD,1)-1
    for jj=1:BlockSize:size(cD,2)-1
        blockElements=cD(ii:ii+BlockSize-1,jj:jj+BlockSize-1);
        Block((ii-1)/BlockSize+1,(jj-1)/BlockSize+1,:)=reshape(blockElements,[1 1 numel(blockElements)]);
    end
end

s=median(abs(Block),3)./0.6745;

Map=s;

end