function y = bf_filter(x,bfdata)
% filtering bank
%  y = bf_filter(x,bfdata)
%
% x      is a 2d matrix
% bfdata is the filter bank, it is a structure with the following elements:
%  .number     number of filters, 
%  .bf         a 3d matrix with the filters, 
%  .factor     factor of the filters. 
%

    len = bfdata.number;
    y   = zeros(cat(2,size(x),len));
    for index = 1:len,
        y(:,:,index) = (bfdata.factor(index))*imfilter(x, conj(bfdata.bf(:,:,index)));
    end
