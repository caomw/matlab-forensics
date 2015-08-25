
filename = 'Classe2_Q1_080_Q2_100_P1010345.jpg';


imJPG = jpeg_read(filename);
imRaw = CleanUpImage(filename);
map1 = GetBlockArtifact(imJPG);
map2 = GetBlockArtifact(imRaw);
%figure
%subplot(1,2,1)
%image(im)
%subplot(1,2,2)
%imagesc(map)

%disp([min(min(map)) max(max(map))]);