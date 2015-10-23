function [FP, TP] = computeROC(pmask, refmask, N)

th = 1:-1/(N-2):-1/(N-2);
FP = zeros(1,N); % false positives
TP = zeros(1,N); % true positives

for k = 1:N
    tmpmask = pmask > th(k);
    TP(k) = sum(sum(tmpmask & refmask));
    FP(k) = sum(sum(tmpmask & ~refmask));
end

return