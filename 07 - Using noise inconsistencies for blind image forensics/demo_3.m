
filename = 'canonxt_kodakdcs330_sub_01.tif';
% set parameters
BlockSize=32;

im = CleanUpImage(filename);

map = GetNoiseMap(im, BlockSize);

figure(1);
subplot(1,2,1)
image(im)
subplot(1,2,2)
imagesc(map)

min(min(map))
max(max(map))

dot=strfind(filename,'.');
outfile=filename(1:dot-1);
map=map/20*63;
map(map>63)=63;
resized=imresize(map,[size(im,1), size(im,2)],'nearest');
resized(resized>63)=63;
imwrite(resized,jet,[outfile '_nearest.png']);
resized=imresize(map,[size(im,1), size(im,2)]);
resized(resized>63)=63;
imwrite(resized,jet,[outfile '_interp.png']);