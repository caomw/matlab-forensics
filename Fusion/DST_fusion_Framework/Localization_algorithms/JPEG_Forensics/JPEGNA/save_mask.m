function [] = save_mask(mask,filename,mlow,mhigh)

cmap = colormap('jet');
masknorm = (mask - mlow)/(mhigh - mlow);
masknorm(masknorm < 0) = 0;
masknorm(masknorm > 1) = 1;
masknorm = round(masknorm*63)+1;
maskimage = cmap([masknorm masknorm+64 masknorm+128]);
maskimage = reshape(maskimage,[size(masknorm) 3]);
maskimage = imresize(maskimage, 8, 'nearest');

figure, imshow(maskimage)

imwrite(maskimage, filename, 'png')

return