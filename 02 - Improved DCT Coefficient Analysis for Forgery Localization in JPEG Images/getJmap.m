function [maskTampered, q1table, alphatable] = getJmap(image,ncomp,c1,c2)
%
% [maskTampered, q1table, alphatable] = getJmap(image,ncomp,c1,c2)
%
% detect and localize tampered areas in doubly compressed JPEG images
%
% Matlab JPEG Toolbox is required, available at:
% http://www.philsallee.com/jpegtbx/index.html
%
% image: JPEG object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c2 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block
% q1table: estimated quantization table of primary compression
% alphatable: mixture parameter for each DCT frequency
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
%
%
% Modified to work with non-jpeg files (that have undergone JPEG
% compressions in the past, of course).
if isstruct(image)
    coeffArray = image.coef_arrays{ncomp};
    qtable = image.quant_tables{image.comp_info(ncomp).quant_tbl_no};
    
    % estimate rounding and truncation error
    I = jpeg_rec(image);
    E = I - double(uint8(I));
    Edct = bdct(0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
    Edct2 = reshape(Edct,1,numel(Edct));
    varE = var(Edct2);
    
else
    image=image(1:floor(size(image,1)/8)*8,1:floor(size(image,2)/8)*8,:);
    
    coeffArray = ExtractYDCT(image);
    qtable=ExtractQTable(coeffArray);
    
    I = ibdct(dequantize(coeffArray, qtable)) + 128;
    %imshow(uint8(I));
    %max(max(I))
    %min(min(I))
    E = I - double(uint8(I));
    Edct = 0.299*bdct(E); %0.299 * E(:,:,1) +  0.587 * E(:,:,2) + 0.114 * E(:,:,3));
    Edct2 = reshape(Edct,1,numel(Edct));
    varE = var(Edct2);
end


% simulate coefficients without DQ effect
Y = ibdct(dequantize(coeffArray, qtable));
coeffArrayS = bdct(Y(2:end,2:end,1));

sizeCA = size(coeffArray);
sizeCAS = size(coeffArrayS);
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
coeffFreq = zeros(1, numel(coeffArray)/64);
coeffSmooth = zeros(1, numel(coeffArrayS)/64);
errFreq = zeros(1, numel(Edct)/64);

bppm = 0.5 * ones(1, numel(coeffArray)/64);
bppmTampered = 0.5 * ones(1, numel(coeffArray)/64);

q1table = 100 * ones(size(qtable));
alphatable = ones(size(qtable));
Q1up = [20*ones(1,10) 30*ones(1,5) 40*ones(1,6) 64*ones(1,7) 80*ones(1,8), 99*ones(1,28)];

for index = c1:c2
    
    coe = coeff(index);
    % load DCT coefficients at position index
    k = 1;
    start = mod(coe,8);
    if start == 0
        start = 8;
    end
    for l = start:8:sizeCA(2)
        for i = ceil(coe/8):8:sizeCA(1)
            coeffFreq(k) = coeffArray(i,l);
            errFreq(k) = Edct(i,l);
            k = k+1;
        end
    end
    k = 1;
    for l = start:8:sizeCAS(2)
        for i = ceil(coe/8):8:sizeCAS(1)
            coeffSmooth(k) = coeffArrayS(i,l);
            k = k+1;
        end
    end
    
    % get histogram of DCT coefficients
    binHist = (-2^11:1:2^11-1);
    num4Bin = hist(coeffFreq,binHist);
    
    % get histogram of DCT coeffs w/o DQ effect (prior model for
    % uncompressed image)
    Q2 = qtable(floor((coe-1)/8)+1,mod(coe-1,8)+1);
    hsmooth = hist(coeffSmooth,binHist*Q2);
    
    % get estimate of rounding/truncation error
    biasE = mean(errFreq);
    
    % kernel for histogram smoothing
    sig = sqrt(varE) / Q2;
    f = ceil(6*sig);
    p = -f:f;
    g = exp(-p.^2/sig^2/2);
    g = g/sum(g);
    
    lidx = binHist ~= 0;
    hweight = 0.5 * ones(1, 2^12);
    E = inf;
    Etmp = inf(1,99);
    alphaest = 1;
    Q1est = 1;
    biasest = 0;
    
    if index == 1
        bias = biasE;
    else
        bias = 0;
    end
    
    % estimate Q-factor of first compression
    for Q1 = 1:Q1up(index)
        for b = bias
            alpha = 1;
            if mod(Q2, Q1) == 0
                diff = (hweight .* (hsmooth - num4Bin)).^2;
            else
                % nhist * hsmooth = prior model for doubly compressed coefficient
                nhist = Q1/Q2 * (floor2((Q2/Q1)*(binHist + b/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + b/Q2 - 0.5)) + 1);
                nhist = conv(g, nhist);
                nhist = nhist(f+1:end-f);
                a1 = hweight .* (nhist .* hsmooth - hsmooth);
                a2 = hweight .* (hsmooth - num4Bin);
                % exclude zero bin from fitting
                alpha = -(a1(lidx) * a2(lidx)') / (a1(lidx) * a1(lidx)');
                alpha = min(alpha, 1);
                diff = (hweight .* (alpha * a1 + a2)).^2;
            end
            KLD = sum(diff(lidx));
            if KLD < E && alpha > 0.25
                E = KLD;
                Q1est = Q1;
                alphaest = alpha;
            end
            if KLD < Etmp(Q1)
                Etmp(Q1) = KLD;
                biasest = b;
            end
        end
    end
    
    Q1 = Q1est;
    nhist = Q1/Q2 * (floor2((Q2/Q1)*(binHist + biasest/Q2 + 0.5)) - ceil2((Q2/Q1)*(binHist + biasest/Q2 - 0.5)) + 1);
    nhist = conv(g, nhist);
    nhist = nhist(f+1:end-f);
    nhist = alpha * nhist + 1 - alpha;
    
    ppt = mean(nhist) ./ (nhist + mean(nhist));
    
    alpha = alphaest;
    q1table(floor((coe-1)/8)+1,mod(coe-1,8)+1) = Q1est;
    alphatable(floor((coe-1)/8)+1,mod(coe-1,8)+1) = alpha;
    % compute probabilities if DQ effect is present
    if mod(Q2,Q1est) > 0
        % index
        nhist = Q1est/Q2 * (floor2((Q2/Q1est)*(binHist + biasest/Q2 + 0.5)) - ceil2((Q2/Q1est)*(binHist + biasest/Q2 - 0.5)) + 1);
        % histogram smoothing (avoids false alarms)
        nhist = conv(g, nhist);
        nhist = nhist(f+1:end-f);
        nhist = alpha * nhist + 1 - alpha;
        
        ppu = nhist ./ (nhist + mean(nhist));
        ppt = mean(nhist) ./ (nhist + mean(nhist));
        % set zeroed coefficients as non-informative
        ppu(2^11 + 1) = 0.5;
        ppt(2^11 + 1) = 0.5;
        
        bppm = bppm .* ppu(coeffFreq + 2^11 + 1);
        bppmTampered = bppmTampered .* ppt(coeffFreq + 2^11 + 1);
    end
end

maskTampered = bppmTampered ./ (bppm + bppmTampered);
maskTampered = reshape(maskTampered,sizeCA(1)/8,sizeCA(2)/8);

% apply median filter to highlight connected regions
maskTampered = medfilt2(maskTampered, [5 5]);

return