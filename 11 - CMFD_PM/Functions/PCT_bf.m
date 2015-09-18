function bfdata = PCT_bf(SZ,ORDER)
%Comupte the Polar Cosine Transform functions
%  bfdata = PCT_bf(SZ,NM)
% 
%    SZ is the size of patch
%    NM is a matrix with 2 columns, where the first column indicates n and the second column m.
%
% bfdata is a structure with the following elements:
%  .number     number of basis functions, 
%  .orders     a matrix with 2 columns, where the first column indicates n and the second column m, 
%  .bf         a 3d matrix with the basis functions, 
%  .factor     factor for ortonormal basis functions. 
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

    if nargin<1 || isempty(SZ)   , SZ        = 16; end;
    if nargin<2 || isempty(ORDER), ORDER     = 3;  end;
    
    if isscalar(ORDER),
        [n,m] = meshgrid(0:(ORDER-1),0:(ORDER-1));
        NM  = cat(2,n(:),m(:));
    else
        NM  = ORDER;
    end;
    len   = size(NM,1);
    ORDER = max(NM(:,1));
  
    BF = zeros(SZ,SZ,len);
    WF = zeros(len,1);
   


    [X,Y] = meshgrid(1:SZ,1:SZ);
    rho2  = ((2.*Y-SZ-1).^2+(2.*X-SZ-1).^2)/(SZ.^2);
    theta = atan2(-(2.*Y-SZ-1),   (2.*X-SZ-1));
    mask  = (rho2<=1);
    cnt   = sum(mask(:));
    for index = 1:len
        n = NM(index,1);
        m = NM(index,2);
        
        BF(:,:,index) = mask.*cos(pi()*n*rho2).*exp(1i*m*theta);
        WF(index)      = (((n>0)+1)./cnt);
    end;
    
    bfdata = struct;
    bfdata.number   = size(NM,1);
    bfdata.orders   = NM;
    bfdata.bf       = BF;
    bfdata.factor   = WF;

