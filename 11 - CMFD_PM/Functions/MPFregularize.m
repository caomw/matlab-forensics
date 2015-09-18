function [mpf_y,mpf_x] = MPFregularize(mpf_y,mpf_x,DD_med,NN_med)
%regularize offsets field by order-statistic filtering
% [mpf_y,mpf_x] = MPFregularize(mpf_y,mpf_x,DD_med,NN_med)
%
%   mpf_x   column indexes,
%   mpf_y   row indexes,
%   DD_med  the structuring element,
%   NN_med  order of order-statistic filtering.
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
    [xp, yp] = meshgrid(0:(Nc-1),0:(Nr-1));
    mpf_y = ordfilt2(mpf_y-yp,NN_med,DD_med,'symmetric')+yp;
    mpf_x = ordfilt2(mpf_x-xp,NN_med,DD_med,'symmetric')+xp;