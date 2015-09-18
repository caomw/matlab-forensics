function e = DLFerror(mpf_y,mpf_x,rd)
%Compute the squared error of dense linear fitting
%  e = DLFerror(mpf_y,mpf_x,rd)
%
%   mpf_x   column indexes;
%   mpf_y   row indexes;
%   rd      radius of circular neighborhood.
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


    [EE_mvf,AA_mvf,VV_mvf] = mvfAffineMtx2Error(rd);
    e = quadfilt_err(mpf_y,VV_mvf)+quadfilt_err(mpf_x,VV_mvf);
    
function y = quadfilt_err(x,V)  
    y = imfilter(x.^2,V(:,:,1),'symmetric') - ( ...
        imfilter(x,V(:,:,2),'symmetric').^2 + ...
        imfilter(x,V(:,:,3),'symmetric').^2 + ...
        imfilter(x,V(:,:,4),'symmetric').^2 );