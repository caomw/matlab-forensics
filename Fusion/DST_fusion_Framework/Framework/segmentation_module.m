function segmentation_module(directory,thresh)
%This function generates the png binary image with the the Synergetic image
%Segmentation (edison matlab interface). This function searches for all the
%.mat files in the directory. 

filter_type = 'median';

    if ispc
        addpath('edison_matlab_interface\');
    else
        addpath('edison_matlab_interface/');
    end
    
    if(strcmp(filter_type,'mean')==0)
        type=0;
    else
        type=1;
    end


    %list all the .mat files
    img_list=dir([directory '*.mat']);
    
    for j=1:size(img_list)
        original_name=char(img_list(j).name);
        load([directory original_name]);        
        fprintf('Load images %d/%d \n',j,size(img_list,1));
        img=imread([directory original_name(1:end-4)]);
        img=img(:,:,1:3);
        disp('Apply the segmentation');
        %Synergetic Image segmentation
        [fimage labels modes regSize grad conf] = edison_wrapper(img,@RGB2Luv,'steps',2,'SpatialBandWidth',7,'RangeBandWidth',6,'MinimumRegionArea',70,...
        'GradientWindowRadius',5,'MixtureParameter',0.3,'EdgeStrengthThreshold',0.55);
        %Let the label images start from 1 instead of 0
        labels=labels+1;
        maximum_label=max(labels(:));
        minimum_label=min(labels(:));

        %expand the BELT map of the image to fit the real dimension of the
        %image.
        [expanded_map]=expand_map(belt_map);
        expanded_map_cut=expanded_map(1:size(img,1),1:size(img,2));
        segmentation_mask=zeros(size(labels,1),size(labels,2));
        for i=minimum_label:maximum_label
            if(type==0)
                if(sum(expanded_map_cut(labels==i))/length(expanded_map_cut(labels==i))>thresh)            
                    segmentation_mask(labels==i)=1;
                end
            else
                if(median(expanded_map_cut(labels==i))>thresh)
                    segmentation_mask(labels==i)=1;
                end                
            end
        end
        nome=[original_name '.png'];
        imwrite(segmentation_mask,[directory nome],'png');        
    end
end
