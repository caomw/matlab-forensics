function [AUC] = computeAUC(pmask, refmask, N)

th = 0:1/(N-1):1;
Pfa = zeros(1,N); %x
Pd = zeros(1,N); %y

for k = 1:N
    tmpmask = pmask > th(k);
end

return