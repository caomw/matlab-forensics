% example of how to use getJmap_EM and getJmapNA_EM
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

filename_A = '1.Ferguson.jpg';
filename_NA = '1.Ferguson.jpg';
% set parameters
c2 = 6;

im = jpeg_read(filename_A);

[LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');

disp(' ')
disp('A-DJPG')
disp('Estimated Q1 Table:')
disp(num2str(q1table))

figure
subplot(2,1,1), imshow(filename_A)
subplot(2,1,2), imagesc(map_final), axis equal

im = jpeg_read(filename_NA);

[LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
map_final = smooth_unshift(sum(LLRmap,3),k1e,k2e);

disp(' ')
disp('Press a key to continue ...')
pause

disp(' ')
disp('NA-DJPG')
disp('Estimated Q1 Table:')
disp(num2str(q1table))
disp('Estimated shift:')
disp(['(',num2str(k1e-1),',',num2str(k2e-1),')'])

figure
subplot(2,1,1), imshow(filename_NA)
subplot(2,1,2), imagesc(map_final), axis equal