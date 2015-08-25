function [doctored, pro]=block(filename)

MACROBLOCK_W=16;
MACROBLOCK_H=16;
EDGE=50;

RGB=double(imread(filename));
[height,width,color]=size(RGB);
if (color==3)
    YCbCr=rgb2ycbcr(RGB);
    pixels=YCbCr(:,:,1);
else
    pixels=RGB;
end
pro=zeros(height,width);

tic
ht=2*pixels-[pixels(:,2:width),pixels(:,width)]-[pixels(:,1),pixels(:,1:width-1)];
vt=2*pixels-[pixels(2:height,:);pixels(height,:)]-[pixels(1,:);pixels(1:height-1,:)];
%ȥ�����EDGE�ģ���Ϊ�Ǳ߽�
m=sign(1-sign(abs(ht)-EDGE)); ht=ht.*m;
m=sign(1-sign(abs(vt)-EDGE)); vt=vt.*m;
toc

row=W_Filter(ht,MACROBLOCK_W,MACROBLOCK_H);
%m=sign(sign(row+1)); row=row.*m;
col=W_Filter(vt',MACROBLOCK_W,MACROBLOCK_H);
%m=sign(sign(col+1)); col=col.*m;
bag=row+col';
imtool(bag*10000);

pro=Mark(bag);
imtool(pro*10000);

doctored=bag;

%HSV=ones(height,width,3)*1;
%HSV(:,:,1)=0.67*(1-pro/(1+max(max(pro))));
%RGB=uint8(round(hsv2rgb(HSV)*255));
%doctored=RGB;
