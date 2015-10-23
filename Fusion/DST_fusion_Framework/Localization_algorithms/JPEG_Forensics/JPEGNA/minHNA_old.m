function [minH0, minH1, minH2] = minHNA(image,ncomp,Q1)
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
% coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);
hspecref = 0;
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
        if k1 == 1 && k2 == 1
            hspecref = hspec;
        end
        if qtable(1,1) > 1
            Qmap(k1,k2,:) = hspec / hspecref(periods == qtable(1,1));
        else
            Qmap(k1,k2,:) = hspec / sum(num4Bin);
        end
    end
end

minH0 = [];
minH1 = [];
minH2 = [];
% k1dQ = 0;
% k2dQ = 0;
% k1sQ = 0;
% k2sQ = 0;
% Q = 0;
% maxQmap = 0;
for k = 1:length(periods)
    Qmaptmp = Qmap(:,:,k);
    if periods(k) == qtable(1,1) && (Q1 == qtable(1,1) || Q1 == 0) 
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
        Qmaptmp2 = max(Qmaptmp2, 0);
        minH2 = min(-log2(Qmaptmp2(:)/sum(Qmaptmp2(:))));
%         figure, imagesc(Qmaptmp2), title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
%         if minH < 2.5
%             [m1,i1] = max(Qmaptmp2);
%             [m2,i2] = max(m1);
%             if i1(i2) > 1 || i2 > 1
%                 k1sQ = i1(i2);
%                 k2sQ = i2;
%             end
%         end
    else
        minH = min(-log2(Qmaptmp(:)/sum(Qmaptmp(:))));
        if periods(k) == Q1
            minH1 = minH;
        elseif Q1 == 0
            [m1,i1] = max(Qmaptmp);
            [m2,i2] = max(m1);
            if (i1(i2) > 1 || i2 > 1)
                 minH0 = [minH0 minH];
            end
        end
%         figure, imagesc(Qmaptmp, [0 1]), title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
%         if minH < 4
%             [m1,i1] = max(Qmaptmp);
%             [m2,i2] = max(m1);
%             if (i1(i2) > 1 || i2 > 1) && m2 > maxQmap
%                 k1dQ = i1(i2);
%                 k2dQ = i2;
%                 maxQmap = m2;
%                 Q = periods(k);
%             end
%         end
    end
end

return