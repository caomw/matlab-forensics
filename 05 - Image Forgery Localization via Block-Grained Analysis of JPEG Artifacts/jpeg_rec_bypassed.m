function [I,YCbCr] = jpeg_rec(image)
%
% [I,YCbCr] = jpeg_rec(image)
%
% simulate decompressed JPEG image from JPEG object 
%
% image: JPEG object from jpeg_read
%
% I: decompressed image (RGB)
% YCbCr: decompressed image (YCbCr)
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


Y = ibdct(dequantize(image.coef_arrays{1}, image.quant_tables{1}));
Cb = ibdct(dequantize(image.coef_arrays{2}, image.quant_tables{2}));
Cr = ibdct(dequantize(image.coef_arrays{3}, image.quant_tables{2}));

Y = Y + 128;
[r,c] = size(Y);
Cb = kron(Cb,ones(2)) + 128;
Cr = kron(Cr,ones(2)) + 128;
Cb = Cb(1:r,1:c);
Cr = Cr(1:r,1:c);


I(:,:,1) = (Y + 1.402 * (Cr -128));
I(:,:,2) = (Y - 0.34414 *  (Cb - 128) - 0.71414 * (Cr - 128));
I(:,:,3) = (Y + 1.772 * (Cb - 128));

YCbCr = cat(3,Y,Cb,Cr);

return