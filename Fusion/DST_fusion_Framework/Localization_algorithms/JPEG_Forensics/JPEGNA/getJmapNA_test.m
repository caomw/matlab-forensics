function [LLRmap, q1table] = getJmapNA_test(image,ncomp,c2,k1,k2)
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
EDC = Edct(1:8:end,1:8:end);
varE = var(EDC(:));

I = ibdct(dequantize(coeffArray, qtable));
% figure, imshow(I, [])
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

DC = conv2(I, ones(8)/8);
% DC = imfilter(I, ones(8)/8, 'circular', 'full');
DC = DC(8:end,8:end);
% hspecref = 0;
% Qmap = zeros(8,8,maxQ(1,1)-minQ(1,1)+1);

binHist = (-2^11:1:2^11-1);
periods = minQ(1,1):maxQ(1,1);
harmfreq = 1./periods;
IPDFT = exp(-2*pi*i* binHist' * harmfreq);

DCpoly = DC(k1:8:end,k2:8:end);
LLRmap = zeros(size(DCpoly));
num4Bin = hist(DCpoly(:),binHist);
num4Bin = num4Bin - mean(num4Bin);


hspec = abs(num4Bin * IPDFT);

[maxspec, ispec] = max(hspec);
Q = periods(ispec);
q1table(1,1) = Q;
phase = round(angle(num4Bin * IPDFT(:,ispec) / (2*pi) * Q));

sig = sqrt(qtable(1,1)^2 / 12 + varE);
w = ceil(3*sig);
p = -w:w;
g = exp(-p.^2/sig^2/2);

% figure, plot(periods, hspec)
% figure, plot(binHist, num4Bin, p, g * num4Bin(2^11 + 1)), title(['DC, Q = ', num2str(Q), '; phase = ', num2str(phase)])
% pause
g = g/sum(g);
% epsilon = 1 / (numel(binHist)+2);
N = numel(DCpoly) / numel(binHist);

bppm = zeros(size(binHist));
bppm(2^11 + 1 + phase:Q:end) = Q;
bppm(2^11 + 1 + phase:-Q:1) = Q;
bppm = conv(g, bppm);
bppm = bppm(w+1:end-w);
bppm = (bppm*N + 1) / (N+2);
% figure, plot(binHist, bppm), pause
LLR = log(bppm / mean(bppm));
LLRmap = LLR(round(DCpoly) + 2^11 + 1);
% nmap = 1 - map;

% figure, imagesc(1./(1 + exp(-LLRmap)), [0 1])
% pause

for index = 2:c2
% 
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    
    AC0 = coeffArray(ic1:8:end,ic2:8:end);
    S = sum(abs(AC0(:)));
    N = numel(AC0);
    N0 = sum(AC0(:) == 0);
    N1 = N - N0;
    Q = qtable(ic1,ic2);
    gam = (-N0*Q + sqrt(N0^2*Q^2 - (2*N1*Q - 4*Q*S)*(2*N*Q + 4*Q*S)))/(2*N*Q + 4*Q*S);
    lambda = -2*log(gam)/Q;
    
    A = zeros(8);
    A(ic1,ic2) = 1;
    B = idct2(A);
    
    AC = conv2(I, B);
%     AC = imfilter(I, B, 'circular', 'full');
    AC = AC(8:end,8:end);
    
    ACpoly = AC(k1:8:end,k2:8:end);
    num4Bin = hist(ACpoly(:),binHist);
    num4Bin0 = hist(AC0(:),binHist);
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
%     hcalnorm = (hcal+1)/(numel(ACcal)+numel(binHist));
    
%     num4Bin = num4Bin - mean(num4Bin);
    
%     Lfun_min = inf;
%     Q = 1;
%     Lvec = [];
%     for periods = minQ(ic1,ic2):maxQ(ic1,ic2)
%         Lfun = sum((mod(ACpoly(:)/periods-1/2, 1)-1/2).^2);
%         Lvec = [Lvec Lfun];
%         if Lfun < Lfun_min
%             Q = periods;
%             Lfun_min = Lfun;
%         end
%     end
%     figure, plot(minQ(ic1,ic2):maxQ(ic1,ic2), Lvec)
%     phase = 0;
    
%     mu = expfit(abs(ACpoly(:)));
%     pdf = exp(-abs(binHist)/mu)/mu/2 * numel(ACpoly);

%     sig = sqrt(qtable(ic1,ic2)^2 / 12 + 1/12);
%     w = ceil(3*sig);
%     x = -w:w;
%     g = exp(-x.^2/sig^2/2);

%     modelFun =  @(p,x) p(2) * exp(-abs(x) / p(1));
%     modelFun =  @(p,x) expconvnorm(p,x);
%     modelFun = @(p,x) p(2) ./ (x.^2 + p(1)^2);
%     startingVals = [1 num4Bin(2^11+1)];
%     coefEsts = nlinfit(binHist, num4Bin, modelFun, startingVals);

%     figure, plot(binHist, num4Bin, binHist, num4Bin0, binHist, N*exp(-abs(binHist)*lambda)*sinh(lambda*Q/2)/Q)
    sig = sqrt(qtable(ic1,ic2)^2 / 12 + varE);

    periods = minQ(ic1,ic2):maxQ(ic1,ic2);
    
%     p0 = @(x) hcalnorm(round(x) + 2^11 + 1);
%     p1 = @(x,Q) h1period(x, Q, hcal, binHist, 2^11, sig);
%     
%     [Q, alpha] = EMperiod(ACpoly(:), minQ(ic1,ic2), maxQ(ic1,ic2), 0.5, p0, p1);
% %     [Q, alpha] = EMperiod(ACpoly(:), 6, minQ(ic1,ic2), maxQ(ic1,ic2), 0.5, p0, p1);
    
   
    harmfreq = 1./periods;
    IPDFT = exp(-2*pi*i* binHist' * harmfreq);
    expspec = sum(num4Bin) * lambda^2 ./ (lambda^2 + (2*pi*harmfreq).^2);
%     expspec2 = sum(num4Bin) * lambda^2 * exp(-(2*pi*harmfreq*sig).^2) ./
%     (lambda^2 + (2*pi*harmfreq).^2);
% 
%     hspec = abs(num4Bin * IPDFT - expspec);
    hspec = abs(num4Bin * IPDFT) - abs(hcal * IPDFT);
%     figure, plot(periods, hspec)
%     num4Bin = num4Bin - modelFun(coefEsts,binHist);
    
    w = ceil(3*sig);
    x = -w:w;
    g = exp(-x.^2/sig^2/2);
%     IPDFTg = exp(-2*pi*i* x' * harmfreq);
%     
%     ws = ceil(3*qtable(ic1,ic2));
%     xs = -ws:ws;
%     hSmooth = exp(-(xs/qtable(ic1,ic2)).^2/2);
%     hSmooth = hSmooth/sum(hSmooth);
%     
%     modelSmooth = conv(num4Bin, hSmooth);
%     modelSmooth = modelSmooth(ws+1:end-ws);
%     num4Bin2 = num4Bin - modelSmooth;
%     expspec = num4Bin2(2^11+1) * abs(g * IPDFTg);
% %     num4Bin3 = num4Bin2;
% %     num4Bin3(2^11+1-w:2^11+1+w) = num4Bin3(2^11+1-w:2^11+1+w) - g*num4Bin3(2^11+1);
%     
% %     mean(num4Bin2)
% %     num4Bin2 = num4Bin2 - mean(num4Bin2);
% %     mean(num4Bin2)
%     hspec = abs(num4Bin2 * IPDFT) - expspec;
% %     hspec = abs((num4Bin - modelFun(coefEsts,binHist)) * IPDFT);
    [maxspec, ispec] = max(hspec);
    Q = periods(ispec);
    q1table(ic1,ic2) = Q;
%     phase = round(angle(num4Bin2 * IPDFT(:,ispec) / (2*pi) * Q));
    phase = 0;
    
%     figure, plot(periods, abs(num4Bin * IPDFT))
%     pause
%     figure, plot(periods, expspec)
%     pause
%     figure, plot(periods, expspec2)
%     pause
% %     figure, plot(periods, abs(mean(num4Bin)*ones(size(num4Bin)) * IPDFT))
% %     figure, plot(periods, hspec), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
% %     figure, plot(periods, abs((num4Bin - mean(num4Bin)) * IPDFT))  
% %     figure, plot(periods, abs(num4Bin2 * IPDFT))
%     figure, plot(periods, abs(num4Bin * IPDFT), periods, expspec, periods, hspec, periods, abs((num4Bin - hcal) * IPDFT))
%     pause
%     pause
%     figure, plot(periods, abs(num4Bin * IPDFT - expspec2))
%     pause
%     figure, plot(binHist, num4Bin,  binHist, modelFun(coefEsts,binHist)), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
%     figure, plot(binHist, num4Bin - modelFun(coefEsts,binHist), x, g * (num4Bin(2^11+1) - modelFun(coefEsts,0))), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
%     pause
%     figure, plot(binHist, num4Bin, x, g * num4Bin2(2^11+1),  binHist, modelSmooth), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
%     figure, plot(binHist, num4Bin2), title(['AC(' num2str(coe) '), Q = ',
%     num2str(Q), '; phase = ', num2str(phase)])
       
    g = g/sum(g);
    N = numel(ACpoly) / numel(binHist);

    bppm = zeros(size(binHist));
    bppm(2^11 + 1 + phase:Q:end) = Q;
    bppm(2^11 + 1 + phase:-Q:1) = Q;
    bppm = conv(g, bppm);
    bppm = bppm(w+1:end-w);
    bppm = (bppm*N + 1) / (N + 2);
%     figure, plot(binHist, bppm), pause
    LLR = log(bppm / mean(bppm));
%     LLR(2^11 + 1) = 0;
    LLRtmp = LLR(round(ACpoly) + 2^11 + 1);
    
    LLRmap = LLRmap + LLRtmp;
%     figure, imagesc(1./(1+exp(-LLRmap)), [0 1])
%     pause

end

% map = map ./ (map + nmap);
% 
% map = medfilt2(map, [5 5], 'symmetric');
% figure, imagesc(1./(1+exp(-LLRmap)), [0 1])

% N = 7;
% w = fspecial('gaussian', [N N], N/6);
% smooth LLRmap
refmask = true(128);
refmask(49:80,49:80) = false;

LLRmap = imfilter(LLRmap, ones(3), 'symmetric', 'full');
% figure, imagesc(LLRmap, [-40 40])
% [FP, TP] = computeROC(LLRmap, refmask, 1000);
% figure, plot(FP/(32^2),TP/(128^2-32^2))
% trapz(FP/(32^2),TP/(128^2-32^2))

LLRmap_big = zeros(8*size(LLRmap));
LLRmap_big(1:8:end,1:8:end) = LLRmap;
bil = conv2(ones(8), ones(8))/64;
LLRmap_big = imfilter(LLRmap_big, bil, 'full');
LLRmap = LLRmap_big(16-k1:8:end-16-k1,16-k2:8:end-16-k2);
% map = 1./(1+exp(-LLRmap));
% figure, imagesc(map, [0 1])
figure, imagesc(LLRmap, [-40 40]), axis square
figure, imshow(~refmask)
figure, imshow(LLRmap > 0)
figure, imagesc(2*(LLRmap > 0)+refmask), axis square
% figure, hist(LLRmap(:), 1000)

% [FP, TP] = computeROC(LLRmap, refmask, 1000);
% figure, plot(FP/(32^2),TP/(128^2-32^2))
% trapz(FP/(32^2),TP/(128^2-32^2))

q1table

return