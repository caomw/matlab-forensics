function hists = coefhist(mtx, calmask, mode)
% compute coefficient histogram or factor histogram for each frequency,
% depending on the mode string.
% 
% mtx                the coefficient matrix 
% calmask            the 8x8 mask matrix, 1 denotes 'compute', 0 denotes 
%                    'not compute'
% mode               mode string, 'coefficient_histogram' or
%                    'factor_histogram'
% 2015-04-15

if nargin < 3
    mode = 'factor_histogram';
end

qsmax = 100;

mtx = round(mtx);
mtx = abs(mtx);
[row, col] = size(mtx);
[rcal, ccal] = find(calmask == 1);

num = length(rcal);
hists = cell(8,8);
if strcmpi(mode, 'factor_histogram')
    % compute factor histogram for each frequency
    for ni = 1 : num
        rt = rcal(ni);
        ct = ccal(ni);
        samples = mtx(rt:8:row, ct:8:col);
        samples = samples(samples>1);
        maxel = max(samples(:));
        
        if isempty(maxel)
            continue;
        end
        
        mode_hist = hist(samples(:), 1:maxel);
        fhlen = min(qsmax, maxel);
        fh = zeros(1, fhlen);
        for q = 1 : fhlen
            fh(q) = sum(mode_hist(q:q:end));
        end
        hists{rt, ct} = fh;
    end
else
    % compute coefficient histogram for each frequency
    for ni = 1 : num
        rt = rcal(ni);
        ct = ccal(ni);
        samples = mtx(rt:8:row, ct:8:col);
        samples = samples(samples>0);
        maxel = max(samples(:));
        if isempty(maxel) || maxel<1
            continue;
        end
        mode_hist = hist(samples(:), 1:maxel);
        hists{rt, ct} = mode_hist;
    end
end
return;