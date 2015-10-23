function [y,cb,cr] = rgb2jfif(r,g,b)
%RGB2JFIF Convert red-green-blue colors to Y, Cb, Cr according to JFIF v1.02.
%   
if ~isa(r, 'uint8')
    error('rgb2jfif: input must be of class uint8')
end

if nargin == 1
    b = double(r(:,:,3));
    g = double(r(:,:,2));
    r = double(r(:,:,1));
elseif nargin == 3
    b = double(b);
    g = double(g);
    r = double(r);
else
    error('rgb2jfif: wrong number of input arguments')
end

y = uint8(round(0.299 * r + 0.587 * g + 0.114 * b));
cb = uint8(round( -0.1687 * r - 0.3313 * g + 0.5 * b + 128));
cr = uint8(round(0.5 * r - 0.4187 * g - 0.0813 * b + 128));
    
if nargout == 1
    y = cat(3,y,cb,cr);
end

return