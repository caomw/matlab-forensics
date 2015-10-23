function [LLRmap, q1table] = getJmapNA(image,ncomp,c2,k1,k2)
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
maxQ = max(16, jpeg_qtable(50));

I = ibdct(dequantize(coeffArray, qtable));
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
binHist = (-2^11:1:2^11-1);

DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);

DCpoly = DC(k1:8:end,k2:8:end);
num4Bin = hist(DCpoly(:),binHist);
num4Bin = num4Bin - mean(num4Bin);

periods = minQ(1,1):16;
harmfreq = 1./periods;
IPDFT = exp(-2*pi*i* binHist' * harmfreq);
hspec = abs(num4Bin * IPDFT);

[maxspec, ispec] = max(hspec);
Q = periods(ispec);
q1table(1,1) = Q;
phase = round(angle(num4Bin * IPDFT(:,ispec) / (2*pi) * Q));

sig = sqrt(qtable(1,1)^2 / 12 + 1/12);
w = ceil(3*sig);
x = -w:w;
g = exp(-x.^2/sig^2/2);

figure, plot(periods, hspec)
figure, plot(binHist, num4Bin, x, g * num4Bin(2^11 + 1)), title(['DC, Q = ', num2str(Q), '; phase = ', num2str(phase)])
pause
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
figure, plot(-Q:Q, LLR(2^11+1-Q:2^11+1+Q)), pause
LLRmap = LLR(round(DCpoly) + 2^11 + 1);
% nmap = 1 - map;

figure, imagesc(LLRmap, [-40 40]/9)
pause

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
    AC = AC(8:end,8:end);
    
    ACpoly = AC(k1:8:end,k2:8:end);
    num4Bin = hist(ACpoly(:),binHist);
    
%     mu = expfit(abs(ACpoly(:)));
%     pdf = exp(-abs(binHist)/mu)/mu/2 * numel(ACpoly);

    modelFun =  @(p,x) p(2) * exp(-abs(x) / p(1));
    startingVals = [1 num4Bin(2^11+1)];
    coefEsts = nlinfit(binHist, num4Bin, modelFun, startingVals);
    
    periods = minQ(ic1,ic2):maxQ(ic1,ic2);
    harmfreq = 1./periods;
    IPDFT = exp(-2*pi*i* binHist' * harmfreq);
    expspec = 2 * coefEsts(1) * coefEsts(2) ./ (1 + (coefEsts(1) * 2*pi*harmfreq).^2);

    hspec = abs(num4Bin * IPDFT) - expspec;
    [maxspec, ispec] = max(hspec);
    Q = periods(ispec);
    q1table(ic1,ic2) = Q;
    phase = round(angle(num4Bin * IPDFT(:,ispec) / (2*pi) * Q));
    
%     figure, plot(periods, abs(num4Bin * IPDFT))
%     figure, plot(periods, expspec)

    sig = sqrt(qtable(ic1,ic2)^2 / 12 + 1/12);
    w = ceil(3*sig);
    x = -w:w;
    g = exp(-x.^2/sig^2/2);
    figure, plot(periods, hspec)
    figure, plot(binHist, num4Bin - modelFun(coefEsts,binHist), x, g * (num4Bin(2^11+1) - modelFun(coefEsts,0))), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
    pause
    
    g = g/sum(g);
    N = numel(DCpoly) / numel(binHist);

    bppm = zeros(size(binHist));
    bppm(2^11 + 1 + phase:Q:end) = Q;
    bppm(2^11 + 1 + phase:-Q:1) = Q;
    bppm = conv(g, bppm);
    bppm = bppm(w+1:end-w);
    bppm = (bppm*N + 1) / (N + 2);
%     figure, plot(binHist, bppm), pause
    LLR = log(bppm / mean(bppm));
    figure, plot(-Q:Q, LLR(2^11+1-Q:2^11+1+Q)), pause
    LLR(2^11 + 1) = 0;
    LLRtmp = LLR(round(ACpoly) + 2^11 + 1);
    
    LLRmap = LLRmap + LLRtmp;
    figure, imagesc(LLRmap, [-40 40]/9)
    pause
end

% smooth LLRmap (cumulate posterior probabilities on 3x3 neighborhood)
LLRmap = imfilter(LLRmap, ones(3), 'symmetric', 'full');
% figure, imagesc(LLRmap, [-40 40])

% interpolate LLRmap to image resolution
LLRmap_big = zeros(8*size(LLRmap));
LLRmap_big(1:8:end,1:8:end) = LLRmap;
bil = conv2(ones(8), ones(8))/64;
LLRmap_big = imfilter(LLRmap_big, bil, 'full');
% correct shift of LLRmap
LLRmap = LLRmap_big(16-k1:8:end-16-k1,16-k2:8:end-16-k2);
% map = 1./(1+exp(-LLRmap));
% figure, imagesc(map, [0 1])
figure, imagesc(LLRmap, [-40 40])
% figure, hist(LLRmap(:), 1000)

q1table

return