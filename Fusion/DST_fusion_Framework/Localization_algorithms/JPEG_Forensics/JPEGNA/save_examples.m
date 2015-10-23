

im = jpeg_read('../JPEGDQ/examples/florence2_tamp95_7_3.jpg');

% [k1e,k2e,Q] = estimateNA(im,1);
% [LLRmap_s, q1table, alpha] = getJmapNA_EM_oracle(im,1,15,k1e,k2e,true);
[LLRmap, LLRmap_s, q1table, k1e, k2e, alphatable] = getJmapNA_EM(im,1,3);
map = LLRmap_s;
mask = smooth_unshift(sum(map,3),k1e,k2e);

figure, imagesc(mask, [-60 60]), axis equal
pause

figure, imshow('../JPEGDQ/examples/florence2_tamp.jpg')

save_mask(mask,'test/florence_mapNA.png',-60,60)


addpath('../JPEGDQ');
[LLRmap, LLRmap_s, q1table, alphatable] = getJmap_EM(im,1,21);
map = LLRmap_s;
mask = imfilter(sum(map,3), ones(3), 'symmetric', 'same');

save_mask(mask,'test/florence_mapA.png',-60,60)


im = jpeg_read('../JPEGDQ/examples/redcar_90_tamp95.jpg');

[LLRmap, LLRmap_s, q1table, k1e, k2e, alphatable] = getJmapNA_EM(im,1,6);
map = LLRmap_s;
mask = smooth_unshift(sum(map,3),k1e,k2e);

% figure, imagesc(mask, [-60 60]), axis equal

figure, imshow('../JPEGDQ/examples/redcar_90_tamp95.jpg')

save_mask(mask,'test/redcar_mapNA.png',-60,60)


addpath('../JPEGDQ');
[LLRmap, LLRmap_s, q1table, alphatable] = getJmap_EM(im,1,21);
map = LLRmap_s;
mask = imfilter(sum(map,3), ones(3), 'symmetric', 'same');

save_mask(mask,'test/redcar_mapA.png',-60,60)