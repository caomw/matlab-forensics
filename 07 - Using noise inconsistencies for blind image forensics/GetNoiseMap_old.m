function [ Map ] = GetNoiseMap( im,  BlockSize)
%GETNOISEMAP Summary of this function goes here
%   Detailed explanation goes here


if size(im,3)>3
    im=im(:,:,1:3);
end
imGray=double(rgb2gray(im));

[cA,cH,cV,cD] = dwt2(imGray,'db8'); %'haar', 'db2'...'db45', 'coif1'..'coif5','sym2'..'sym45', 'bior1.1'..'bior6.8'


cD=cD(1:floor(size(cD,1)/BlockSize)*BlockSize,1:floor(size(cD,2)/BlockSize)*BlockSize);


%disp([min(min(cD)) max(max(cD))]);


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