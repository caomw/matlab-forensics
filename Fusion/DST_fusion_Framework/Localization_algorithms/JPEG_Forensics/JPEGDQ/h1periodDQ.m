function [p1] = h1periodDQ(x, Q1, Q2, hcal, binHist, center, bias, sig)
%
% estimate probability distribution of doubly quantized coefficient for value(s) x
%
% Q1: quantization step of first compression
% Q2: quantization step of second compression
% hcal: histogram of unquantized coefficient
% binHist: bin positions
% center: index of x = 0 in binHist
% bias: mean of quantization/truncation noise between firts and second
% compression
% sig: std of quantization/truncation noise

N = sum(hcal);
% simulate quantization using Q1
if mod(Q1,2) == 0
    hs = [0.5 ones(1,Q1-1) 0.5];
    ws = Q1/2;
else
    hs = ones(1,Q1);
    ws = (Q1-1)/2;
end
h2 = conv(hcal,hs);
% simulate dequantization
h1 = zeros(size(binHist));
h1(center + 1:Q1:end) = h2(center + 1 + ws:Q1:end-ws);
h1(center + 1:-Q1:1) = h2(center + 1 + ws:-Q1:1+ws);
% simulate rounding/truncation
w = ceil(5*sig);
k = -w:w;
g = exp(-(k+bias).^2/sig^2/2);
h1 = conv(h1, g);
h1 = h1(w+1:end-w);
% simulate quantization using Q2
if mod(Q2,2) == 0
    hs = [0.5 ones(1,Q2-1) 0.5];
    ws = Q2/2;
else
    hs = ones(1,Q2);
    ws = (Q2-1)/2;
end
h1 = conv(h1,hs);
h1 = h1(mod(center,Q2) + 1 + ws:Q2:end-ws);
% normalize probability and use Laplace correction to avoid p1 = 0
h1 = h1/sum(h1);
h1 = (h1*N+1)/(N+numel(binHist)/Q2);

p1 = h1(round(x) + floor(center/Q2) + 1);

return