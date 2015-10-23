function [LLRmap, q1table] = getJmapNA_EM_oracle(image,ncomp,c2,k1,k2,simple)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block

coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
q1table = ones(8);
minQ = max(2, floor(qtable/sqrt(3)));
maxQ = max(jpeg_qtable(50), qtable);

% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
% EDC = Edct(1:8:end,1:8:end);
% biasE = mean(EDC(:));
% varE = var(EDC(:));

I = ibdct(dequantize(coeffArray, qtable));
% figure, imshow(I, [])
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
binHist = (-2^11:1:2^11-1);
center = 2^11;



for index = 1:c2
% 
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    
    A = zeros(8);
    A(ic1,ic2) = 1;
    B = idct2(A);
    
    AC = conv2(I, B);
%     AC = imfilter(I, B, 'circular', 'full');
    AC = AC(8:end,8:end);
    ACpoly = AC(k1:8:end,k2:8:end);
    % choose shift for estimating unquantized distribution through
    % calibration
    if k1 < 5
        k1cal = k1 + 1;
    else
        k1cal = k1 - 1;
    end
    if k2 < 5
        k2cal = k2 + 1;
    else
        k2cal = k2 - 1;
    end
    ACcal = AC(k1cal:8:end,k2cal:8:end);
    hcal = hist(ACcal(:),binHist);
    hcalnorm = (hcal+1)/(numel(ACcal)+numel(binHist));
    
%     hcal = zeros(size(binHist));
%     for k1cal = 1:8
%         for k2cal = 1:8
%             if k1cal > 1 && k2cal > 1 && k1cal ~= k1 && k2cal ~= k2
%                 ACcal = AC(k1cal:8:end,k2cal:8:end);
%                 hcal = hcal  + hist(ACcal(:),binHist);
%             end
%         end
%     end
%     hcalnorm = (hcal+1)/(sum(hcal)+numel(binHist));
            
    
    % estimate std dev of quantization error on DCT coeffs (quantization of
    % second compression plus rounding/truncation between first and second
    % compression)
    EAC = Edct(ic1:8:end,ic2:8:end);
    varE = var(EAC(:));
    if index == 1
        bias = mean(EAC(:));
    else
        bias = 0;
    end
    sig = sqrt(qtable(ic1,ic2)^2 / 12 + varE);
    
    % define mixture components
    p0 = @(x) hcalnorm(round(x) + center + 1);
    p1 = @(x,Q) h1period(x, Q, hcal, binHist, center, bias, sig);
%     p1 = @(x,Q) exp(LLR(x, binHist, Q, 0, 2^11, sig)) .* p0(x);
   
    [Q, alpha] = EMperiod(ACpoly(:), minQ(ic1,ic2), maxQ(ic1,ic2), 0.5, p0, p1, 100, 100);
    q1table(ic1,ic2) = Q;
    
    if simple
        nz = sum(ACpoly(:) ~= 0)/numel(ACpoly);
        LLRmap(:,:,index) = LLR(ACpoly, binHist, nz, Q, round(bias), center, sig);
    else
        ppu = log(p1(binHist, Q)./p0(binHist));
        LLRmap(:,:,index) = ppu(round(ACpoly) + center + 1);
    end
%     LLRmap = LLRmap + LLRtmp;
%     figure, imagesc(LLRmap, [-40 40]/9)
%     figure, imagesc(LLRmap)
%     figure, imagesc(1./(1+exp(-LLRmap)), [0 1])
%     pause
end

% % smooth LLRmap and correct shift
% LLRmapS = smooth_unshift(sum(LLRmap,3),k1,k2);
% 
% % map = 1./(1+exp(-LLRmap));
% % figure, imagesc(map, [0 1])
% figure, imagesc(LLRmapS, [-40 40])
% % figure, imagesc(LLRmap2, [-40 40])
% 
% refmask = true(128);
% refmask(49:80,49:80) = false;
% [FP, TP] = computeROC(LLRmapS, refmask, 1000);
% % figure, plot(FP/(32^2),TP/(128^2-32^2))
% display(['AUC of LLRmap = ', num2str(trapz(FP/(32^2),TP/(128^2-32^2)))]);
% 
% q1table

return