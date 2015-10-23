function[reflected] = PadOrCrop(img, target)
%function[reflected] = PadOrCrop(img, target)
%This function take the image (either RGB or grayscale) and adapt it to
%have size equal to that specified in target.
%If the target value for the image dimension is smaller than the actual,
%the algorithm crops the central part of the image;
%If the target value for the image dimension is bigger than the actual, the
%algorithm perform a reflective padding along that dimension.
%
%--- INPUT ARGS ---
%-> img: starting image (RGB or grayscale)
%-> target: 1-by-2 array of target dimensions
%
%--- OUTPUT ARGS ---
%-> reflected: adapted image

offset(2) = round((target(2)-size(img,2))/2);
offset(1) = round((target(1)-size(img,1))/2);
W = size(img,1);
H = size(img,2);
CH = size(img,3);

reflected = zeros(size(img,1)+2*offset(1) , size(img,2)+2*offset(2), CH);

%assert(prod(offset)>0,'[Error]: cannot perform mixed cropping and extension');

if offset(1)<0
    if offset(2)<0
        reflected = img(-offset(1)+1:end+offset(1),-offset(2)+1:end+offset(2),:);
        reflected = minor_fix(reflected,target);
        return;
    else
        reflected(:,offset(2)+1: H+offset(2),:) = img(-offset(1)+1:end+offset(1),:,:);  
        reflected(:,1:offset(2),:) = reflected(:, offset(2)*2:-1:offset(2)+1,:);
        reflected(:,end-offset(2)-1:end,:) = reflected(:,end-offset(2):-1:end-2*offset(2)-1,:,:);            
    end
else
    if offset(2)<0
        reflected(offset(1)+1: W+offset(1) , :, :) = img(:,-offset(2)+1:end+offset(2),:);
        reflected(1:offset(1),:,:) = reflected(offset(1)*2:-1:offset(1)+1,:,:);    
        reflected(end-offset(1)-1:end,:,:) = reflected(end-offset(1):-1:end-2*offset(1)-1,:,:);        
    else
        reflected(offset(1)+1: W+offset(1) , offset(2)+1: H+offset(2), :) = img;
        reflected(1:offset(1),:,:) = reflected(offset(1)*2:-1:offset(1)+1,:,:);    
        reflected(end-offset(1)-1:end,:,:) = reflected(end-offset(1):-1:end-2*offset(1)-1,:,:);
        reflected(:,1:offset(2),:) = reflected(:, offset(2)*2:-1:offset(2)+1,:);
        reflected(:,end-offset(2)-1:end,:) = reflected(:,end-offset(2):-1:end-2*offset(2)-1,:,:);            
    end
end
    reflected = minor_fix(reflected,target);
    return;
end

function[fixed] = minor_fix(array, trgdim)
    if size(array,1)>trgdim(1)
        array = array(1:end-1,:,:);
    elseif size(array,1)<trgdim(1)
        array(end+1,:,:) = array(end,:,:);
    end   
    
    if size(array,2)>trgdim(2)
        array = array(:,1:end-1,:);
    elseif size(array,2)<trgdim(2)
        array(:,end+1,:) = array(:,end,:);
    end  
    fixed=array;
end