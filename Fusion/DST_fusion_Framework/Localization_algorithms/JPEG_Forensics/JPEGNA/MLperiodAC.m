function [L] = MLperiodAC(x, Q, lambda, sig, N)

L = (1 - exp(-lambda*Q/2)) * exp(-(x/sig).^2/2);
for k = Q:Q:N
    L = L + exp(-lambda*k)*sinh(lambda*Q/2)*(exp(-((x-k)/sig).^2/2) + exp(-((x+k)/sig).^2/2));
end
L = sum(log(L));

return