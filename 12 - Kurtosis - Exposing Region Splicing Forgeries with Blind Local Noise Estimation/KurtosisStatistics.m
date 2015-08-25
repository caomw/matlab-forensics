

List=dir('ForStats/');
List={List(3:end).name};

CollectedDCT=[];

for ImageFile=3:length(List)
    tic
    disp(ImageFile/length(List))
    im=CleanUpImage(['ForStats/' List{ImageFile}]);
    %Size of the DCT transform
    DCTSize=8;
    Overlap=false;
    %Size of the sliding window
    
    MaxCoeffs=64;
    if DCTSize==8
        coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
    else
        coeff = 1:DCTSize.^2;
        MaxCoeffs=DCTSize.^2;
    end
    
    
    
    YCbCr=rgb2ycbcr(im);
    Y=double(im(:,:,1));
    
    D=dctmtx(DCTSize);
    
    if Overlap
        DCTStep=1;
        DCT=ones([size(Y)-DCTSize+1 MaxCoeffs-1])*-inf;
    else
        %Crop image to perfectly fit DCT window
        %disp('not overlapping');
        Y=Y(1:floor(size(Y,1)/DCTSize)*DCTSize,1:floor(size(Y,2)/DCTSize)*DCTSize);
        DCTStep=DCTSize;
        DCT=ones([size(Y)/DCTSize MaxCoeffs-1])*-inf;
    end
    
    for ii=1:DCTStep:size(Y,1)-DCTSize+1
        for jj=1:DCTStep:size(Y,2)-DCTSize+1
            tmpDCT=D*Y(ii:ii+DCTSize-1,jj:jj+DCTSize-1)*D';
            tmpDCT=reshape(tmpDCT,1,1,numel(tmpDCT));
            tmpDCT=tmpDCT(:,:,coeff); %reorder according to zigzag
            tmpDCT=tmpDCT(:,:,2:MaxCoeffs); %only keep some low coefficients
            DCT((ii-1)/DCTStep+1,(jj-1)/DCTStep+1,:)=tmpDCT;
        end
    end
    
    
    %disp('DCT computed');
    toc
    serializedDCT=reshape(DCT,[],MaxCoeffs-1);
    
    %Estimate global noise variance
    CollectedDCT=[CollectedDCT;serializedDCT];
    size(CollectedDCT)
    
    Subband_k=kurtosis(CollectedDCT);
    figure;plot(sort(Subband_k,'descend'),'LineStyle','none','Marker','o');
    pause
end
Subband_k=kurtosis(CollectedDCT)-3;

figure;plot(sort(Subband_k,'descend'),'LineStyle','none','Marker','o');