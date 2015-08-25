function [map, stat] = CFAloc(image, Bayer, Nb, Ns)
%
% [map, stat] = CFAloc(image,Bayer, Nb, Ns)
%
% Implementation of an algorithm to detect the presence/absence of CFA
% artifacts to localize forged region as described in P. Ferrara, T.
% Bianchi, A. De Rosa and P. Piva, "Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts",  
% IEEE Transactions on Information Forensics & Security, vol. 7,  no. 5,  
% Oct. 2012 (published online June 2012),  pp. 1566-1577. 
%
% 
% image:    image 
% Bayer:    2x2 Bayer pattern of green channel. It is assumed to be known
% Nb:       feature dimension
% Ns:       number of blocks to cumulate
%
% map:      log-likelihood map
% stat:     proposed feature
%
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
% 
% 
% Additional permission under GNU GPL version 3 section 7

if (nargin ~= 4)
    error('Insert image, 2x2 CFA pattern on grenn channel, Nb and Ns');
end

% parameters
Nm = 5; % dimension of map filtering

% green channel extraction

im = image(:,:,2);

[h, w] = size(im);
dim = [h, w];

% prediction error
pred_error = prediction(im);

% local variance of acquired and interpolated pixels
var_map = getVarianceMap(pred_error, Bayer, dim);

% proposed feature
stat = getFeature(var_map, Bayer, Nb);

% GMM parameters estimation
[mu, sigma] = MoGEstimationZM(stat);

% likelihood map
loglikelihood_map = loglikelihood(stat, mu, sigma);

% filtered and cumulated log-likelihood map
map = getMap(loglikelihood_map, Ns, Nm);

return
