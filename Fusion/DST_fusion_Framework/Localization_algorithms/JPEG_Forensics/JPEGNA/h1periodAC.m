function [h1] = h1periodAC(x, Q, lambda, sig, N)

h1 = (1 - exp(-lambda*Q/2)) * exp(-(x/sig).^2/2);
for k = Q:Q:N
    h1 = h1 + exp(-lambda*k)*sinh(lambda*Q/2)*(exp(-((x-k)/sig).^2/2) + exp(-((x+k)/sig).^2/2));
end
h1 = h1/sig/sqrt(2*pi);

return