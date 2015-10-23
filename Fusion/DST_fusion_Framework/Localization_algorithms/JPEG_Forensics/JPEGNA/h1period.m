function [p1] = h1period(x, Q, hcal, binHist, center, bias, sig)
%
% estimate probability distribution of quantized/dequantized coefficient for value(s) x
%
% Q: quantization step 
% hcal: histogram of unquantized coefficient
% binHist: bin positions
% center: index of x = 0 in binHist
% bias: mean of quantization/truncation noise after dequantization
% sig: std of quantization/truncation noise

N = sum(hcal);
% simulate quantization
if mod(Q,2) == 0
    hs = [0.5 ones(1,Q-1) 0.5];
    ws = Q/2;
else
    hs = ones(1,Q);
    ws = (Q-1)/2;
end
h2 = conv(hcal,hs);
% simulate dequantization
h1 = zeros(size(binHist));
h1(center + 1:Q:end) = h2(center + 1 + ws:Q:end-ws);
h1(center + 1:-Q:1) = h2(center + 1 + ws:-Q:1+ws);
% simulate rounding/truncation
w = ceil(3*sig);
k = -w:w;
g = exp(-(k+bias).^2/sig^2/2);
h1 = conv(h1, g);
h1 = h1(w+1:end-w);
% normalize probability and use Laplace correction to avoid p1 = 0
h1 = h1/sum(h1);
h1 = (h1*N+1)/(N+numel(binHist));

p1 = h1(round(x) + center + 1);

return