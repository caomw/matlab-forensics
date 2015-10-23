function [imageOut] = simulateDQ(imageIn,Q1)

[I, Y] = jpeg_rec(imageIn);
Q2 = imageIn.quant_tables{imageIn.comp_info(1).quant_tbl_no};
% simulate absence of quantization through calibration
% coeffOut = quantize(bdct(double(I(2:end,2:end)) - 128), Q2);
% Itmp  = uint8(ibdct(dequantize(coeffOut, Q2)) + 128);
% [r, c] = size(Itmp);
% I(2:r,2:c) = Itmp(1:r-1,1:c-1);
% coeffOut = quantize(bdct(double(I) - 128), Q1);
coeffOut = quantize(bdct(double(Y(2:end,2:end,1)) - 128), Q1);
Ytmp = ibdct(dequantize(coeffOut, Q1)) + 128;
[r,c] = size(Ytmp);
Cbtmp = Y(:,:,2);
Crtmp = Y(:,:,3);
Y = Y(:,:,1);
Y(1:r,1:c) = Ytmp;
I = jfif2rgb(Y, Cbtmp, Crtmp);
[Ytmp, Cbtmp, Crtmp] = rgb2jfif(I);

% figure, imshow(Itmp)

coeffOut = quantize(bdct(double(Ytmp) - 128), Q2);
imageOut = imageIn;
imageOut.coef_arrays{1} = coeffOut;

return