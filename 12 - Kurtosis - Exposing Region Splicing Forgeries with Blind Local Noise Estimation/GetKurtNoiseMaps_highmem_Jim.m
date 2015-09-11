function [ estVDCT, estVHaar, estVRand ] = GetKurtNoiseMaps_highmem_Jim( im )
    %GETKURTNOISEMAPS Summary of this function goes here
    %   Detailed explanation goes here
    sz = 3; % size of the pre-smoothing filters
    sigs = [6]; %[2 4 8]; % size of sliding window    
    
    im=double(rgb2ycbcr(im));
    im=im(:,:,1);

    flt = ones(sz,1);
    flt = flt*flt'/sz^2;
    noiIm = conv2(im,flt,'same');
    
    estVDCT = zeros([round(size(im)/4),length(sigs)],'single');
    estVHaar = zeros([round(size(im)/4),length(sigs)],'single');
    estVRand = zeros([round(size(im)/4),length(sigs)],'single');
    for k = 1:length(sigs)
        estVDCT_tmp=localNoiVarEstimate_highmem(noiIm,'dct',4,sigs(k));
        estVDCT(:,:,k)=imresize(single(estVDCT_tmp),round(size(estVDCT_tmp)/4),'method','box');
        %estVHaar_tmp = localNoiVarEstimate_highmem(noiIm,'haar',4,sigs(k));
        %estVHaar(:,:,k) = imresize(single(estVHaar_tmp),round(size(estVHaar_tmp)/4),'method','box');
        %estVRand_tmp=localNoiVarEstimate_highmem(noiIm,'rand',4,sigs(k));
        %estVRand(:,:,k) = imresize(single(estVRand_tmp),round(size(estVRand_tmp)/4),'method','box');
    end

    estVDCT(estVDCT<=0.001)=single(mean(mean(mean(estVDCT))));
    %estVHaar(estVHaar<=0.001)=single(mean(mean(mean(estVHaar))));
    %estVRand(estVRand<=0.001)=single(mean(mean(mean(estVRand))));
   
end

