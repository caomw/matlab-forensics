function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    c2 = 6;
    
    [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
    map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    figure
    imagesc(map_final);
    [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
    map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    figure
    imagesc(map_final);
    
end