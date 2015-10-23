function [imageOut, imageSQ] = simulateNA(imageIn,Q1,k1,k2)

[I, Y] = jpeg_rec(imageIn);
Q2 = imageIn.quant_tables{imageIn.comp_info(1).quant_tbl_no};
% simulate absence of quantization through calibration
% coeffOut = quantize(bdct(double(I(2:end,2:end)) - 128), Q2);
% Itmp  = uint8(ibdct(dequantize(coeffOut, Q2)) + 128);
% [r, c] = size(Itmp);
% I(2:r,2:c) = Itmp(1:r-1,1:c-1);
% coeffOut = quantize(bdct(double(I) - 128), Q1);
if k1 < 5
    k1cal = k1 + 1;
else
    k1cal = k1 - 1;
end
if k2 < 5
    k2cal = k2 + 1;
else
    k2cal = k2 - 1;
end
Ytmp = zeros(imageIn.image_height, imageIn.image_width);
Ytmp(1:end+1-k1cal,1:end+1-k2cal) = Y(k1cal:end,k2cal:end,1);
coeffOut = quantize(bdct(double(Ytmp) - 128), Q1);
imageSQ = imageIn;
imageSQ.coef_arrays{1} = coeffOut;

Ytmp = ibdct(dequantize(coeffOut, Q1)) + 128;
[r,c] = size(Ytmp);
Cbtmp = Y(:,:,2);
Crtmp = Y(:,:,3);
Y = Y(:,:,1);
Y(1:r,1:c) = Ytmp;
I = jfif2rgb(Y, Cbtmp, Crtmp);
[Ytmp, Cbtmp, Crtmp] = rgb2jfif(I);

figure, imshow(I)
k1s = mod(9-k1,8)+1;
k2s = mod(9-k2,8)+1;
Ytmp2 = zeros(size(Ytmp));
Ytmp2(1:end+1-k1s,1:end+1-k2s) = Ytmp(k1s:end,k2s:end);
coeffOut = quantize(bdct(double(Ytmp2) - 128), Q2);
imageOut = imageIn;
imageOut.coef_arrays{1} = coeffOut;

return