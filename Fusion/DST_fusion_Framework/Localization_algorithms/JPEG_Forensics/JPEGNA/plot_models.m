
filename = 'test/DPP8_TIFF0383_Q65_Q85.jpg';
filenameSQ = 'test/DPP8_TIFF0383_Q85.jpg';
QF1 = 65;
c2 = 10;
ncomp = 1;
k1 = 4;
k2 = 4;


image = jpeg_read(filename);
imageSQ = jpeg_read(filenameSQ);
q1table = jpeg_qtable(QF1);


coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
coeffArraySQ = imageSQ.coef_arrays{ncomp};
qtableSQ = imageSQ.quant_tables{image.comp_info(ncomp).quant_tbl_no};


% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
% EDC = Edct(1:8:end,1:8:end);
% biasE = mean(EDC(:));
% varE = var(EDC(:));

I = ibdct(dequantize(coeffArray, qtable));
ISQ = ibdct(dequantize(coeffArraySQ, qtableSQ));
% figure, imshow(I, [])
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
binHist = (-2^11:1:2^11-1);
center = 2^11;

% DC = conv2(I, ones(8)/8);
% % DC = imfilter(I, ones(8)/8, 'circular', 'full');
% DC = DC(8:end,8:end);
% DCpoly = DC(k1:8:end,k2:8:end);
% num4Bin = hist(DCpoly(:),binHist);
% num4Bin = num4Bin - mean(num4Bin);
% 
% periods = minQ(1,1):16;
% harmfreq = 1./periods;
% IPDFT = exp(-2*pi*i* binHist' * harmfreq);
% hspec = abs(num4Bin * IPDFT);
% 
% [maxspec, ispec] = max(hspec);
% Q = periods(ispec);
% q1table(1,1) = Q;
% phase = round(angle(num4Bin * IPDFT(:,ispec) / (2*pi) * Q));
% 
% sig = sqrt(qtable(1,1)^2 / 12 + varE);
% 
% LLRmap(:,:,1) = LLR(DCpoly, binHist, Q, phase, 2^11, sig);

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
    
    ACSQ = conv2(ISQ, B);
%     AC = imfilter(I, B, 'circular', 'full');
    ACSQ = ACSQ(8:end,8:end);
    ACSQpoly = ACSQ(k1:8:end,k2:8:end);
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

    Q1 = q1table(ic1,ic2);
    
    % models
    pQ = p1(binHist, Q1);
    pNQ = p0(binHist);
    pQ_S = exp(LLR(binHist, binHist, 0, Q1, round(bias), 2^11, sig)) .* pNQ;
    
    % original histograms
    hQ = hist(ACpoly(:), binHist) / numel(ACpoly);
    hNQ = hist(ACSQpoly(:), binHist) / numel(ACSQpoly);
    
    
    plot(binHist, hQ, 'k+:', binHist, pQ, 'r-', binHist, pQ_S, 'm-.', binHist, hNQ, 'bx:', binHist, pNQ, 'g--','LineWidth',1)
    grid
    axis([-24 24 -0.005 0.1])
    xlabel('unquantized DCT coefficient value')
    ylabel('frequency')
    legend('h_{Q}', 'p_{Q}', 'p_{Q} simplified', 'h_{NQ}', 'p_{NQ}')
    pause
        
end