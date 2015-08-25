% description:
%  This package includes the basic code for blind noise variance esimation
%  and blind local noise variance estimation as described in the reference. 
%
% reference:
%   X.Pan, X.Zhang and S.Lyu, Exposing Image Splicing with
%   Inconsistent Local Noise Variances, IEEE International
%   Conference on Computational Photography, Seattle, WA, 2012
%
% disclaimer:
%   This work is the intellectual property of SUNY Research Foundation.
%   This code is for research purpose only and is provided "as it is".
%   Neither the authors of the publication or the SUNY Research Foundation
%   are responsible for any liability related with this code 
%
% Xunyu Pan, Xing Zhang, Siwei Lyu -- 07/26/2012             

% simple demos of the global and local noise variance estimation
demoGlobalNoiEst.m
demoLocalNoiEst.m

% main code performing global and local noise variance estimation
globalNoiVarEstimate.m
localNoiVarEstimate.m

% utility code
dct2mtx.m
haar2mtx.m
rnd2mtx.m
block_avg.m
vec.m
