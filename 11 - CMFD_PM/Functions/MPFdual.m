function mask = MPFdual(mpf_y,mpf_x,mask)
%Mirroring of the regions.
% mask = MPFdual(mpf_y,mpf_x,mask)
%   mpf_x   column indexes;
%   mpf_y   row indexes;
%   mask    selective mask, with same dimensions of mpf_x
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Copyright (c) 2015 Image Processing Research Group of University Federico II of Naples ('GRIP-UNINA').
% All rights reserved.
% this software should be used, reproduced and modified only for informational and nonprofit purposes.
% 
% By downloading and/or using any of these files, you implicitly agree to all the
% terms of the license, as specified in the document LICENSE.txt
% (included in this package) and online at
% http://www.grip.unina.it/download/LICENSE_OPEN.txt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    [Nr, Nc] = size(mpf_y);  
    if sum(mask(:))>0,
        ind = find(mask==true());
        ind = (round(mpf_y(ind))+Nr*round(mpf_x(ind))+1);
        ind(ind>(Nr*Nc)) = [];
        ind(ind<1) = [];
        mask(ind) = true();
    end;

	