function [mask,param,outData] = CMFD_PM(img,param)
% [mask,param] = CMFD_PM(img,param)
%This code is the version 1.0 of the CMFD (Copy-Move Forgery Detection)
%   algorithm described in "Efficient dense-field copy-move forgery detection", 
%   written by  D. Cozzolino, G. Poggi and L. Verdoliva, 
%   IEEE Trans. on Information Forensics and Security, in press, 2015.
%   Please refer to this paper for a more detailed description of
%   the algorithm.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Copyright (c) 2015 Image Processing Research Group of University Federico II of Naples ('GRIP-UNINA').
% All rights reserved.
% This work should only be used for nonprofit purposes.
% 
% By downloading and/or using any of these files, you implicitly agree to all the
% terms of the license, as specified in the document LICENSE.txt
% (included in this package) and online at
% http://www.grip.unina.it/download/LICENSE_OPEN.txt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% parameters 
% parameters Feature Extraction
if nargin<2 || isempty(param), param = struct(); end;
param = setParameters(param,'type_feat',2); % type of feature, one of the following:
    % 1) ZM-cart
    % 2) ZM-polar 
    % 3) PCT-cart
    % 4) PCT-polar
    % 5) FMT (log-polar)

diameter_feat = {16,16,16,16,24}; 
param = setParameters(param,'diameter',diameter_feat{param.type_feat}); % patch diameter
param = setParameters(param,'ZM_order',5);
param = setParameters(param,'PCT_NM', [0,0;0,1;0,2;0,3; 1,0;1,1;1,2;2,0;2,1;3,0]);
param = setParameters(param,'FMT_N', -2:2); 
param = setParameters(param,'FMT_M',  0:4);
param = setParameters(param,'radiusNum', 26); % number of sampling points along the radius
param = setParameters(param,'anglesNum', 32); % number of sampling points along the circumferences
param = setParameters(param,'radiusMin',sqrt(2)); % minimun radius for FMT

% parameters Matching
param = setParameters(param,'num_iter', 8); % N_{it} = number of iterations
param = setParameters(param,'th_dist1', 8); % T_{D1} = minimum length of offsets
param = setParameters(param,'num_tile', 1); % number of thread

% parameters Post Processing
param = setParameters(param,'th2_dist2', 50*50); % T^2_{D2} = minimum diatance between clones
param = setParameters(param,'th2_dlf'  ,  300);  % T^2_{\epsion} = threshold on DLF error
param = setParameters(param,'th_sizeA' , 1200);  % T_{S} = minimum size of clones
param = setParameters(param,'th_sizeB' , param.th_sizeA);  % T_{S} = minimum size of clones
param = setParameters(param,'rd_median', 4);     % \rho_M = radius of median filter
param = setParameters(param,'rd_dlf'   , 6);     % \rho_N = radius of DLF patch
param = setParameters(param,'rd_dil'   , param.rd_dlf+param.rd_median); % \rho_D = radius for dilatetion


%% Techique
if not(exist('vecnnmex_mod')),
    addpath(fullfile(fileparts(mfilename('fullpath')),'Functions'));
end;
if ischar(img), img = imread(img); end;

outData = struct();
img = color2gray(img); 
fprintf('START\n'); drawnow();

% (1) Feature Extraction
timestamp = tic();
    % generation of filters
    if param.type_feat==1,
        outData.feat_name = 'ZM-cart';
        bfdata = ZM_bf(param.diameter, param.ZM_order); 
    elseif param.type_feat==2,
        outData.feat_name = 'ZM-polar';
        bfdata = ZMp_bf(param.diameter, param.ZM_order, param.radiusNum, param.anglesNum);
    elseif param.type_feat==3,
        outData.feat_name = 'PCT-cart';
        bfdata = PCT_bf(param.diameter, param.PCT_NM);
    elseif param.type_feat==4,
        outData.feat_name = 'PCT-polar';
        bfdata = PCTp_bf(param.diameter, param.PCT_NM, param.radiusNum, param.anglesNum);
    elseif param.type_feat==5,
        outData.feat_name = 'FMT';
        bfdata = FMTpl_bf(param.diameter, param.FMT_M, param.radiusNum, param.anglesNum, param.FMT_N, param.radiusMin);
    else
        error('type of feature not found');
    end;  
    % feature generation
    feat = abs(bf_filter(img, bfdata));

    % cutting off the borders
    raggioU =  ceil((param.diameter-1)/2);
    raggioL = floor((param.diameter-1)/2);
    feat = feat((1+raggioU):(end-raggioL),(1+raggioU):(end-raggioL),:); 
outData.timeFE = toc(timestamp);
fprintf('time FE: %0.3f\n',outData.timeFE); drawnow();

%% Matching
timestamp = tic();
    feat  = (feat-min(feat(:)))./(max(feat(:))-min(feat(:))); %mPM requires the features to be in [0,1]
    cnn   = vecnnmex_mod(feat, feat, 1, param.num_iter, -param.th_dist1, param.num_tile);
    mpf_y = double(cnn(:,:,2,1));
    mpf_x = double(cnn(:,:,1,1));
outData.timeMP = toc(timestamp);
fprintf('time PM: %0.3f\n',outData.timeMP); drawnow();
outData.cnn = cnn;

%% Post Processing
timestamp = tic();
    % regularize offsets field by median filtering
    [DD_med, NN_med] = genDisk(param.rd_median); NN_med = (NN_med+1)/2;
    [ mpf_y,  mpf_x] = MPFregularize(mpf_y,mpf_x,DD_med,NN_med);

    % Compute the squared error of dense linear fitting
    DLFerr  =  DLFerror(mpf_y,mpf_x,param.rd_dlf);
    mask    = (DLFerr<=param.th2_dlf);
    outData.maskDLF =  mask;
    
    % removal of close couples
    dist2 = MPFspacedist2(mpf_y,mpf_x);
    mask  = mask & (dist2>=param.th2_dist2);

    % morphological operations
    mask  = bwareaopen(mask,param.th_sizeA,8); 
    outData.maskMPF = mask;
    mask  = MPFdual(mpf_y,mpf_x,mask); % mirroring of detected regions
    mask  = bwareaopen(mask,param.th_sizeB,8);
    mask  = imdilate(mask,strel('disk',param.rd_dil));
    
    % put the borders
    mask = padarray_both(mask,[raggioU,raggioU,raggioL,raggioL],false()); 
    DLFerr = padarray_both(DLFerr,[raggioU,raggioU,raggioL,raggioL],0); 

outData.timePP = toc(timestamp);
fprintf('time PP: %0.3f\n',outData.timePP); drawnow();
outData.cnn_end = cat(3,mpf_x,mpf_y);
outData.DLFerr  = DLFerr;

%% end
fprintf('END : %0.3f\n',outData.timeFE+outData.timeMP+outData.timePP); drawnow();

function param = setParameters(param,name,value)
   if not(isfield(param,name)) || isempty(getfield(param,name))
      param = setfield(param,name,value);
   end;