function demo(directory)
    %This script executes the Fusion Framework on a set of images saved in the input directory:
    if nargin<1
        directory='tamper_images/';
    end

    %Run the fusion framework
    fusion_framework(directory);

    %Threshold in [0,1] for binarization of forgery map (higher threshold decrease false positives but also true positives)
    thresh=0.7;
    % Run the segmentation module
    segmentation_module(directory,thresh);
end