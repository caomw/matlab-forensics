function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
	[estVDCT, estVHaar] = GetKurtNoiseMaps_Jim(im);
    for ii=1:size(estVDCT,3)
        figure
        imagesc(estVDCT(:,:,ii))
    end
            
end

