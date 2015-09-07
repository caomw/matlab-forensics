function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
	[estVDCT, estVHaar, estVRand] = GetKurtNoiseMaps(im);
    for ii=1:size(estVDCT,3)
        figure
        imagesc(estVDCT(:,:,ii))
    end
            
    for ii=1:size(estVHaar,3)
        figure
        imagesc(estVHaar(:,:,ii))
    end
    for ii=1:size(estVRand,3)
        figure
        imagesc(estVRand(:,:,ii))
    end
    
end

