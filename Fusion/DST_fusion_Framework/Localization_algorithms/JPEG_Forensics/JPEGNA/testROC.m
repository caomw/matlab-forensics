test_size = [1024, 1024];
tamp_size = [256, 256];
% define mask for tampering (tamp_size)
mask = false([test_size 3]);
pt1 = floor((test_size - tamp_size)/2) + 1;
pt2 = pt1 + tamp_size - 1;
mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
mask = ~mask;

mask_block = filter2(ones(8), mask(:,:,1), 'valid');
mask_block  = mask_block(1:8:end, 1:8:end) > 32;
PNtot = sum(sum(mask_block))
NNtot = sum(sum(~mask_block))
% number of points on ROC
N = 1000;

FPtot = zeros(N,1);
TPtot = zeros(N,1);
Ntrial = 1000;

for k= 1:Ntrial
    LLRmap = 10*randn(test_size/8);
    k1 = 1;
    k2 = 1;
    while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
        k1 = floor(8*rand(1)) + 1;
        k2 = floor(8*rand(1)) + 1;
    end
    maskTampered = smooth_unshift(LLRmap,k1,k2);
    [FP, TP] = computeROC(-maskTampered, mask_block, N);
    FPtot = FPtot + FP;
    TPtot = TPtot + TP;
end

FPtot = FPtot/Ntrial/NNtot;
TPtot = TPtot/Ntrial/PNtot;

figure, plot(FPtot, TPtot), axis square
AUC = trapz(FPtot, TPtot)