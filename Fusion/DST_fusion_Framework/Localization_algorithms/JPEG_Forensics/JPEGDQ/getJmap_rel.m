function [maskTampered, q1table, alphatable, msetable, nztable, reltable] = getJmap_rel(image,ncomp,c1,c2)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block

coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};

% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
% E0 = Edct(1:8:end,1:8:end);
% E0 = reshape(E0,1,numel(E0));
% bias = mean(E0)
% varE0 = var(E0)
Edct2 = reshape(Edct,1,numel(Edct));
varE = var(Edct2);

relfun = @(p,xdata)p(4) * exp(-(abs(xdata - p(1))/p(2)).^p(3));
crel = [0.845848252910510   0.328662041516073   1.232925504404717   0.823743768504003];

% simulate coefficients without DQ effect
Y = ibdct(dequantize(coeffArray, qtable));
coeffArrayS = bdct(Y(2:end,2:end,1));

sizeCA = size(coeffArray);
sizeCAS = size(coeffArrayS);
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
coeffFreq = zeros(1, numel(coeffArray)/64);
coeffSmooth = zeros(1, numel(coeffArrayS)/64);
errFreq = zeros(1, numel(Edct)/64);

bppm = 0.5 * ones(1, numel(coeffArray)/64);
bppmTampered = 0.5 * ones(1, numel(coeffArray)/64);

q1table = 100 * ones(size(qtable));
alphatable = ones(size(qtable));
msetable = zeros(size(qtable));
nztable = zeros(size(qtable));
reltable = zeros(size(qtable));
Q1up = [20*ones(1,10) 30*ones(1,5) 40*ones(1,6) 64*ones(1,7) 80*ones(1,8), 99*ones(1,28)];

% kernel for histogram smoothing
% std of quantization noise on DCT of Y
% sig = 6 / Q2;
% w = ceil(5*sig);
% p = -w:w;
% g = exp(-p.^2/sig^2/2);
% g = g/sum(g);

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
            errFreq(k) = Edct(i,l);
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
    
    % get estimate of rounding/truncation error
    biasE = mean(errFreq);
    % varE = var(errFreq);
    
    sig = sqrt(varE) / Q2;
    f = ceil(6*sig);
    p = -f:f;
    g = exp(-p.^2/sig^2/2);
    g = g/sum(g);
%     ker = conv(g, ones(1,Q2));
%     kercenter = ceil(length(ker)/2);
%     f = floor(kercenter/Q2);
%     ker = ker(mod(kercenter,Q2):Q2:end);
    
    lidx = binHist ~= 0;
    hweight = ones(1, 2^12);
%     hweight = 1./(hsmooth + 1);
    E = inf;
    Etmp = inf(1,99);
    alphaest = 1;
    Q1est = 1;
    biasest = 0;
    
    if index == 1
        %bias = -3:3;
        bias = biasE;
    else
        bias = 0;
    end
    
    % estimate Q-factor of first compression
    for Q1 = 1:Q1up(index)
        for b = bias
            alpha = 1;
            if mod(Q2, Q1) == 0
                diff = (hweight .* (hsmooth - num4Bin)).^2;
            else
                % nhist * hsmooth = prior model for doubly compressed coefficient
                nhist = Q1/Q2 * (floor2((Q2/Q1)*(binHist + b/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + b/Q2 - 0.5)) + 1);
    %             nhist = conv(ker, nhist);
    %             nhist = nhist(f+1:end-f);
                nhist = conv(g, nhist);
                nhist = nhist(f+1:end-f);
                a1 = hweight .* (nhist .* hsmooth - hsmooth);
                a2 = hweight .* (hsmooth - num4Bin);
                % exclude zero bin from fitting
                alpha = -(a1(lidx) * a2(lidx)') / (a1(lidx) * a1(lidx)');
                alpha = min(alpha, 1.25);
                alpha = max(alpha, 0.25);
    %             diff = hweight .* abs(num4Bin - nhist .* hsmooth);
                diff = (hweight .* (alpha * a1 + a2)).^2;
            end
            KLD = sum(diff(lidx));
            if KLD < E % && alpha > 0.25 && alpha < 1.25
                E = KLD;
                Q1est = Q1;
                alphaest = alpha;
            end
            if KLD < Etmp(Q1)
                Etmp(Q1) = KLD;
                biasest = b;
            end
        end
    end
  
