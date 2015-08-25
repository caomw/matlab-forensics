function [Feature_Vector, OutputMap, coeffArray] = Extract_Features( im )
% Mark Zampoglou
% Implementation of  "Fast, automatic and fine-grained tampered JPEG image
% detection via DCT coefficient analysis" by Lin et al

Display=false;

if isstruct(im)
     [Feature_Vector, OutputMap, coeffArray] = Extract_Features_JPEG( im, Display )
else
    [Feature_Vector, OutputMap, coeffArray] = Extract_Features_NonJPEG( im, Display )
end


end

