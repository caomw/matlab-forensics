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



function [L] = loglikelihood(statistics, mu, sigma)

% Loglikelihood map

% allowable values for logarithm
min = 1e-320;
max = 1e304;

statistics(isnan(statistics))=1;
statistics(isinf(statistics))=max;
statistics(statistics == 0) = min;


mu1=mu(2);
mu2=mu(1);

sigma1=sigma(2);
sigma2=sigma(1);

% log-likelihood
L = log(sigma1) - log(sigma2) ...
    -0.5.*((((log(statistics) - mu2).^2)/sigma2^2) - ...
    (((log(statistics) - mu1).^2)/sigma1^2));

return