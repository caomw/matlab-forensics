function [k1,k2,Q,IPM,DIPM] = detectNA(im,ncomp,th1,th2,show)
%
% [k1,k2,Q,IPM,DIPM] = detectNA(im,ncomp,th1,th2,show)
%
% Implementation of an algorithm to detect the presence of non-aligned
% double JPEG compression (NA-JPEG) as described in T. Bianchi and A. Piva,
% "Detection of Non-Aligned Double JPEG Compression Based on Integer
% Periodicity Maps", IEEE Trans. Forensics Security.
%
% Matlab JPEG Toolbox is required, available at:
% http://www.philsallee.com/jpegtbx/index.html
%
% im:       jpeg object from jpeg_read of Matlab JPEG Toolbox
% ncomp:    index of color component to be used (1 = Y, 2 = Cb, 3 = Cr)
% th1:      threshold on minH of IPM
% th2:      threshold on minH of DIPM
% show:     show IPM/DIPM if true
%
% k1, k2:   shift of previous JPEG compression
%           (shift as defined on paper is given by (9-k) mod 8)
% Q:        quantization step of DC coeff of previous JPEG compression
%           if NA-JPEG compression is not detected: k1 = k2 = Q = 0
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
    disp('sss');
    ncomp = 1;
    th1 = 4;
    th2 = 2.5;
end
if nargin < 5
    show = false;
end

coeffArray = im.coef_arrays{ncomp};
qtable = im.quant_tables{im.comp_info(ncomp).quant_tbl_no};
minQ = max(2, floor(qtable/sqrt(3)));
maxQ = max(20, qtable);
% simulate decompression
I = ibdct(dequantize(coeffArray, qtable));
% compute DC coefficients for all shifts
DC = conv2(I, ones(8)/8);
DC = DC(8:end,8:end);
hspecref = 0;
Qmap = zeros(8,8,maxQ(1,1)-minQ(1,1)+1);
Q2 = qtable(1,1);

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
        
        %  normalize for better visualization
        if k1 == 1 && k2 == 1
            hspecref = hspec;
        end
        if  Q2 > 1
            Qmap(k1,k2,:) = hspec / hspecref(periods == Q2);
        else
            Qmap(k1,k2,:) = hspec / sum(num4Bin);
        end
    end
end

k1dQ = 0;
k2dQ = 0;
k1sQ = 0;
k2sQ = 0;
Q = 0;
maxQmap = 0;
minHbest = 6;
for k = 1:length(periods)
    Qmaptmp = Qmap(:,:,k);
    if periods(k) == Q2
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
        minH = min(-log2(Qmaptmp2(:)/sum(Qmaptmp2(:))));
        if show
            figure, imagesc(Qmaptmp2), title(['DIPM: Q = ', num2str(periods(k)), '; minH2 = ', num2str(minH)])
        end
        DIPM = Qmaptmp2;
        if minH < th2
            % record shift if minH of DIPM < th2 and (k1,k2) ~= (1,1)
            [m1,i1] = max(Qmaptmp2);
            [m2,i2] = max(m1);
            if i1(i2) > 1 || i2 > 1
                k1sQ = i1(i2);
                k2sQ = i2;
            end
        end
    else
        % compute IPM
        minH = min(-log2(Qmaptmp(:)/sum(Qmaptmp(:))));
        if minH < th1
            % record shift if minH of IPM < th1 and (k1,k2) ~= (1,1)
            % check also if correspond to maximum peak of IPMs
            [m1,i1] = max(Qmaptmp);
            [m2,i2] = max(m1);
            if (i1(i2) > 1 || i2 > 1) && m2 > maxQmap
                k1dQ = i1(i2);
                k2dQ = i2;
                maxQmap = m2;
                Q = periods(k);
            end
        end
        if minH < minHbest
            [m1,i1] = max(Qmaptmp);
            [m2,i2] = max(m1);
            if (i1(i2) > 1 || i2 > 1)
                Qmapbest = Qmaptmp;
                minHbest = minH;
                Qbest = periods(k);
            end
        end
    end
end
if show
    figure, imagesc(Qmapbest,[0 1]), title(['IPM: Q = ', num2str(Qbest), '; minH1 = ', num2str(minHbest)])
end

if exist('Qmapbest','var')
    IPM = Qmapbest;
else
    IPM = [];
end

if k1dQ > 1 || k2dQ > 1
    k1 = k1dQ;
    k2 = k2dQ;
elseif k1sQ > 1 || k2sQ > 1
    k1 = k1sQ;
    k2 = k2sQ;
    Q = Q2;
else
    k1 = 0;
    k2 = 0;
    Q = 0;
end


if ~(exist('DIPM','var'))
    DIPM=[];
end

return