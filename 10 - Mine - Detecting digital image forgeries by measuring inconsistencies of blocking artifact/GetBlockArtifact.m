function [ BMat ] = GetBlockArtifact(im)%GETBLOCKARTIFACT Summary of this function goes here
    %   Detailed explanation goes here
    MaxCoeffs=32;% %64;
    coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
    
    if isstruct(im)
        Q=im.quant_tables{1};
        YDCT=im.coef_arrays{1};
        YDCT=dequantize(YDCT,Q);
        imSize=size(YDCT);
        YDCT_Block=reshape(YDCT,[8 round(imSize(1)/8) 8 round(imSize(2)/8)]);
        YDCT_Block=permute(YDCT_Block, [1 3 2 4]);
        YDCT_Block=reshape(YDCT_Block, [8 8 round(imSize(1)*imSize(2)/64)]);
    else
        im=double(im);
    %Y=rgb2ycbcr(imRaw);
        Y=0.299*im(:,:,1)+0.587*im(:,:,2)+0.114*im(:,:,3);
        Y=Y(:,:,1);
        Y=Y(1:floor(end/8)*8,1:floor(end/8)*8);
        Y=Y-128;
    
        T = dctmtx(8);
        dct = @(block_struct) T * block_struct.data * T';
        %YDCT=round(blockproc(Y,[8 8],dct));
        %Use this instead, much closer to original JPEG DCT
        YDCT=round(bdct(Y,8));
        imSize=size(Y);
        YDCT_Block=reshape(YDCT,[8 round(imSize(1)/8) 8 round(imSize(2)/8)]);
        YDCT_Block=permute(YDCT_Block, [1 3 2 4]);
        YDCT_Block=reshape(YDCT_Block, [8 8 round(imSize(1)*imSize(2)/64)]);
    end
    
    NoPeaks=false;
    
    DCTHists=histc(YDCT_Block,-257:257,3);
    DCTHists=DCTHists(:,:,2:end-1);
    
    QEst=zeros(8);
    
    %skip the DC term
    for coeffIndex=2:MaxCoeffs
        NoPeaks=false;
        coe = coeff(coeffIndex);
        startY = mod(coe,8);
        if startY == 0
            startY = 8;
        end
        startX=ceil(coe/8);
        DCTHist=reshape(DCTHists(startY,startX,:),1,[]);
        HistFFT=fft(DCTHist);
        Power=abs(HistFFT);
        PowerFilterSize=3;
        g=fspecial('gauss',[1 50],PowerFilterSize);
        PowerFilt = conv(Power, g, 'same');
        Valley=1;
        while (PowerFilt(Valley)<=PowerFilt(Valley+1))
            Valley=Valley+1;
        end
        Valley=Valley+1;
        while (Valley<length(PowerFilt)-1) && (PowerFilt(Valley)>= PowerFilt(Valley+1))
            Valley=Valley+1;
        end
        if Valley*2<length(Power*0.8)
            Power=Power(Valley:end-Valley);
        else
            NoPeaks=true;
        end
        Diff2=diff(Power,2);
        if length(Diff2)==0
            Diff2=0;
        end
        g=fspecial('gauss',[1 50],5);
        yfilt = conv (Diff2, g, 'same');
        yfilt(yfilt>min(yfilt)/5)=0;
        [ymax,imax,ymin,imin] = extrema(yfilt);
        if NoPeaks
            imin=[];
        end
        QEst(startY,startX)=length(imin+1);
    end
    D=repmat(QEst,[1,1,size(YDCT_Block,3)]);
    BMat=abs(YDCT_Block-round(YDCT_Block./D).*D);
    BMat(isnan(BMat))=0;
    BMat=sum(sum(BMat));
    BMat=reshape(BMat,imSize(1)/8,imSize(2)/8);
end