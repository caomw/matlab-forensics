function [LLRmap2] = smooth_unshift(LLRmap,k1,k2)

LLRmap = imfilter(LLRmap, ones(3), 'symmetric', 'full');

LLRmap_big = zeros(8*size(LLRmap));
LLRmap_big(1:8:end,1:8:end) = LLRmap;
bil = conv2(ones(8), ones(8))/64;
LLRmap_big = imfilter(LLRmap_big, bil, 'full');
LLRmap2 = LLRmap_big(16-k1:8:end-16-k1,16-k2:8:end-16-k2);

return