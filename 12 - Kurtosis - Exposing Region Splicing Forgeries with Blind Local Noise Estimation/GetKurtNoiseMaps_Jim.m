function [ estVDCT, estVHaar, estVRand ] = GetKurtNoiseMaps( im )
    if numel(im)>45*(2^20)
        [ estVDCT, estVHaar, estVRand ] = GetKurtNoiseMaps_lowmem( im );
    else
        [ estVDCT, estVHaar, estVRand ] = GetKurtNoiseMaps_highmem_Jim( im );
    end
end

