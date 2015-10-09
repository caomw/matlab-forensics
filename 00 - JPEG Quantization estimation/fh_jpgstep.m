function [step,fhcell] = fh_jpgstep(pmtx, t)

% estimate the quantization step for each frequency
% pmtx               pixel matrix of decompressed bitmap to be estimated
% t                  threshold, 0.70 (default)
% step               the estimated quantization steps
% 2015-04-15

if nargin < 2
    % the default threshold
    t = 0.70;
end

pmtx = double(pmtx);
dctmtx = bdct(pmtx - 128);

% Preprocessing: exclude truncation blocks --------------------------------
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
% -------------------------------------------------------------------------%
% compute factor histogram for each frequency
mask = true(8, 8);
fhcell = coefhist(dctmtx, mask, 'factor_histogram');

invpos = find(mask==1);
len = length(invpos);

step = zeros(8, 8);
for i = 1 : len
    cfh = fhcell{invpos(i)};
    if  isempty(cfh)
        continue;
    end
    cfh = cfh / cfh(1);
    
%     stepcand = find(cfh>=t);
%     step(invpos(i)) = max(stepcand);
    
    % estimate the quantization step for each frequency
    step(invpos(i)) = find(cfh>=t, 1, 'last');
end
return;