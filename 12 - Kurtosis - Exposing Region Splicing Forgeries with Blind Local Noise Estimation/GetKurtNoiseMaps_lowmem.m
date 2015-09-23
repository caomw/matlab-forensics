function [ estVDCT, estVHaar, estVRand ] = GetKurtNoiseMaps_lowmem( im )
    %GETKURTNOISEMAPS Summary of this function goes here
    %   Detailed explanation goes here
    sz = 3; % size of the pre-smoothing filters
    sigs = [4 8]; %[2 4 8]; % size of sliding window    
    
    im=double(rgb2ycbcr(im));
    im=im(:,:,1);

    flt = ones(sz,1);
    flt = flt*flt'/sz^2;
    noiIm = conv2(im,flt,'same');
    
    estVDCT = zeros([round(size(im)/4),length(sigs)],'single');
    save('estVDCT.mat','estVDCT');
    clear estVDCT
    estVHaar = zeros([round(size(im)/4),length(sigs)],'single');
    save('estVHaar.mat','estVHaar');
    clear estVHaar
    estVRand = zeros([round(size(im)/4),length(sigs)],'single');
    save('estVRand.mat','estVRand');
    clear estVRand
    for k = 1:length(sigs)
        estVDCT_tmp=localNoiVarEstimate_lowmem(noiIm,'dct',4,sigs(k));
        load('estVDCT.mat');
        estVDCT(:,:,k)=imresize(single(estVDCT_tmp),round(size(estVDCT_tmp)/4),'method','box');
        clear estVDCT_tmp        
        save('estVDCT.mat','estVDCT');
        clear estVDCT
        estVHaar_tmp = localNoiVarEstimate_lowmem(noiIm,'haar',4,sigs(k));
        load('estVHaar.mat');        
        estVHaar(:,:,k) = imresize(single(estVHaar_tmp),round(size(estVHaar_tmp)/4),'method','box');
        clear estVHaar_tmp
        save('estVHaar.mat','estVHaar');
        clear estVHaar
        %estVRand_tmp=localNoiVarEstimate_lowmem(noiIm,'rand',4,sigs(k));
        %load('estVRand.mat');       
        %estVRand(:,:,k) = imresize(single(estVRand_tmp),round(size(estVRand_tmp)/4),'method','box');
        %clear estVRand_tmp
        %save('estVRand.mat','estVRand');
        %clear estVRand        
    end

    load('estVDCT.mat');
    load('estVHaar.mat');     
    load('estVRand.mat');  
    
    estVDCT(estVDCT<=0.001)=single(mean(mean(mean(estVDCT))));
    estVHaar(estVHaar<=0.001)=single(mean(mean(mean(estVHaar))));
    estVRand(estVRand<=0.001)=single(mean(mean(mean(estVRand))));
   
    delete('estVDCT.mat','estVHaar.mat','estVRand.mat');
    
end

