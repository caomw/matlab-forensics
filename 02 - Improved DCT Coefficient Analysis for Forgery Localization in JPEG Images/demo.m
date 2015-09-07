function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    ncomp = 1;
    c1 = 1;
    c2 = 15;
    map = getJmap(im,ncomp,c1,c2);
    imagesc(map);
end

