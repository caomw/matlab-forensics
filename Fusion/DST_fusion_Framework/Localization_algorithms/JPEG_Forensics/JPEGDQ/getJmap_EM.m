function [LLRmap, LLRmap_s, q1table, alphatable] = getJmap_EM(image,ncomp,c2)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% LLRmap: estimated likelihood of being tampered for each 8x8 image block

% addpath('../JPEGNA');
coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
q1table = ones(8);
alphatable = ones(8);
LLRmap = zeros([size(coeffArray)/8, c2]);
LLRmap_s = zeros([size(coeffArray)/8, c2]);

% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
varE = var(Edct(:));

% simulate coefficients without DQ effect
Y = ibdct(dequantize(coeffArray, qtable));
coeffArrayS = bdct(Y(2:end,2:end,1));

coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
Q1up = jpeg_qtable(50);

for index = 1:c2
    
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    AC = coeffArray(ic1:8:end,ic2:8:end);
    ACsmooth = coeffArrayS(ic1:8:end,ic2:8:end);
    EAC = Edct(ic1:8:end,ic2:8:end);
    
    Q2 = qtable(ic1,ic2);
    center = floor(2^11/Q2);

    % get histogram of DCT coefficients
    binHist = (-center:1:center-1);
    
    % get histogram of DCT coeffs w/o DQ effect (prior model for
    % uncompressed image)
    
    hsmooth0 = hist(ACsmooth(:),-2^11:2^11-1);
    hsmooth = hist(ACsmooth(:),binHist*Q2);
    hsmoothnorm = (hsmooth+1)/(numel(ACsmooth)+numel(binHist));
    
    % get estimate of rounding/truncation error
    biasE = mean(EAC(:));
    
    sig = sqrt(varE) / Q2;
    f = ceil(6*sig);
    p = -f:f;
    g = exp(-p.^2/sig^2/2);
    g = g/sum(g);

    if index == 1
        bias = biasE;
    else
        bias = 0;
    end
    biasest = bias;
    
    % define mixture components
    p0 = @(x) hsmoothnorm(round(x) + center + 1);
    p1 = @(x,Q) h1periodDQ(x, Q, Q2, hsmooth0, -2^11:2^11-1, 2^11, bias, sig);
    
    [Q1, alpha] = EMperiod(AC(:), 1, Q1up(ic1,ic2), 0.95, p0, p1, 5, 20);
    q1table(ic1,ic2) = Q1;
    alphatable(ic1,ic2) = alpha;

    % compute probabilities if DQ effect is present
    if mod(Q2,Q1) > 0
        % simplified model
        nhist = Q1/Q2 * (floor2((Q2/Q1)*(binHist + biasest/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + biasest/Q2 - 0.5)) + 1);
        % histogram smoothing (avoids false alarms)
        nhist = conv(g, nhist);
        nhist = nhist(f+1:end-f);
        N = numel(AC) / numel(binHist);
        nhist = (nhist*N + 1);
        ppu = log(nhist./mean(nhist));
        nz = sum(AC(:) ~= 0)/numel(AC);
        ppu(center + 1) = nz * ppu(center + 1);
        LLRmap_s(:,:,index) = ppu(AC + center + 1);
        % standard model
        ppu = log(p1(binHist, Q1)./p0(binHist));
        LLRmap(:,:,index) = ppu(AC + center + 1);
    end
end

% figure, imagesc(-sum(LLRmap,3),[-10 10]), axis square
% maskTampered = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
% figure, imagesc(-maskTampered,[-90 90]), axis square
% figure, imagesc(1./(1+exp(maskTampered)),[0 1])

% 

return