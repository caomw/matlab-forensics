function [ BMat ] = GetBlockArtifact(imJPG, imRaw)%GETBLOCKARTIFACT Summary of this function goes here
    %   Detailed explanation goes here
    MaxCoeffs=32;% %64;
    coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
    
    Q=imJPG.quant_tables{1};
    YDCT=imJPG.coef_arrays{1};
    YDCT=dequantize(YDCT,Q);
    imSize=size(YDCT);
    YDCT_Block=reshape(YDCT,[8 round(imSize(1)/8) 8 round(imSize(2)/8)]);
    YDCT_Block=permute(YDCT_Block, [1 3 2 4]);
    YDCT_Block=reshape(YDCT_Block, [8 8 round(imSize(1)*imSize(2)/64)]);
    
    imRaw=double(imRaw);
    %Y=rgb2ycbcr(imRaw);
    Y=0.299*imRaw(:,:,1)+0.587*imRaw(:,:,2)+0.114*imRaw(:,:,3);
    Y=Y(:,:,1);
    Y=Y(1:floor(end/8)*8,1:floor(end/8)*8);
    Y=Y-128;
    
    T = dctmtx(8);
    dct = @(block_struct) T * block_struct.data * T';
    YDCTRaw=round(blockproc(Y,[8 8],dct));
    %Use this instead, much closer to original JPEG DCT
    %YDCTRaw=round(bdct(Y,8));
    imSizeRaw=size(Y);
    YDCT_BlockRaw=reshape(YDCTRaw,[8 round(imSizeRaw(1)/8) 8 round(imSizeRaw(2)/8)]);
    YDCT_BlockRaw=permute(YDCT_BlockRaw, [1 3 2 4]);
    YDCT_BlockRaw=reshape(YDCT_BlockRaw, [8 8 round(imSizeRaw(1)*imSizeRaw(2)/64)]);

    
    
    %X=reshape(Y,[8 8 m/p n/q]);
    %X=permute(X,[1 3 2 4]);
    %X=reshape(X,[m n]);   
    
    NoPeaks=false;
    NoPeaksRaw=false;
    
    MinDCT=min(min(YDCT_Block,[],3));
    MaxDCT=max(max(YDCT_Block,[],3));
    DCTHists=histc(YDCT_Block,MinDCT:MaxDCT,3);
    
    MinDCTRaw=min(min(YDCT_BlockRaw,[],3));
    MaxDCTRaw=max(max(YDCT_BlockRaw,[],3));
    %DCTHistsRaw=histc(YDCT_BlockRaw,MinDCT:MaxDCT,3);
    DCTHistsRaw=histc(YDCT_BlockRaw,-257:257,3);
    DCTHistsRaw=DCTHistsRaw(:,:,2:end-1);
    
    QEst=zeros(8);
    
    %skip the DC term
    for coeffIndex=2:MaxCoeffs
        coe = coeff(coeffIndex);
        startY = mod(coe,8);
        if startY == 0
            startY = 8;
        end
        startX=ceil(coe/8);
        DCTHist=reshape(DCTHists(startY,startX,:),1,[]);
        HistFFT=fft(DCTHist);
        Power=abs(HistFFT);
        DispPower=Power;
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
        g=fspecial('gauss',[1 50],5);
        yfilt = conv (Diff2, g, 'same');
        yfilt(yfilt>min(yfilt)/5)=0;
        [ymax,imax,ymin,imin] = extrema(yfilt);
        if NoPeaks
            imin=[];
        end
        
        DCTHistRaw=reshape(DCTHistsRaw(startY,startX,:),1,[]);
        HistFFTRaw=fft(DCTHistRaw);
        PowerRaw=abs(HistFFTRaw);
        DispPowerRaw=PowerRaw;
        %descend until first local minimum to get rid of DC peak
        g=fspecial('gauss',[1 50],PowerFilterSize);
        PowerFiltRaw = conv(PowerRaw, g, 'same');
        ValleyRaw=1;
        while (ValleyRaw<length(PowerFiltRaw)-1) && (PowerFiltRaw(ValleyRaw)<=PowerFiltRaw(ValleyRaw+1))
            ValleyRaw=ValleyRaw+1;
        end
        ValleyRaw=ValleyRaw+1;
        while (ValleyRaw<length(PowerFiltRaw)-1) && (PowerFiltRaw(ValleyRaw)>= PowerFiltRaw(ValleyRaw+1))
            ValleyRaw=ValleyRaw+1;
        end
        if ValleyRaw*2<length(PowerRaw*0.8)
            PowerRaw=PowerRaw(ValleyRaw:end-ValleyRaw);
        else
            NoPeaksRaw=true;
        end
        Diff2Raw=diff(PowerRaw,2);
        g=fspecial('gauss',[1 50],5);
        yfiltRaw = conv (Diff2Raw, g, 'same');
        yfiltRaw(yfiltRaw>min(yfiltRaw)/5)=0;
        [ymax,imax,ymin,iminRaw] = extrema(yfiltRaw);       
        if NoPeaksRaw
            iminRaw=[];
        end
                
        
        %figure(11)
        %subplot(2,1,1)
        %bar(PowerFilt)
        %subplot(2,1,2)
        %bar(PowerFiltRaw)
        %figure(12)
        %subplot(2,1,1)
        %bar(DispPower)
        %subplot(2,1,2)
        %bar(DispPowerRaw)
        %figure(13)
        %subplot(2,1,1)
        %bar(DispPower)
        %subplot(2,1,2)
        %bar(PowerRaw)
        %figure(14)
        %subplot(2,1,1)
        %bar(Diff2)
        %subplot(2,1,2)
        %bar(Diff2Raw)
        %figure(15)
        %subplot(2,1,1)
        %bar(yfilt)
        %subplot(2,1,2)
        %bar(yfiltRaw)
        disp([length(iminRaw) length(imin) Q(startY,startX)]);
        %if length(imin)+1~=Q(startY,startX)
        %    disp(coeffIndex)
        %    break
        %end
        %pause;
        
        QEst(startY,startX)=length(iminRaw+1);
    end
    D=repmat(QEst,1,1,size(YDCT_Block,3));
    BMat=abs(YDCT_Block-round(YDCT_Block./D).*D);
    BMat(isnan(BMat))=0;
    BMat=sum(sum(BMat));
    BMat=reshape(BMat,imSize(1)/8,imSize(2)/8);
end