%     figure, plot(Etmp)
%     title(['index = ' num2str(index) '; Q1 = ' num2str(Q1est) '; Q2 = ' num2str(Q2)])
%     figure, plot(binHist, num4Bin, binHist, hsmooth) 
%     title(['index = ' num2str(index) '; Q1 = ' num2str(Q1est) '; Q2 = ' num2str(Q2)])
%     pause
    Q1 = Q1est;
    nhist = Q1/Q2 * (floor2((Q2/Q1)*(binHist + biasest/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + biasest/Q2 - 0.5)) + 1);
%     nhist = conv(ker, nhist);
%     nhist = nhist(f+1:end-f);
    nhist = conv(g, nhist);
    nhist = nhist(f+1:end-f);
%     nhist = alpha * nhist + 1 - alpha;
        
%     ppt = mean(nhist) ./ (nhist + mean(nhist));
%     figure, plot(binHist, num4Bin, binHist, alphaest * hsmooth .* nhist + (1 - alphaest) * hsmooth) 
%     title(['index = ' num2str(index) '; Q1 = ' num2str(Q1) '; Q2 = ' num2str(Q2) '; alpha = ' num2str(alphaest)])
%     pause

%     figure, plot(binHist, hsmooth .* nhist,'r',binHist, hsmooth,'b')
%     xlabel('DCT value')
%     ylabel('occurencies')
%     axis([-60 60 0 max(hsmooth .* nhist)])
%     figure, plot(binHist, ppt)
%     xlabel('DCT value')
%     ylabel('P_{TAMP}')
%     axis([-60 60 0 1])
%     pause
    
    alpha = alphaest;
    q1table(floor((coe-1)/8)+1,mod(coe-1,8)+1) = Q1est;
    alphatable(floor((coe-1)/8)+1,mod(coe-1,8)+1) = alpha;
    msetable(floor((coe-1)/8)+1,mod(coe-1,8)+1) = E / sum(num4Bin(lidx).^2);
    nz = sum(num4Bin(lidx)) / numel(coeffFreq);
    nztable(floor((coe-1)/8)+1,mod(coe-1,8)+1) = nz;
    % compute probabilities if DQ effect is present
    if mod(Q2,Q1est) > 0
        % index
        nhist = Q1est/Q2 * (floor2((Q2/Q1est)*(binHist + biasest/Q2 + 0.5)) - ceil2((Q2/Q1est)*(binHist + biasest/Q2 - 0.5)) + 1);
        % histogram smoothing (avoids false alarms)
        nhist = conv(g, nhist);
        nhist = nhist(f+1:end-f);
        nhist = alpha * nhist + 1 - alpha;
        
        prel = nz * relfun(crel, alpha);
        punrel = (1 - nz) * (1 - relfun(crel, alpha));
        prel = prel / (prel + punrel);
        ppu = nhist ./ (nhist + mean(nhist));
        ppu = prel * ppu + 0.5*(1 - prel);
        ppt = 1 - ppu;
        % set zeroed coefficients as non-informative
        ppu(2^11 + 1) = 0.5;
        ppt(2^11 + 1) = 0.5;
        
        bppm = bppm .* ppu(coeffFreq + 2^11 + 1);
        bppmTampered = bppmTampered .* ppt(coeffFreq + 2^11 + 1);
        
        reltable(floor((coe-1)/8)+1,mod(coe-1,8)+1) = prel;
       
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