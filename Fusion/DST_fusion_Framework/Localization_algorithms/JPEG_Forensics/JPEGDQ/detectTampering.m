function [mask, img] = detectTampering(jpeg, c1Y, c2Y, c1C, c2C)

image = jpeg_read(jpeg); 

if nargin == 5
    maskTamperedY = getJmap(image, 1, c1Y, c2Y);
    maskTamperedCb = getJmap(image, 2, c1C, c2C);
    maskTamperedCr = getJmap(image, 3, c1C, c2C);

    [rY,cY] = size(maskTamperedY);
    hRC = image.comp_info(1).h_samp_factor;
    vRC = image.comp_info(1).v_samp_factor;

    maskTamperedCb = kron(maskTamperedCb, ones(vRC,hRC));
    maskTamperedCr = kron(maskTamperedCr, ones(vRC,hRC));

    maskTampered = maskTamperedY .* maskTamperedCb(1:rY,1:cY) .* maskTamperedCr(1:rY,1:cY);
    maskUntampered = (1 - maskTamperedY) .* (1 - maskTamperedCb(1:rY,1:cY)) .* (1 - maskTamperedCr(1:rY,1:cY));
    maskTampered = maskTampered ./ (maskTampered + maskUntampered);
else
    maskTampered = getJmap_rel(image, 1, c1Y, c2Y);
%     maskTampered = getJmap_plus(image, 1, c1Y, c2Y);
end

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