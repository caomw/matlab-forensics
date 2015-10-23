function [alpha, v1, mu2, v2] = EMGaussianZM(x, tol, max_iter)
%
% estimate Gaussian mixture parameters from data x with EM algorithm
% assume x distributed as alpha * N(0,v1) + (1 - alpha) * N(mu2, v2)

% initial guess
alpha = 0.5;
mu2 = mean(x);
v2 = var(x);
v1 = v2/10;


alpha_old = 1;
k = 1;
while abs(alpha - alpha_old) > tol && k < max_iter
    alpha_old = alpha;
    k = k + 1;
    % expectation
    
    f = ((1 - alpha)/alpha) * exp(-(x - mu2).^2/2/v2 + x.^2/2/v1) / sqrt(v2) * sqrt(v1);
    alpha1 = 1 ./ (1 + f);
    alpha2 = 1-alpha1;
    % maximization
    alpha = mean(alpha1);
    v1 = sum(alpha1 .* x.^2) / sum(alpha1);
    mu2 = sum(alpha2 .* x) / sum(alpha2);
    v2 = sum(alpha2 .* (x - mu2).^2) / sum(alpha2);
end

if abs(alpha - alpha_old) > tol
    display('warning: EM algorithm: number of iterations > max_iter');
end

return