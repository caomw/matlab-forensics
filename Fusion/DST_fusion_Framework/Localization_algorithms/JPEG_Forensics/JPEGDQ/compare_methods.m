function [mask_us, mask_others] = compare_methods(filename, c1, c2)

image = jpeg_read(filename);

maskTampered = getJmap(image, 1, 1, c1);
mask_us = medfilt2(maskTampered, [5 5], 'symmetric');

[mask_us, rect] = imcrop(mask_us);


               
maskTampered = detectionTamperingLCI(image, c2);
mask_others = medfilt2(maskTampered, [5 5], 'symmetric');

mask_others = imcrop(mask_others, rect);

I = imread(filename);
I = imresize(I, 1/2);
I = imcrop(I, rect * 4);
map = colormap('jet');

figure, imshow(I)
h = figure; imshow(mask_us, [])
set(h, 'Colormap', map);
h = figure; imshow(mask_others, [])
set(h, 'Colormap', map);

mask_us = floor(imadjust(mask_us) * 255) + 1;
map_us(:,:,1) = reshape(map(mask_us,1),size(mask_us));
map_us(:,:,2) = reshape(map(mask_us,2),size(mask_us));
map_us(:,:,3) = reshape(map(mask_us,3),size(mask_us));
mask_others = floor(imadjust(mask_others) * 255) + 1;
map_others(:,:,1) = reshape(map(mask_others,1),size(mask_others));
map_others(:,:,2) = reshape(map(mask_others,2),size(mask_others));
map_others(:,:,3) = reshape(map(mask_others,3),size(mask_others));
imwrite(I, 'pic.tif', 'tiff');
imwrite(map_us, 'map_us.tif', 'tiff');
imwrite(map_others, 'map_others.tif', 'tiff');


return