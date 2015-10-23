% BDCT 2-D Blocked discrete cosine transform
%
%    B = BDCT2(A) computes DCT2 transform of A in 8x8 blocks.  B is
%    the same size as A and contains the cosine transform coefficients for
%    each block.  This transform can be inverted using IBDCT.
%
%    B = BDCT2(A,N) computes DCT2 transform of A in blocks of size NxN.

function [b] = bdct2(a,n)

if (nargin == 1)
  n = 8;
end
[r,c] = size(a);

% pad with zeros to have size multiple of n
rtmp = floor(r/n)*n;
ctmp = floor(c/n)*n;
tmp = double(a(1:rtmp, 1:ctmp));

% compute DCT matrix
C = dct(eye(n));

% apply separable dct along columns and rows
tmp = reshape(tmp, n, numel(tmp)/n);
tmp = C * tmp;
tmp = reshape(tmp, rtmp, ctmp);
tmp = reshape(tmp.', n, numel(tmp)/n);
tmp = C * tmp;
b = reshape(tmp, ctmp, rtmp).';

return
