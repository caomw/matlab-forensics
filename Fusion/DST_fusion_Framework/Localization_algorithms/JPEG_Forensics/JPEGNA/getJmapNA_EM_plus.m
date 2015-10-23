function [LLRmap, LLRmap_s, q1table, k1e, k2e, alphatable] = getJmapNA_EM(image,ncomp,c2)
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

I = ibdct(dequantize(coeffArray, qtable));
% figure, imshow(I, [])
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
binHist = (-2^11:1:2^11-1);
center = 2^11;

B = ones(8)/8;
DC = conv2(I, B);
DC = DC(8:end,8:end);
EDC = Edct(1:8:end,1:8:end);
varE = var(EDC(:));
bias = mean(EDC(:));
% sig = sqrt(qtable(1,1)^2 / 12 + varE);
alphatable = ones(8);
LLRmap = zeros([size(I)/8, c2]);
LLRmap_s = zeros([size(I)/8, c2]);
k1e = 1;
k2e = 1;
Lmax = -inf;

% alphavec = [];
% Lvec = [];
% iivec = [];
% seek grid shift
% tic
for k1 = 1:8
    for k2 = 1:8
        if (k1 > 1 || k2 > 1)
            sig = sqrt(getQ2_ast(1,1,k1,k2,qtable) + varE);
            DCpoly = DC(k1:8:end,k2:8:end);
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
            DCcal = DC(k1cal:8:end,k2cal:8:end);
            hcal = hist(DCcal(:),binHist);
            hcalnorm = (hcal+1)/(numel(DCcal)+numel(binHist));
            
            % define mixture components
            p0 = @(x) hcalnorm(round(x) + center + 1);
            p1 = @(x,Q) h1period(x, Q, hcal, binHist, center, bias, sig);
        %     p1 = @(x,Q) exp(LLR(x, binHist, Q, 0, 2^11, sig)) .* p0(x);

            [Q, alpha, L, ii] = EMperiod(DCpoly(:), minQ(1,1), maxQ(1,1), 0.95, p0, p1, 5, 20);
    
%             alphavec = [alphavec alpha];
%             Lvec = [Lvec L];
%             iivec = [iivec ii];
            
            if L > Lmax
                % simplified model
                nz = sum(DCpoly(:) ~= 0)/numel(DCpoly);
%                 nz = 0;
                LLRmap_s(:,:,1) = LLR(DCpoly, binHist, nz, Q, round(bias), center, sig);
                % standard model
                ppu = log(p1(binHist, Q)./p0(binHist));
%                 ppu(center + 1 + round(bias)) = 0;
                LLRmap(:,:,1) = ppu(round(DCpoly) + center + 1);
                %
                q1table(1,1) = Q;
                alphatable(1,1) = alpha;
                k1e = k1;
                k2e = k2;
                Lmax = L;
            end
        end
    end
end
% toc

% figure, plot(1:63, alphavec, 1:63, Lvec/min(Lvec))
% figure, plot(iivec)
% pause

for index = 2:c2
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
    ACpoly = AC(k1e:8:end,k2e:8:end);
    % choose shift for estimating unquantized distribution through
    % calibration
    if k1e < 5
        k1cal = k1e + 1;
    else
        k1cal = k1e - 1;
    end
    if k2e < 5
        k2cal = k2e + 1;
    else
        k2cal = k2e - 1;
    end
    ACcal = AC(k1cal:8:end,k2cal:8:end);
    hcal = hist(ACcal(:),binHist);
    hcalnorm = (hcal+1)/(numel(ACcal)+numel(binHist));            
    
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
    sig = sqrt(getQ2_ast(ic1,ic2,k1e,k2e,qtable) + varE);
%     sig = sqrt(qtable(ic1,ic2)^2 / 12 + varE);
    
    % define mixture components
    p0 = @(x) hcalnorm(round(x) + center + 1);
    p1 = @(x,Q) h1period(x, Q, hcal, binHist, center, bias, sig);
%     p1 = @(x,Q) exp(LLR(x, binHist, Q, 0, 2^11, sig)) .* p0(x);
   
    [Q, alpha] = EMperiod(ACpoly(:), minQ(ic1,ic2), maxQ(ic1,ic2), 0.95, p0, p1, 5, 20);
    q1table(ic1,ic2) = Q;
    alphatable(ic1,ic2) = alpha;
    
    % simplified model
    nz = sum(ACpoly(:) ~= 0)/numel(ACpoly);
%     nz = 0;
    LLRmap_s(:,:,index) = LLR(ACpoly, binHist, nz, Q, round(bias), center, sig);
    % standard model
    ppu = log(p1(binHist, Q)./p0(binHist));
%     ppu(center + 1) = 0;
    LLRmap(:,:,index) = ppu(round(ACpoly) + center + 1);
    %
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