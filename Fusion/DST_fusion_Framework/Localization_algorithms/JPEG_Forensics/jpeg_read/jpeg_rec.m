function [I,YCbCr] = jpeg_rec(image)

% c = [0.299, 0.587, 0.114; -0.168736, -0.331264, 0.5; 0.5, -0.418688, -0.081312];

Y = ibdct(dequantize(image.coef_arrays{1}, image.quant_tables{1}));
Cb = ibdct(dequantize(image.coef_arrays{2}, image.quant_tables{2}));
Cr = ibdct(dequantize(image.coef_arrays{3}, image.quant_tables{2}));

Y = Y + 128;
[r,c] = size(Y);
Cb = kron(Cb,ones(2)) + 128;
Cr = kron(Cr,ones(2)) + 128;
Cb = Cb(1:r,1:c);
Cr = Cr(1:r,1:c);

% R = Y + 1.402 (Cr-128)
% G = Y - 0.34414 (Cb-128) - 0.71414 (Cr-128)
% B = Y + 1.772 (Cb-128)


% I(:,:,1) = uint8(Y + 1.402 * (Cr -128));
% I(:,:,2) = uint8(Y - 0.34414 *  (Cb - 128) - 0.71414 * (Cr - 128));
% I(:,:,3) = uint8(Y + 1.772 * (Cb - 128));

I(:,:,1) = (Y + 1.402 * (Cr -128));
I(:,:,2) = (Y - 0.34414 *  (Cb - 128) - 0.71414 * (Cr - 128));
I(:,:,3) = (Y + 1.772 * (Cb - 128));

YCbCr = cat(3,Y,Cb,Cr);

return