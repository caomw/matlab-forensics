function [LLRmap2] = smooth_unshift(LLRmap,k1,k2)
%
% [LLRmap2] = smooth_unshift(LLRmap,k1,k2)
%
% smooth likelihood map by applying a 3x3 mean filter
% align map with the examined image
%
% LLRmap: raw likelihood map 
% k1,k2: grid shift of primary compression
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
% 
% If you modify this Program, or any covered work, by linking or combining it 
% with Matlab JPEG Toolbox (or a modified version of that library), 
% containing parts covered by the terms of Matlab JPEG Toolbox License, 
% the licensors of this Program grant you additional permission to convey the 
% resulting work. 

LLRmap = imfilter(LLRmap, ones(3), 'symmetric', 'full');

LLRmap_big = zeros(8*size(LLRmap));
LLRmap_big(1:8:end,1:8:end) = LLRmap;
bil = conv2(ones(8), ones(8))/64;
LLRmap_big = imfilter(LLRmap_big, bil, 'full');
LLRmap2 = LLRmap_big(16-k1:8:end-16-k1,16-k2:8:end-16-k2);

return