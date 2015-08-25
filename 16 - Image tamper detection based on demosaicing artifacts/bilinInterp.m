function [ Out_Im ] = bilinInterp( CFAIm,BinFilter,CFA )
%BILININTERP Summary of this function goes here
%   Detailed explanation goes here
CFAIm=double(CFAIm);

MaskMin=1/4*[1 2 1;2 4 2;1 2 1];
MaskMaj=1/4*[0 1 0;1 4 1;0 1 0];

if ~isempty(find(diff(CFA)==0)) ||  ~isempty(find(diff(CFA')==0))
    MaskMaj=MaskMaj.*2;
end



Mask=repmat(MaskMin,[1,1,3]);
[a,Maj]=max(sum(sum(BinFilter)));
Mask(:,:,Maj)=MaskMaj;

Out_Im=zeros(size(CFAIm));


for ii=1:3
    Mixed_im=zeros([size(CFAIm,1),size(CFAIm,2)]);
   
    Orig_Layer=CFAIm(:,:,ii);
%    figure(11);   image(Orig_Layer);colormap(gray(255));
    Interp_Layer=imfilter(Orig_Layer,Mask(:,:,ii));
%    figure(12);   image(Interp_Layer);colormap(gray(255));
    Mixed_im(BinFilter(:,:,ii)==0)=Interp_Layer(BinFilter(:,:,ii)==0);
 %   figure(13);   image(Mixed_im);colormap(gray(255));
    Mixed_im(BinFilter(:,:,ii)==1)=Orig_Layer(BinFilter(:,:,ii)==1);
    Out_Im(:,:,ii)=Mixed_im;
end
%figure(15);image(Out_Im(:,:,3));colormap(gray(255));pause

%cropDim=(size(MaskMin,1)-1)/2;
%cropDim=ceil(cropDim/2)*2;
%Out_Im=Out_Im(cropDim+1:end-cropDim,cropDim+1:end-cropDim,:);

Out_Im=uint8(Out_Im);