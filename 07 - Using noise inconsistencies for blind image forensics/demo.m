function demo( im)
    BlockSize=8;
    map = GetNoiseMap(im, BlockSize);
    imagesc(map);
    
end

