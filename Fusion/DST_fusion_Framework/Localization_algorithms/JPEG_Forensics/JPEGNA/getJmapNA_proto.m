function [] = getJmapNA(image,ncomp,c2)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block

coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
minQ = max(2, floor(qtable/sqrt(3)));

I = ibdct(dequantize(coeffArray, qtable));
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);
spec = 0;
spec2 = 0;
hspecref = 0;
k1p1 = 0;
k2p1 = 0;
Qp1 = 0;
k1p2 = 0;
k2p2 = 0;
Qp2 = 0;

Qmap = zeros(8,8,17-minQ(1,1));

for k1 = 1:8
    for k2 = 1:8
        DCpoly = DC(k1:8:end,k2:8:end);
        
        binHist = (-2^11:1:2^11-1);
        num4Bin = hist(DCpoly(:),binHist);
        
        periods = minQ(1,1):16;
        harmfreq = 1./periods;
        IPDFT = exp(-2*pi*i* binHist' * harmfreq);

        % hspec = abs(fft(num4Bin));
        hspec = abs(num4Bin * IPDFT);
        if k1 == 1 && k2 == 1
%             plot(periods, hspec), title(['k1 = ', num2str(k1-1), '; k2 = ', num2str(k2-1)])
%             figure
            hspecref = hspec;
        end
        if qtable(1,1) > 1
            Qmap(k1,k2,:) = hspec / hspecref(periods == qtable(1,1));
        else
            Qmap(k1,k2,:) = hspec / sum(num4Bin);
        end
%         hspec = [hspec(end-48:end), hspec, hspec(1:49)];
%         hmax = ordfilt2(hspec,49,true(1,49));
%         hspec(hspec < hmax) = 0;
%         hspec = hspec(50:end-49);
%         hspec(1) = 0;
        hspec2 = hspec;
        hspec2(hspec <= hspecref) = 0;
       
        [maxspec, ispec] = max(hspec);
        [maxspec2, ispec2] = max(hspec2);

        if maxspec > spec && (k1 > 1 || k2 > 1)
            spec = maxspec;
            k1p1 = k1;
            k2p1 = k2;
            Qp1 = periods(ispec);
%             plot(periods, hspec), title(['k1 = ', num2str(k1-1), '; k2 = ', num2str(k2-1)])
%             pause
        end
        if maxspec2 > spec2 
            spec2 = maxspec2;
            k1p2 = k1;
            k2p2 = k2;
            Qp2 = periods(ispec2);
%             plot(periods, hspec2), title(['k1 = ', num2str(k1-1), '; k2 = ', num2str(k2-1)])
%             pause
        end
%         if k1 ==3 && k2 == 3
%             plot(periods, hspec), title(['k1 = ', num2str(k1-1), '; k2 = ', num2str(k2-1)])
%             figure, plot(periods, hspec2), title(['k1 = ', num2str(k1-1), '; k2 = ', num2str(k2-1)])
%             pause
%         end 
    end
end

for k = 1:length(periods)
    Qmaptmp = Qmap(:,:,k);
    minH = min(-log2(Qmaptmp(:)/sum(Qmaptmp(:))));
    figure, imagesc(Qmaptmp, [0 1]), title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
    if periods(k) == qtable(1,1)
%         Qmaptmp = Qmaptmp * diag(1./sum(Qmaptmp,1));
%         Qmaptmp = diag(1./sum(Qmaptmp,2)) * Qmaptmp;
        Qmaptmp2(2:4,2:4) = Qmaptmp(2:4,2:4) - (Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(2:4,8:-1:6) = Qmaptmp(2:4,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,2:4) = Qmaptmp(8:-1:6,2:4) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,8:-1:6) = Qmaptmp(8:-1:6,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4)) / 3;
        Qmaptmp2(1,2:4) = Qmaptmp(1,2:4) - Qmaptmp(1,8:-1:6);
        Qmaptmp2(1,8:-1:6) = Qmaptmp(1,8:-1:6) - Qmaptmp(1,2:4);
        Qmaptmp2(2:4,1) = Qmaptmp(2:4,1) - Qmaptmp(8:-1:6,1);
        Qmaptmp2(8:-1:6,1) = Qmaptmp(8:-1:6,1) - Qmaptmp(2:4,1);
        Qmaptmp2(1,5) = Qmaptmp(1,5) - (Qmaptmp(1,4) + Qmaptmp(1,4)) / 2;
        Qmaptmp2(5,1) = Qmaptmp(5,1) - (Qmaptmp(4,1) + Qmaptmp(4,1)) / 2;
        Qmaptmp2(5,5) = Qmaptmp(5,5) - (Qmaptmp(4,5) + Qmaptmp(6,5) + Qmaptmp(5,4) + Qmaptmp(5,6)) / 4;
        Qmaptmp2 = max(Qmaptmp2, 0);
        minH = min(-log2(Qmaptmp2(:)/sum(Qmaptmp2(:))));
        figure, imagesc(Qmaptmp2), title(['Q = ', num2str(periods(k)), '; minH = ', num2str(minH)])
    end
    pause
end

k1p1-1
k2p1-1
Qp1
k1p2-1
k2p2-1
Qp2
spec2 / spec

