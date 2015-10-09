function S = fh_jpgdetect(pmtx)
% compute the Sac facture for a given bitmap

% the reasonable maximum of quantization step 
qsmax = 100;

pmtx = double(pmtx);
dctmtx = bdct(pmtx - 128);

% preprocessing: exclude truncation blocks --------------------------------
[row, col] = size(dctmtx);
availmtx = true(row, col);
for bi = 1 : floor(row/8)
    for bj = 1 : floor(col/8)
        pblk = pmtx([1:8]+(bi-1)*8, [1:8]+(bj-1)*8);
        pmax = max(pblk(:));
        pmin = min(pblk(:));
        if  pmax == 255 || pmin ==0
            availmtx([1:8]+(bi-1)*8, [1:8]+(bj-1)*8) = 0;
        end
    end
end
dctmtx = dctmtx .* availmtx;
% -------------------------------------------------------------------------

% only AC coefficients are used
dctmtx(1:8:end,1:8:end) = 0;

% exclude 0 -1 and 1
samples = abs(round(dctmtx(:)));
samples = samples(samples>1);

maxel = max(samples(:));
coef_histo = hist(samples, 1:maxel);
fhlen = min(qsmax, maxel);

if isempty(maxel) || maxel<=1
    S = 0;
    return;
end

% fast calculation of factor histogram
fh = zeros(1, fhlen);
for q = 1 : fhlen
    fh(q) = sum(coef_histo(q:q:end));
end

% normalize
fh = fh / fh(1);

deriv1 = fh(2:end) - fh(1:end-1);
S = max(deriv1);
return;


