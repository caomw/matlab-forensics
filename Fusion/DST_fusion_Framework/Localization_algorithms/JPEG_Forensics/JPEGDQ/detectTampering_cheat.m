function [mask, img] = detectTampering_cheat(jpeg, c1Y, c2Y, Q1)

image = jpeg_read(jpeg); 

maskTampered = getJmap_cheat(image, 1, c1Y, c2Y, Q1);

% N = 7;
% w = fspecial('gaussian', [N N], N/6);
maskTampered = medfilt2(maskTampered, [5 5]);
% maskTfilt = exp(imfilter(log(maskTampered), w));
% maskUfilt = exp(imfilter(log(1 - maskTampered), w));
% maskTampered = 1 ./ (1 + exp(maskUfilt - maskTfilt));
figure, imagesc(maskTampered,[0.25 0.75]), colorbar
% figure, imagesc(maskTampered > 0.5)

img = imread(jpeg);
m = size(img);
maskbppmlarge = imresize(maskTampered > 0.5,[m(1) m(2)]);
%img(:,:,1) = uint8(double(img(:,:,1)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,1))) .* maskbppmlarge);
%img(:,:,2) = uint8(double(img(:,:,2)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,2))) .* maskbppmlarge);
%img(:,:,3) = uint8(double(img(:,:,3)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,3))) .* maskbppmlarge);
%img(:,:,1) = uint8(double(img(:,:,1)) .* (1 - maskbppmlarge));
img(:,:,2) = uint8(double(img(:,:,2)) .* (1 - maskbppmlarge));
%img(:,:,3) = uint8(double(img(:,:,3)) .* (1 - maskbppmlarge));
figure, imshow(img);



map = colormap;
sizemap = size(map);
mapint = uint8(255*map);

masklarge = imresize(maskTampered,[m(1) m(2)]);
maskint = ceil(masklarge*sizemap(1));
maskint(maskint < 1) = 1;
maskint(maskint > sizemap(1)) = sizemap(1);


c = mapint(:,1);
mask(:,:,1) = c(maskint);
c = mapint(:,2);
mask(:,:,2) = c(maskint);
c = mapint(:,3);
mask(:,:,3) = c(maskint);

return