% Copyright (C) 2011 Signal Processing and Communications Laboratory (LESC),       
% Dipartimento di Elettronica e Telecomunicazioni - Università di Firenze                        
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
    f1 = alpha * exp(-x.^2/2/v1)/sqrt(v1);
    f2 = (1 - alpha) * exp(-(x - mu2).^2/2/v2)/sqrt(v2);
    alpha1 = f1 ./ (f1 + f2);
    alpha2 = f2 ./ (f1 + f2);
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