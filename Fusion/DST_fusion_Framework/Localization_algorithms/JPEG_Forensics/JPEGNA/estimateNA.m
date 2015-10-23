function [k1,k2,Q] = estimateNA(image,ncomp)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block

coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
minQ = max(2, floor(qtable/sqrt(3)));
maxQ = max(16, qtable);

I = ibdct(dequantize(coeffArray, qtable));

DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);
Qmap = zeros(8,8,maxQ(1,1)-minQ(1,1)+1);

binHist = (-2^11:1:2^11-1);
periods = minQ(1,1):maxQ(1,1);
harmfreq = 1./periods;
IPDFT = exp(-2*pi*i* binHist' * harmfreq);

for k1 = 1:8
    for k2 = 1:8
        DCpoly = DC(k1:8:end,k2:8:end);
        num4Bin = hist(DCpoly(:),binHist);
        hspec = abs(num4Bin * IPDFT);
        Qmap(k1,k2,:) = hspec;
    end
end

k1 = 0;
k2 = 0;
Q = 0;
minHref1 = 6;
minHref2 = 6;
maxQmap = 0;
for k = 1:length(periods)
    Qmaptmp = Qmap(:,:,k);
    if periods(k) == qtable(1,1)
        Qmaptmp2(2:4,2:4) = Qmaptmp(2:4,2:4) - (Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(2:4,8:-1:6) = Qmaptmp(2:4,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,2:4) = Qmaptmp(8:-1:6,2:4) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,8:-1:6) = Qmaptmp(8:-1:6,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4)) / 3;
        Qmaptmp2(1,2:4) = Qmaptmp(1,2:4) - Qmaptmp(1,8:-1:6);
        Qmaptmp2(1,8:-1:6) = Qmaptmp(1,8:-1:6) - Qmaptmp(1,2:4);
        Qmaptmp2(2:4,1) = Qmaptmp(2:4,1) - Qmaptmp(8:-1:6,1);
        Qmaptmp2(8:-1:6,1) = Qmaptmp(8:-1:6,1) - Qmaptmp(2:4,1);
        Qmaptmp2(5,2:4) = Qmaptmp(5,2:4) - Qmaptmp(5,8:-1:6);
        Qmaptmp2(5,8:-1:6) = Qmaptmp(5,8:-1:6) - Qmaptmp(5,2:4);
        Qmaptmp2(2:4,5) = Qmaptmp(2:4,5) - Qmaptmp(8:-1:6,5);
        Qmaptmp2(8:-1:6,5) = Qmaptmp(8:-1:6,5) - Qmaptmp(2:4,5);
        Qmaptmp2(1,5) = Qmaptmp(1,5) - (Qmaptmp(1,4) + Qmaptmp(1,6)) / 2;
        Qmaptmp2(5,1) = Qmaptmp(5,1) - (Qmaptmp(4,1) + Qmaptmp(6,1)) / 2;
        Qmaptmp2(5,5) = Qmaptmp(5,5) - (Qmaptmp(4,5) + Qmaptmp(6,5) + Qmaptmp(5,4) + Qmaptmp(5,6)) / 4;
        Qmaptmp2(1,1) = 0;
%         Qmaptmp2 = max(Qmaptmp2, 0);
        Qmaptmp2 = Qmaptmp2 + mean(Qmaptmp(2:end));
        minH = min(-log2(Qmaptmp2(:)/sum(Qmaptmp2(:))));
%         figure, imagesc(0:7,0:7,Qmaptmp/sum(Qmaptmp(:)), [0 1/4]) , title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
%         axis square
%         figure, imagesc(0:7,0:7,Qmaptmp2/sum(Qmaptmp2(:)), [0 1/2]) , title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
%         axis square
        if minH < minHref1
            [m1,i1] = max(Qmaptmp2);
            [m2,i2] = max(m1);
            if i1(i2) > 1 || i2 > 1
                k1 = i1(i2);
                k2 = i2;
                minHref2 = minH;
                Q = periods(k);
            end
        end
    else
        minH = min(-log2(Qmaptmp(:)/sum(Qmaptmp(:))));
%         figure, imagesc(0:7,0:7,Qmaptmp/sum(Qmaptmp(:)), [0 1/4]) , title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
%         axis square
        [m1,i1] = max(Qmaptmp);
        [m2,i2] = max(m1);            
        if (i1(i2) > 1 || i2 > 1) && m2 > maxQmap && minH < minHref2
            k1 = i1(i2);
            k2 = i2;
            maxQmap = m2;
            minHref1 = minH;
            Q = periods(k);
        end
    end
end

return