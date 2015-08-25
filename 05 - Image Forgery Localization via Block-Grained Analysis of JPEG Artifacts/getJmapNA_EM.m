function [LLRmap, LLRmap_s, q1table, k1e, k2e, alphatable] = getJmapNA_EM(image,ncomp,c2)
%
% [LLRmap, LLRmap_s, q1table, k1e, k2e, alphatable] = getJmapNA_EM(image,ncomp,c2)
%
% detect and localize tampered areas in doubly compressed JPEG images
%
% Matlab JPEG Toolbox is required, available at: 
% http://www.philsallee.com/jpegtbx/index.html
%
% image: JPEG object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c2: number of DCT coefficients to consider (1 <= c2 <= 64)
%
% LLRmap(:,:,c): estimated likelihood of being doubly compressed for each 8x8 image block
%   using standard model and c-th DCT frequency (zig-zag order)
% LLRmap_s(:,:,c): estimated likelihood of being doubly compressed for each 8x8 image block
%   using simplified model and c-th DCT frequency (zig-zag order)
% q1table: estimated quantization table of primary compression
% k1e, k2e: estimated shift of first compression
% alphatable: mixture parameter for each DCT frequency
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

coeffArray = image.coef_arrays{ncomp};
qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
q1table = ones(8);
minQ = max(2, floor(qtable/sqrt(3)));
maxQ = max(jpeg_qtable(50), qtable);

% estimate rounding and truncation error
I = jpeg_rec(image);
E = I - double(uint8(I));
Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));

I = ibdct(dequantize(coeffArray, qtable));
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
binHist = (-2^11:1:2^11-1);
center = 2^11;

B = ones(8)/8;
DC = conv2(I, B);
DC = DC(8:end,8:end);
EDC = Edct(1:8:end,1:8:end);
varE = var(EDC(:));
bias = mean(EDC(:));
sig = sqrt(qtable(1,1)^2 / 12 + varE);
alphatable = ones(8);
LLRmap = zeros([size(I)/8, c2]);
LLRmap_s = zeros([size(I)/8, c2]);
k1e = 1;
k2e = 1;
Lmax = -inf;

% estimate shift of first compression
for k1 = 1:8
    for k2 = 1:8
        if (k1 > 1 || k2 > 1)
            DCpoly = DC(k1:8:end,k2:8:end);
            % choose shift for estimating unquantized distribution through
            % calibration
            if k1 < 5
                k1cal = k1 + 1;
            else
                k1cal = k1 - 1;
            end
            if k2 < 5
                k2cal = k2 + 1;
            else
                k2cal = k2 - 1;
            end
            DCcal = DC(k1cal:8:end,k2cal:8:end);
            hcal = hist(DCcal(:),binHist);
            hcalnorm = (hcal+1)/(numel(DCcal)+numel(binHist));
            
            % define mixture components
            p0 = @(x) hcalnorm(round(x) + center + 1);
            p1 = @(x,Q) h1period(x, Q, hcal, binHist, center, bias, sig);
        
            % estimate parameters of first compression
            [Q, alpha, L, ii] = EMperiod(DCpoly(:), minQ(1,1), maxQ(1,1), 0.95, p0, p1, 5, 20);
    
          
            if L > Lmax
                % simplified model
                nz = sum(DCpoly(:) ~= 0)/numel(DCpoly);
                LLRmap_s(:,:,1) = LLR(DCpoly, binHist, nz, Q, round(bias), center, sig);
                % standard model
                ppu = log(p1(binHist, Q)./p0(binHist));
                LLRmap(:,:,1) = ppu(round(DCpoly) + center + 1);
                %
                q1table(1,1) = Q;
                alphatable(1,1) = alpha;
                k1e = k1;
                k2e = k2;
                Lmax = L;
            end
        end
    end
end


for index = 2:c2
% 
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    
    A = zeros(8);
    A(ic1,ic2) = 1;
    B = idct2(A);
    
    AC = conv2(I, B);
    AC = AC(8:end,8:end);
    ACpoly = AC(k1e:8:end,k2e:8:end);
    % choose shift for estimating unquantized distribution through
    % calibration
    if k1e < 5
        k1cal = k1e + 1;
    else
        k1cal = k1e - 1;
    end
    if k2e < 5
        k2cal = k2e + 1;
    else
        k2cal = k2e - 1;
    end
    ACcal = AC(k1cal:8:end,k2cal:8:end);
    hcal = hist(ACcal(:),binHist);
    hcalnorm = (hcal+1)/(numel(ACcal)+numel(binHist));            
    
    % estimate std dev of quantization error on DCT coeffs (quantization of
    % second compression plus rounding/truncation between first and second
    % compression)
    EAC = Edct(ic1:8:end,ic2:8:end);
    varE = var(EAC(:));
    if index == 1
        bias = mean(EAC(:));
    else
        bias = 0;
    end
    sig = sqrt(qtable(ic1,ic2)^2 / 12 + varE);
    
    % define mixture components
    p0 = @(x) hcalnorm(round(x) + center + 1);
    p1 = @(x,Q) h1period(x, Q, hcal, binHist, center, bias, sig);

    % estimate parameters of first compression
    [Q, alpha] = EMperiod(ACpoly(:), minQ(ic1,ic2), maxQ(ic1,ic2), 0.95, p0, p1, 5, 20);
    q1table(ic1,ic2) = Q;
    alphatable(ic1,ic2) = alpha;
    
    % simplified model
    nz = sum(ACpoly(:) ~= 0)/numel(ACpoly);
    LLRmap_s(:,:,index) = LLR(ACpoly, binHist, nz, Q, round(bias), center, sig);
    % standard model
    ppu = log(p1(binHist, Q)./p0(binHist));
    LLRmap(:,:,index) = ppu(round(ACpoly) + center + 1);
    %

end


return