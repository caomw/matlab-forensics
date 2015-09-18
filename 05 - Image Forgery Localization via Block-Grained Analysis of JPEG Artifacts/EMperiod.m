function [Q, alpha, Lmax, ii] = EMperiod(x, Qmin, Qmax, alpha0, p0, p1, dLmin, maxIter)
%
% function [Q, alpha, Lmax, ii] = EMperiod(x, Qmin, Qmax, alpha0, p0, p1, dLmin, maxIter)
% 
% estimate quantization factor Q and mixture parameter alpha from data x
% x are assumed distributed as h(x) = alpha * p0(x) + (1 - alpha) * p1(x,Q)
% Qmin, Qmax: range of possible Qs
% alpha0: initial guess for alpha
% dLmin, maxIter: convergence parameters
%
% alpha is estimated through the EM algorithm for every Q = Qmin:Qmax
% the optimal Q is found by exhaustive maximization over the true
% log-likelihood function L = sum(log(h(x|Q)))
% the EM algorithm is assumed to converge when the increase of L is less
% than dLmin
%
% Lmax: final value of log-likelihood function
% ii: final number of iterations
%
% Copyright (C) 2011 Signal Processing and Communications Laboratory (LESC),       
% Dipartimento di Elettronica e Telecomunicazioni - Universit� di Firenze                        
% via S. Marta 3 - I-50139 - Firenze, Italy                   
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% 
% Additional permission under GNU GPL version 3 section 7
% 
% If you modify this Program, or any covered work, by linking or combining it 
% with Matlab JPEG Toolbox (or a modified version of that library), 
% containing parts covered by the terms of Matlab JPEG Toolbox License, 
% the licensors of this Program grant you additional permission to convey the 
% resulting work. 


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

    % Markos: for cases where the if clause is never activated    
    Q=Qvec(1);
    alpha=alphavec(1);

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
end

return