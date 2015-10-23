function[cut, bbox] = takeCenterBlock(fname, blocksize, align)
%function[cut, bbox] = takeCenterBlock(fname, blocksize, align)
%This function automatically crops a centered subpart of the image in file
%fname. The centered subpart size is specified in the two dimensional
%vector blocksize. 
%Furthermore, this function return a bounding box that identify the central
%portion of the CROPPED (NOT ORIGINAL!) image (1/4 of the size in height and width). 
%Optionally, this bounding box can be aligned to the 8x8 grid.
%
%---- INPUT ARGS ----
%-> fname: file name, must point to an image...
%-> blocksize: two-dimensional integer array [height width]
%-> OPTIOANL align: set to 'align' to get cutted part aligned to the 8x8
    %grid
%
%---- OUTPUT ARGS ----
%-> cut: cropped image
%-> bbox: bounding box for the

        I = imread(fname);
        [h,w,dummy] = size(I);
        if sum([h w] < blocksize)>0
            warning('Image is smaller than sub-block: returning original matrix.');
            cut = I;            
        else
            % cut center part (test_size)
            p1 = floor(([h w] - blocksize)/2) + 1;
            p2 = p1 + blocksize - 1;
            cut = I(p1(1):p2(1),p1(2):p2(2),:);
        end
        %return centered bounding box of size 1/4, whit grid aligned to the
        %8x8
        [h,w,dummy] = size(cut);
        blocksize = [floor(h/4) floor(w/4)];
        % cut center part (test_size)
        p1 = floor(([h w] - blocksize)/2) + 1;
        
        bbox = [p1(2) p1(1) blocksize(2) blocksize(1)];
        if nargin>2 && strcmpi(align,'align')
            %align to 8x8 grid
               x = bbox(1); 
               y = bbox(2);
               w = bbox(3);
               h = bbox(4);                      
               % bounding box aligned to grid & multiple of 8
               x = floor(ceil(x)/8)*8 + 1;
               y = floor(ceil(y)/8)*8 + 1;
               w = floor(w/8)*8;
               h = floor(h/8)*8;
               bbox = [x y w h];
        end
end