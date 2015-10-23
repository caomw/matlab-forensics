function [L] = LLR(x, binHist, nz, Q, phase, center, sig)

w = ceil(3*sig);
k = -w:w;
g = exp(-k.^2/sig^2/2);
g = g/sum(g);
N = numel(x) / numel(binHist);

bppm = zeros(size(binHist));
bppm(center + 1 + phase:Q:end) = Q;
bppm(center + 1 + phase:-Q:1) = Q;
bppm = conv(g, bppm);
bppm = bppm(w+1:end-w);
bppm = (bppm*N + 1);
LLRmap = log(bppm / mean(bppm));
% LLRmap(center + 1) = 0;
LLRmap(center + 1) = nz * LLRmap(center + 1);
L = LLRmap(round(x) + center +1);

return