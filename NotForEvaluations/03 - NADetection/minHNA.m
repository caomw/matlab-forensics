function [minH1, minH2] = minHNA(im,ncomp)
%
% [minH1, minH2] = minHNA(im,ncomp)
%
% Computation of features able to detect the presence of non-aligned 
% double JPEG compression (NA-JPEG) as described in T. Bianchi and A. Piva,
% "Detection of Non-Aligned Double JPEG Compression Based on Integer 
% Periodicity Maps", IEEE Trans. Forensics Security.
%
% Matlab JPEG Toolbox is required, available at: 
% http://www.philsallee.com/jpegtbx/index.html
% 
% im:       jpeg object from jpeg_read of Matlab JPEG Toolbox
% ncomp:    index of color component to be used (1 = Y, 2 = Cb, 3 = Cr)
%
% minH1:    smaller min-entropy of IPM such that maximum of IPM is not at
%           (0,0)
% minH2:    min-entropy of DIPM
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

if nargin < 2
    ncomp = 1;
end

coeffArray = im.coef_arrays{ncomp};
qtable = im.quant_tables{im.comp_info(ncomp).quant_tbl_no};
minQ = max(2, floor(qtable/sqrt(3)));
maxQ = max(16, qtable);
% simulate decompression
I = ibdct(dequantize(coeffArray, qtable));
% compute DC coefficients for all shifts
DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);
Qmap = zeros(8,8,maxQ(1,1)-minQ(1,1)+1);

binHist = (-2^11:1:2^11-1);
periods = minQ(1,1):maxQ(1,1);
% define DFT matrix for frequencies corresponding to integer periods
harmfreq = 1./periods;
IPDFT = exp(-2*pi*i* binHist' * harmfreq);

for k1 = 1:8
    for k2 = 1:8
        % get DC coefficients for shift k1, k2
        DCpoly = DC(k1:8:end,k2:8:end);
        num4Bin = hist(DCpoly(:),binHist);
        % compute DFT of histogram of DC coeffs
        hspec = abs(num4Bin * IPDFT);
        Qmap(k1,k2,:) = hspec;
    end
end

minH1 = 6;
minH2 = 6;
for k = 1:length(periods)
    Qmaptmp = Qmap(:,:,k);
    if periods(k) == qtable(1,1) 
        % compute DIPM
        Qmaptmp2(2:4,2:4) = Qmaptmp(2:4,2:4) - (Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(2:4,8:-1:6) = Qmaptmp(2:4,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(8:-1:6,2:4) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,2:4) = Qmaptmp(8:-1:6,2:4) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,8:-1:6)) / 3;
        Qmaptmp2(8:-1:6,8:-1:6) = Qmaptmp(8:-1:6,8:-1:6) - (Qmaptmp(2:4,2:4) + Qmaptmp(2:4,8:-1:6) + Qmaptmp(8:-1:6,2:4)) / 3;
        Qmaptmp2(1,2:4) = Qmaptmp(1,2:4) - Qmaptmp(1,8:-1:6);
        Qmaptmp2(1,8:-1:6) = Qmaptmp(1,8:-1:6) - Qmaptmp(1,2:4);
        Qmaptmp2(2:4,1) = Qmaptmp(2:4,1) - Qmaptmp(8:-1:6,1);
        Qmaptmp2(8:-1:6,1) = Qmaptmp(8:-1:6,1) - Qmaptmp(2:4,1);
        Qmaptmp2(5,2:4) = Qmaptmp(5,2:4) - Qmaptmp(5,8:-1:6);
        Qmaptmp2(5,8:-1:6) = Qmaptmp(5,8:-1:6) - Qmaptmp(5,2:4);
        Qmaptmp2(2:4,5) = Qmaptmp(2:4,5) - Qmaptmp(8:-1:6,5);
        Qmaptmp2(8:-1:6,5) = Qmaptmp(8:-1:6,5) - Qmaptmp(2:4,5);
        Qmaptmp2(1,5) = Qmaptmp(1,5) - (Qmaptmp(1,4) + Qmaptmp(1,6)) / 2;
        Qmaptmp2(5,1) = Qmaptmp(5,1) - (Qmaptmp(4,1) + Qmaptmp(6,1)) / 2;
        Qmaptmp2(5,5) = Qmaptmp(5,5) - (Qmaptmp(4,5) + Qmaptmp(6,5) + Qmaptmp(5,4) + Qmaptmp(5,6)) / 4;
        Qmaptmp2 = max(Qmaptmp2, 0);
        minH2 = min(-log2(Qmaptmp2(:)/sum(Qmaptmp2(:))));
    else
        % compute IPM
        minH = min(-log2(Qmaptmp(:)/sum(Qmaptmp(:))));
        if minH < minH1
            % record minimum value of minH if argmax_{i,j} IPM ~= (0,0)
            [m1,i1] = max(Qmaptmp);
            [m2,i2] = max(m1);
            if (i1(i2) > 1 || i2 > 1)
                 minH1 = minH;
            end
        end
    end
end

return