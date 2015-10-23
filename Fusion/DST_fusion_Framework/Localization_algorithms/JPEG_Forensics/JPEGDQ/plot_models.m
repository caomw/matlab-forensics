
filename = 'test/DPP8_TIFF0383_Q65_Q85.jpg';
filenameSQ = 'test/DPP8_TIFF0383_Q85.jpg';
QF1 = 65;
c2 = 3;
ncomp = 1;


image = jpeg_read(filename);
imageSQ = jpeg_read(filenameSQ);
q1table = jpeg_qtable(QF1);

% addpath('../JPEGNA');
coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
coeffArraySQ = imageSQ.coef_arrays{ncomp};


% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
varE = var(Edct(:));

% simulate coefficients without DQ effect
Y = ibdct(dequantize(coeffArray, qtable));
coeffArrayS = bdct(Y(2:end,2:end,1));

coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
Q1up = [20*ones(1,10) 30*ones(1,5) 40*ones(1,6) 64*ones(1,7) 80*ones(1,8), 99*ones(1,28)];

for index = 3:c2
    
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    AC = coeffArray(ic1:8:end,ic2:8:end);
    ACSQ = coeffArraySQ(ic1:8:end,ic2:8:end);
    ACsmooth = coeffArrayS(ic1:8:end,ic2:8:end);
    EAC = Edct(ic1:8:end,ic2:8:end);
    
    Q2 = qtable(ic1,ic2);
    Q1 = q1table(ic1,ic2);
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
    
    % models
    pDQ = p1(binHist, Q1);
    pNDQ = p0(binHist);
    nDQ = Q1/Q2 * (floor2((Q2/Q1)*(binHist + bias/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + bias/Q2 - 0.5)) + 1);
    pDQ_S = nDQ .* pNDQ;
    % original histograms
    hDQ = hist(AC(:), binHist) / numel(AC);
    hNDQ = hist(ACSQ(:), binHist) / numel(ACSQ);
    
    
    plot(binHist, hDQ, 'k+:', binHist, pDQ, 'r-', binHist, pDQ_S, 'm-.', binHist, hNDQ, 'bx:', binHist, pNDQ, 'g--','LineWidth',1)
    grid
    axis([-16 16 -0.005 0.2])
    xlabel('quantized DCT coefficient value')
    ylabel('frequency')
    legend('h_{DQ}', 'p_{DQ}', 'p_{DQ} simplified', 'h_{NDQ}', 'p_{NDQ}')
        
end