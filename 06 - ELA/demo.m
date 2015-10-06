function demo( im )
    Quality=90;
    Multiplier=20;
    Flatten=false;
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    Map=ELA(im,Quality,Multiplier,Flatten);
    imshow(uint8(Map));
    
end

