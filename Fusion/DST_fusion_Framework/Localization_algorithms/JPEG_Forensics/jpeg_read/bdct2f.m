% BDCT 2-D Blocked discrete cosine transform, fast version
%
%    B = BDCT2F(A) computes DCT2 transform of A in 8x8 blocks.  Size of A 
%    must be multiple of 8. B is the same size as A and contains the cosine
%    transform coefficients for each block. This transform can be inverted 
%    using IBDCT.
%

function [b] = bdct2f(a)

[r,c] = size(a);
if bitand(r,3) || bitand(c,3)
  error('bdct2f: size of image must me multiple of 8');
end

% compute DCT matrix
C = dct(eye(8));

% apply separable dct along columns and rows
tmp = reshape(a, 8, numel(a)/8);
tmp = C * tmp;
tmp = reshape(tmp, r, c);
tmp = reshape(tmp.', 8, numel(tmp)/8);
tmp = C * tmp;
b = reshape(tmp, c, r).';

return
