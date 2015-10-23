function [maskTampered,q1table] = getJmap_old(image,ncomp,c1,c2)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block


coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};

% simulate coefficients without DQ effect
I = ibdct(dequantize(coeffArray, qtable));
coeffArrayS = bdct(I(2:end,2:end,1));

sizeCA = size(coeffArray);
sizeCAS = size(coeffArrayS);
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
coeffFreq = zeros(1, numel(coeffArray)/64);
coeffSmooth = zeros(1, numel(coeffArrayS)/64);

bppm = 0.5 * ones(1, numel(coeffArray)/64);
bppmTampered = 0.5 * ones(1, numel(coeffArray)/64);

q1table = 99*ones(size(qtable));

% gaussian kernel for histogram smoothing
sig = 0.5;
f = ceil(6*sig);
p = -f:f;
g = exp(-p.^2/sig^2/2);
g = g/sum(g);

for index = c1:c2
    coe = coeff(index);
    % load DCT coefficients at position index
    k = 1;
    start = mod(coe,8); 
    if start == 0
        start = 8;
    end
    for l = start:8:sizeCA(2)
        for i = ceil(coe/8):8:sizeCA(1)
            coeffFreq(k) = coeffArray(i,l);
            k = k+1;
        end
    end
    k = 1;
    for l = start:8:sizeCAS(2)
        for i = ceil(coe/8):8:sizeCAS(1)
            coeffSmooth(k) = coeffArrayS(i,l);
            k = k+1;
        end
    end

    % get histogram of DCT coefficients
    binHist = (-2^11:1:2^11-1);
    num4Bin = hist(coeffFreq,binHist);
    
    % get histogram of DCT coeffs w/o DQ effect (prior model for
    % uncompressed image)
    Q2 = qtable(floor((coe-1)/8)+1,mod(coe-1,8)+1);
    hsmooth = hist(coeffSmooth,binHist*Q2);
    
    lidx = binHist ~= 0;
    hweight = 0.5 * ones(1, 2^12);
%     hweight = 1./(hsmooth + 1);
    E = inf;
    Q1est = 1;
    
    % estimate Q-factor of first compression
    for Q1 = 1:99
        % nhist * hsmooth = prior model for doubly compressed coefficient
        nhist = Q1/Q2 * (floor((Q2/Q1)*(binHist + 0.5)) - ceil((Q2/Q1)*(binHist - 0.5)) + 1);
%         nhist = conv(g, nhist);
%         nhist = nhist(f+1:end-f);
        diff = hweight .* abs(num4Bin - nhist .* hsmooth);
        Etmp(Q1) = sum(diff(lidx));
        if Etmp(Q1) < E
            E = Etmp(Q1);
            Q1est = Q1;
        end
    end

%     figure, plot(Etmp), title(['index = ' num2str(index) '; Q1 = ' num2str(Q1est) '; Q2 = ' num2str(Q2)])
%     figure, plot(binHist, num4Bin), title(['index = ' num2str(index) '; Q1 = ' num2str(Q1est) '; Q2 = ' num2str(Q2)])
        
    q1table(floor((coe-1)/8)+1,mod(coe-1,8)+1) = Q1est;
    % compute probabilities if DQ effect is present
    if mod(Q2,Q1est) > 0
        % index
        nhist = Q1est/Q2 * (floor((Q2/Q1est)*(binHist + 0.5)) - ceil((Q2/Q1est)*(binHist - 0.5)) + 1);
        % histogram smoothing (avoids false alarms)
        nhist = conv(g, nhist);
        nhist = nhist(f+1:end-f);
        
        ppu = nhist ./ (nhist + mean(nhist));
        ppt = mean(nhist) ./ (nhist + mean(nhist));
        % set zeroed coefficients as non-informative
        ppu(2^11 + 1) = 0.5;
        ppt(2^11 + 1) = 0.5;
        
        bppm = bppm .* ppu(coeffFreq + 2^11 + 1);
        bppmTampered = bppmTampered .* ppt(coeffFreq + 2^11 + 1);
        
%         maskTampered = bppmTampered ./ (bppm + bppmTampered);
%         maskTampered = reshape(maskTampered,sizeCA(1)/8,sizeCA(2)/8);
%         figure, imagesc(maskTampered), colorbar
%         figure, plot(binHist, num4Bin, binHist, nhist .* hsmooth, binHist, hsmooth)
    end
end

maskTampered = bppmTampered ./ (bppm + bppmTampered);
maskTampered = reshape(maskTampered,sizeCA(1)/8,sizeCA(2)/8);

% figure, imagesc(maskTampered), colorbar
% 
% qtable
% q1table

return