binHist = (-2^11:1:2^11-1);
% DCref = DC(1:8:end,1:8:end);
if spec2 / spec > 0.15
    k1 = k1p2;
    k2 = k2p2;
    Q = Qp2;
else
    k1 = k1p1;
    k2 = k2p1;
    Q = Qp1;
end

DCpoly = DC(k1:8:end,k2:8:end);
num4Bin = hist(DCpoly(:),binHist);

periods = minQ(1,1):16;
harmfreq = 1./periods;
IPDFT = exp(-2*pi*i* binHist' * harmfreq);
hspec = abs(num4Bin * IPDFT);

IPDFTQ = exp(-2*pi*i* binHist' / Q);
phase = round(angle(num4Bin * IPDFTQ) / (2*pi) * Q);

% bppm = zeros(size(num4Bin));
% bppm(mod(num4Bin - phase, Qp2) == 0) = 1;
% bppm = 0.5 + 0.49 * cos(2*pi*(binHist - phase) / Q);

sig = sqrt(qtable(1,1)^2 / 12 + 2/3);
w = ceil(3*sig);
p = -w:w;
g = exp(-p.^2/sig^2/2);

if spec2 / spec > 0.15
    hspec(hspec <= hspecref) = 0;
end
figure, plot(periods, hspec)
figure, plot(binHist, num4Bin, p, g * num4Bin(2^11 + 1)), title(['DC, Q = ', num2str(Q), '; phase = ', num2str(phase)])
pause
g = g/sum(g);
epsilon = 0.01;

bppm = epsilon * ones(size(binHist));
bppm(2^11 + 1 + phase:Q:end) = Q*(1 - epsilon);
bppm(2^11 + 1 + phase:-Q:1) = Q*(1 - epsilon);
bppm = conv(g, bppm);
bppm = bppm(w+1:end-w);
% figure, plot(binHist, bppm), pause
bppm = bppm ./ (bppm + mean(bppm));
map = bppm(round(DCpoly) + 2^11 + 1);
nmap = 1 - map;

% figure, imagesc(map, [0 1])
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
    B = ibdct(A);
    
    AC = conv2(I, B);
    AC = AC(8:end,8:end);
    
    ACpoly = AC(k1:8:end,k2:8:end);
    
    binHist = (-2^11:1:2^11-1);
    num4Bin = hist(ACpoly(:),binHist);
    
%     mu = expfit(abs(ACpoly(:)));
%     pdf = exp(-abs(binHist)/mu)/mu/2 * numel(ACpoly);

    modelFun =  @(p,x) p(2) * exp(-abs(x) / p(1));
    startingVals = [1 num4Bin(2^11+1)];
    coefEsts = nlinfit(binHist, num4Bin, modelFun, startingVals);
    
    periods = minQ(ic1,ic2):16;
    harmfreq = 1./periods;
    IPDFT = exp(-2*pi*i* binHist' * harmfreq);
    expspec = 2 * coefEsts(1) * coefEsts(2) ./ (1 + (coefEsts(1) * 2*pi*harmfreq).^2);

    % hspec = abs(fft(num4Bin));
    hspec = abs(num4Bin * IPDFT) - expspec;
    [maxspec, ispec] = max(hspec);
    Q = periods(ispec);
    phase = round(angle(num4Bin * IPDFT(:,ispec) / (2*pi) * Q));
    
    figure, plot(periods, abs(num4Bin * IPDFT))
    figure, plot(periods, expspec)
%     bppm = 0.5 + 0.49 * cos(2*pi*(binHist - phase) / Q);

    sig = sqrt(qtable(ic1,ic2)^2 / 12 + 2/3);
    w = ceil(3*sig);
    p = -w:w;
    g = exp(-p.^2/sig^2/2);
    figure, plot(periods, hspec)
    figure, plot(binHist, num4Bin, p, g * num4Bin(2^11+1)), title(['AC(' num2str(coe) '), Q = ', num2str(Q), '; phase = ', num2str(phase)])
    pause
    
    g = g/sum(g);
    epsilon = 0.01;

    bppm = epsilon * ones(size(binHist));
    bppm(2^11 + 1 + phase:Q:end) = Q*(1 - epsilon);
    bppm(2^11 + 1 + phase:-Q:1) = Q*(1 - epsilon);
    bppm = conv(g, bppm);
    bppm = bppm(w+1:end-w);
%     figure, plot(binHist, bppm), pause
    bppm = bppm ./ (bppm + mean(bppm));
    bppm(2^11 + 1) = 0.5;
    maptmp = bppm(round(ACpoly) + 2^11 + 1);
    
    if index ~= 4
        map = map .* maptmp;
        nmap = nmap .* (1 - maptmp);
    end
    
%     figure, imagesc(maptmp, [0 1])
%     pause

end

% map = map ./ (map + nmap);
% 
% map = medfilt2(map, [5 5], 'symmetric');
% figure, imagesc(map, [0 1])

LLRmap = log(map./nmap);
N = 7;
% w = fspecial('gaussian', [N N], N/6);
LLRmap = imfilter(LLRmap, ones(15));
figure, imagesc(1./(1+exp(-LLRmap)), [0 1])


return