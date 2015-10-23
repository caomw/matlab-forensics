function [r,g,b] = jfif2rgb(y,cb,cr)
%JFIF2RGB Convert Y, Cb, Cr to red-green-blue colors according to JFIF v1.02.
%   
% if ~isa(y, 'uint8')
%     error('jfif2rgb: input must be of class uint8')
% end

if nargin == 1
    cr = double(y(:,:,3));
    cb = double(y(:,:,2));
    y = double(y(:,:,1));
elseif nargin == 3
    cr = double(cr);
    cb = double(cb);
    y = double(y);
else
    error('jfif2rgb: wrong number of input arguments')
end

r = uint8(round(y + 1.402 * (cr - 128)));
g = uint8(round(y - 0.34414 * (cb - 128) - 0.71414 * (cr - 128)));
b = uint8(round(y + 1.772 * (cb - 128)));
    
if nargout == 1
    r = cat(3,r,g,b);
end

return