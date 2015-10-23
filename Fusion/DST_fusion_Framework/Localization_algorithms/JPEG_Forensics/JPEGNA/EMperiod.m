function [Q, alpha, Lmax, ii] = EMperiod(x, Qmin, Qmax, alpha0, p0, p1, dLmin, maxIter)
%
% function [Q, alpha] = EMperiod(x, Qmin, Qmax, alpha0, p0, p1)
% 
% estimate quantization factor Q and mixture parameter alpha from data x
% x are assumed distributed as h(x) = alpha * p0(x) + (1 - alpha) * p1(x,Q)
% Qmin, Qmax: range of possible Qs
% alpha0: initial guess for alpha
% dLmin: convergence parameter
%
% alpha is estimated through the EM algorithm for every Q = Qmin:Qmax
% the optimal Q is found by exhaustive maximization over the true
% log-likelihood function L = sum(log(h(x|Q)))
% the EM algorithm is assumed to converge when the increase of L is less
% than dLmin

h0 = p0(x);
Qvec = Qmin:Qmax;
alphavec = alpha0*ones(size(Qvec));
h1mat = zeros(length(Qvec), length(x));
for k = 1:length(Qvec)
    h1mat(k,:) = p1(x, Qvec(k));
end
Lvec = -inf(size(Qvec));
Lmax = -inf;
delta_L = inf;
ii = 0;

while delta_L > dLmin && ii < maxIter
    ii = ii + 1;
    for k = 1:length(Qvec)

        % expectation
        beta0 = h0*alphavec(k) ./ (h0*alphavec(k) + h1mat(k,:)*(1 - alphavec(k)));
        % maximization
        alphavec(k) = mean(beta0);
        % compute true log-likelihood of mixture
        L = sum(log(alphavec(k)*h0 + (1-alphavec(k))*h1mat(k,:)));
        if L > Lmax
            Lmax = L;
            Q = Qvec(k);
            alpha = alphavec(k);
            if L - Lvec(k) < delta_L
                delta_L = L - Lvec(k);
            end
        end
        Lvec(k) = L;
    end
%     range = min(x):max(x);
%     h = (hist(x, range)+1)/(numel(x)+numel(range));
%     figure, plot(range, h,range, alpha*p0(range) + (1-alpha)*p1(range, Q))
%     figure, plot(Qvec, Lvec)
% %     figure, plot(Qvec, alphavec)
%     display(['new Lmax is ', num2str(Lmax)])
%     display(['new Q is ', num2str(Q)])
%     display(['new alpha is ', num2str(alpha)])
%     pause
end

% range = min(x):max(x);
% h = (hist(x, range)+1)/(numel(x)+numel(range));
% figure, plot(range, h,range, alpha*p0(range) + (1-alpha)*p1(range, Q))
% figure, plot(Qvec, Lvec)
% % figure, plot(Qvec, alphavec)
% % display(['new Lmax is ', num2str(Lmax)])
% display(['new Q is ', num2str(Q)])
% display(['new alpha is ', num2str(alpha)])
% pause

return