function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    % dimension of statistics
    Nb = [2, 8];
    % number of cumulated bloks
    Ns = 1;
    toCrop=mod(size(im),2);
    im=im(1:end-toCrop(1),1:end-toCrop(2),:);
    
    [bayer, F1]=GetCFASimple(im);
    
    
    for j = 1:2
        [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
        figure;
        imagesc(map);
        
    end
    
end

