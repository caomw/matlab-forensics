function [p1] = h1period(x, Q, hcal, binHist, center, bias, sig)
%
% [p1] = h1period(x, Q, hcal, binHist, center, bias, sig)
%
% estimate probability distribution of quantized/dequantized coefficients 
% for value(s) x according to NA-DJPG model
%
% Q: quantization step 
% hcal: histogram of unquantized coefficient
% binHist: bin positions
% center: index of x = 0 in binHist
% bias: mean of quantization/truncation noise after dequantization
% sig: std of quantization/truncation noise
%
% p1: estimated pdf at binHist
%
% Copyright (C) 2012 Signal Processing and Communications Laboratory (LESC),       
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
% 
% If you modify this Program, or any covered work, by linking or combining it 
% with Matlab JPEG Toolbox (or a modified version of that library), 
% containing parts covered by the terms of Matlab JPEG Toolbox License, 
% the licensors of this Program grant you additional permission to convey the 
% resulting work. 

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