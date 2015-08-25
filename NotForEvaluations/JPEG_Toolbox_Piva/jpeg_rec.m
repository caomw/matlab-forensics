function [I,YCbCr] = jpeg_rec(image)
%
% [I,YCbCr] = jpeg_rec(image)
%
% simulate decompressed JPEG image from JPEG object
%
% Matlab JPEG Toolbox is required, available at:
% http://www.philsallee.com/jpegtbx/index.html
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
Y = Y + 128;

if image.image_components==3
    if length(image.quant_tables)==1
        image.quant_tables{2}=image.quant_tables{1};
        image.quant_tables{3}=image.quant_tables{1};
    end
    
    Cb = ibdct(dequantize(image.coef_arrays{2}, image.quant_tables{2}));
    Cr = ibdct(dequantize(image.coef_arrays{3}, image.quant_tables{2}));
    
    [r,c] = size(Y);
    [rC,cC]=size(Cb);
    
    if  (ceil(r/rC)==2) && (ceil(c/cC)==2) % 4:2:0
        kronMat=ones(2);
    elseif  (ceil(r/rC)==1) && (ceil(c/cC)==4) % 4:1:1
        kronMat=ones(1,4);
    elseif (ceil(r/rC)==1) && (ceil(c/cC)==2) % 4:2:2
        kronMat=ones(1,4);
    elseif (ceil(r/rC)==1) && (ceil(c/cC)==1) % 4:4:4
        kronMat=ones(1,1);
    elseif (ceil(r/rC)==2) && (c/cC==1) % 4:4:0
        kronMat=ones(2,1);
    else
        error(['Subsampling method not recognized: ', num2str(size(Y)), num2str(size(Cr))]);
    end
    
    
    Cb = kron(Cb,kronMat) + 128;
    Cr = kron(Cr,kronMat) + 128;
    
    Cb = Cb(1:r,1:c);
    Cr = Cr(1:r,1:c);
    
    I(:,:,1) = (Y + 1.402 * (Cr -128));
    I(:,:,2) = (Y - 0.34414 *  (Cb - 128) - 0.71414 * (Cr - 128));
    I(:,:,3) = (Y + 1.772 * (Cb - 128));
    YCbCr = cat(3,Y,Cb,Cr);
else
    I=repmat(Y,[1,1,3]);
    YCbCr=rgb2ycbcr(I);
end



return