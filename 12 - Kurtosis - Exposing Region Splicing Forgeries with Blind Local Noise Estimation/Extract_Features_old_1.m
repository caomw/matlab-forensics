%function [overall_k,overall_s2, m1, m2, m3, m4, s2, k] = Extract_Features( im )
%DETECT_CROP Summary of this function goes here
%   Detailed explanation goes here

% Bandpass filtering performed via DCT. Could also be done using ICT. Could
% it work using the JPEG channels?

tic
%Size of the DCT transform
DCTSize=8;
%Size of the sliding window
WindowSize=32;

%Number of frequencies to drop from the high end of each direction
FreqsToDrop=0;


YCbCr=rgb2ycbcr(im);
Y=im(:,:,1);
%Crop image to perfectly fit DCT window
Y=Y(1:floor(size(Y,1)/DCTSize)*DCTSize,1:floor(size(Y,2)/DCTSize)*DCTSize);

D=dctmtx(DCTSize);

DCT=ones(floor([(size(Y)-DCTSize)+1 (DCTSize-FreqsToDrop).^2-1]))*-inf;

for ii=1:size(Y,1)-DCTSize+1
    for jj=1:size(Y,2)-DCTSize+1
        tmpDCT=D*double(Y(ii:ii+DCTSize-1,jj:jj+DCTSize-1))*D';
        tmpDCT=tmpDCT(1:end-FreqsToDrop,1:end-FreqsToDrop);
        tmpDCT=reshape(tmpDCT,1,1,numel(tmpDCT));
        tmpDCT=tmpDCT(:,:,2:end);
        DCT((ii-1)+1,(jj-1)+1,:)=tmpDCT;
    end
end


disp('DCT computed');
toc

tic
%Compute moments
DCT2=DCT.^2;
DCT3=DCT.^3;
DCT4=DCT.^4;


for ii=1:size(DCT,3)
    I1(:,:,ii)=integralImage(DCT(:,:,ii));
    I2(:,:,ii)=integralImage(DCT2(:,:,ii));
    I3(:,:,ii)=integralImage(DCT3(:,:,ii));
    I4(:,:,ii)=integralImage(DCT4(:,:,ii));
end

%disp(['I1==0 ',num2str(sum(sum(sum(I1==0))))])


%I1=I1(2:end,2:end,:);
%I2=I2(2:end,2:end,:);
%I3=I3(2:end,2:end,:);
%I4=I4(2:end,2:end,:);

disp('Integral Images created');
toc

tic
m1=zeros(size(I1));
m2=zeros(size(I2));
m3=zeros(size(I3));
m4=zeros(size(I4));

for ii=1:size(DCT,1)-WindowSize
    for jj=1:size(DCT,2)-WindowSize
        m1(ii,jj,:)=(I1(ii+WindowSize, jj+WindowSize,:)+I1(ii, jj,:)-I1(ii+WindowSize, jj,:)-I1(ii, jj+WindowSize,:));
        m2(ii,jj,:)=(I2(ii+WindowSize, jj+WindowSize,:)+I2(ii, jj,:)-I2(ii+WindowSize, jj,:)-I2(ii, jj+WindowSize,:));
        m3(ii,jj,:)=(I3(ii+WindowSize, jj+WindowSize,:)+I3(ii, jj,:)-I3(ii+WindowSize, jj,:)-I3(ii, jj+WindowSize,:));
        m4(ii,jj,:)=(I4(ii+WindowSize, jj+WindowSize,:)+I4(ii, jj,:)-I4(ii+WindowSize, jj,:)-I4(ii, jj+WindowSize,:));
    end
end

m1=m1(1:end-WindowSize,1:end-WindowSize,:);
m2=m2(1:end-WindowSize,1:end-WindowSize,:);
m3=m3(1:end-WindowSize,1:end-WindowSize,:);
m4=m4(1:end-WindowSize,1:end-WindowSize,:);


m1=m1./WindowSize.^2;
m2=m2./WindowSize.^2;
m3=m3./WindowSize.^2;
m4=m4./WindowSize.^2;

disp('Means estimated');
toc

%Eq. 6
s2=m2-m1.^2;


%Why are negative values generated? is it sth like a rounding problem, or a
%fundamental maths one? k should be positive, not "near"-positive...
k_num=(m4-4.*m3.*m1+6.*m2.*(m1.^2)-3.*(m1.^4));
k_denom=(m2.^2-2.*m2.*(m1.^2)+m1.^4);
k=k_num./k_denom;

%THE -3 GENERATES MANY NEGATIVE VALUES. MATLAB "kurtosis()" DOES NOT USE IT...
%WITHOUT THE -3, THIS IS A PERFECT SUPERFAST APPROXIMATION OF MATLAB kurtosis()

k(k_denom==0)=0;

%plot k values
%figure;
%plot(reshape(k,1,numel(k)),'LineStyle','none','Marker','o');
disp(['amount of overall_s2<0: ' num2str(sum(sum(overall_s2<0))./numel(overall_s2<0).*100) '%']);
k(k<0)=0;

overall_k_num=mean(sqrt(k),3).*mean(1/(s2.^2),3)-mean(sqrt(k)./s2,3).*mean(1/s2,3);
overall_k_denom=mean(1/(s2.^2),3)-mean(1/s2,3).^2;

overall_k_root=overall_k_num./overall_k_denom;
overall_k_root(overall_k_denom==0)=0;
overall_k_root(sum(s2==0,3)>0)=0;

overall_s2=1./mean(1./s2,3)-(1./overall_k_root).*(mean(sqrt(k),3)./mean(1/s2,3));
overall_s2(overall_k_root==0)=0;
disp(['amount of overall_s2<0: ' num2str(sum(sum(overall_s2<0))./numel(overall_s2<0).*100) '%']);

%overall_s2(overall_s2<0)=0;

overall_k=overall_k_root.^2;
