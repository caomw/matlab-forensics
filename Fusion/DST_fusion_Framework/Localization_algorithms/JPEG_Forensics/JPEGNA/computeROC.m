function [FP, TP] = computeROC(pmask, refmask, N)

th = linspace(-100, 100, N-3);
TP = [0; cumsum(histc(-pmask(refmask), [-inf th inf]))];
FP = [0; cumsum(histc(-pmask(~refmask), [-inf th inf]))];

return