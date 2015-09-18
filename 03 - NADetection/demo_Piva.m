% demo of detection algorithm
% naming convention of images:
%   [name]_QXX.jpg: 
%       single JPEG compression with quality XX            
%   [name]_QYY_QXX_NA_k1_k2.jpg: 
%       non aligned double JPEG compression
%       grid shift (k1,k2)
%       quality of first compression YY
%       quality of second compression XX
%  
%   correspondence between JPEG quality and DC quantization step
%   quality:    50    53    56    59    63    66    69    72    75    78   
%   step:       16    15    14    13    12    11    10     9     8     7   
%   quality:    81    84   88    91    94    97
%   step:        6     5    4     3     2     1
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

filenames = {'Varie_038_Q84.jpg',...
             'Varie_038_Q78_Q94_NA_4_4.jpg',...
             'big_299_Q66_Q81_NA_0_1.jpg',...
             'big_299_Q69_Q66_NA_2_7.jpg',...
             'big_108_Q75_Q75_NA_4_2.jpg',...
             'big_108_Q88_Q69_NA_6_6.jpg'};
         
% threshold on min-entropy of IPM
th1 = 4;
% threshold on min-entropy of DIPM
th2 = 2.5;

for k = 1:length(filenames)
    im = jpeg_read(filenames{k});
    [H1,H2] = minHNA(im);
    [k1,k2,Q,IPM,DIPM] = detectNA(im,1,th1,th2,false);
    figure
    subplot(1,3,1), imshow(filenames{k},'InitialMagnification','fit');
    subplot(1,3,2), imagesc(IPM,[0 1]), title(['IPM: min-H = ', num2str(H1)]), axis square
    subplot(1,3,3), imagesc(DIPM,[0 1]), title(['DIPM: min-H = ', num2str(H2)]), axis square
    display(['Image ', filenames{k}])
    display(['min-entropy of IPM: ', num2str(H1)])
    display(['min-entropy of DIPM: ', num2str(H2)])
    if Q > 0
        display('Non-aligned double JPEG compression detected')
        display(['grid shift: (',num2str(mod(9-k1,8)),',',num2str(mod(9-k2,8)),')'])
        display(['quantization step of DC coeff: ', num2str(Q)])
    else
        display('Non-aligned double JPEG compression NOT detected')
    end
    display('Press any key to continue...')
    pause
end