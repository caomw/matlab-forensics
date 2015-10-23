function [Q, alpha] = EMperiodAC(x, Q0, Qmin, Qmax, alpha0, lambda, sig, N)

h0 = lambda*exp(-lambda*abs(x))/2;
h = hist(x, -1024:1024)/numel(x);

alpha = alpha0;
Q = Q0;
Lmax = -inf;
change = true;
while change
    % expectation
    h1 = h1periodAC(x, Q, lambda, sig, N);
    beta0 = h0*alpha ./ (h0*alpha + h1*(1 - alpha));
    
    % maximization
    alpha = mean(beta0);
    display(['new alpha is ', num2str(alpha)])
    figure, plot(-1024:1024, lambda*exp(-lambda*abs(-1024:1024))/2, -1024:1024, h1periodAC(-1024:1024, Q, lambda, sig, N))
    figure, plot(-1024:1024, h, -1024:1024, alpha*lambda*exp(-lambda*abs(-1024:1024))/2 + (1-alpha)*h1periodAC(-1024:1024, Q, lambda, sig, N))
    
    Lvec = [];
    change = false;
    for Qtmp = Qmin:Qmax
        h1 = h1periodAC(x, Qtmp, lambda, sig, N);
        beta0 = h0*alpha ./ (h0*alpha + h1*(1 - alpha));
        L = sum(beta0.*log(h0) + (1-beta0).*log(h1));
        if L > Lmax
            Q = Qtmp;
            Lmax = L;
            change = true;
        end
        Lvec = [Lvec L];
    end
    figure, plot(Qmin:Qmax, Lvec)
    display(['new Q is ', num2str(Q)])
    display(['new Lmax is ', num2str(Lmax)])
    pause
end

return