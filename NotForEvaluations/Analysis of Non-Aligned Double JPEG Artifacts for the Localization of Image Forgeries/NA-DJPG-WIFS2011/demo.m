% example of how to use getJmapNA_EM_oracle
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

filename = 'florence2_tamp_8_4.jpg';
% set parameters
ncomp = 1;
c2 = 6;
k1 = 8;
k2 = 4;
alpha0 = 0.5;
dLmin = 100;
maxIter = 100;

im = jpeg_read(filename);

map = getJmapNA_EM_oracle(im,ncomp,c2,k1,k2,true,alpha0,dLmin,maxIter);
map_final = smooth_unshift(sum(map,3),k1,k2);

figure
subplot(2,1,1), imshow(filename)
subplot(2,1,2), imagesc(map_final), axis equal