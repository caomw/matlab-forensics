function [save_map]=expand_map(fusion_map)
    %This function expands the fusion map. Each value of the fusion map is
    %assigned to a block of 8x8 pixel in the save_map
    block_size=8;
    startx=1;
    starty=1;
    [row,col]=size(fusion_map);
    save_map=zeros(row*block_size,col*block_size);
    for i=1:row
        for j=1:col
            save_map(startx+(block_size*(i-1)):block_size*i,starty+(block_size*(j-1)):block_size*j)=fusion_map(i,j);
        end
    end

end