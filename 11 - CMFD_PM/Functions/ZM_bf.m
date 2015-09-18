function bfdata = ZM_bf(SZ,ORDER)
%Comupte the Zernike momente functions
%  bfdata = ZM_bf(SZ,ORDER)
%  bfdata = ZM_bf(SZ,NM)
% 
%    SZ is the size of patch
% ORDER is the order of Zernike momente
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
    if nargin<2 || isempty(ORDER), ORDER     = 5;  end;
    
    if isscalar(ORDER),
        NM  = ZM_orderlist(ORDER);
    else
        NM  = ORDER;
    end;
    len   = size(NM,1);
  
    BF = zeros(SZ,SZ,len);
    WF = zeros(len,1);
    
    F = factorial(0:max(NM(:,1)));

    [X,Y] = meshgrid(1:SZ,1:SZ);
    rho   =  sqrt( (2.*Y-SZ-1).^2+(2.*X-SZ-1).^2)/SZ;
    theta = atan2(-(2.*Y-SZ-1),   (2.*X-SZ-1));
    mask  = (rho<=1);
    cnt   = sum(mask(:));
    for index = 1:len
        n = NM(index,1);
        m = NM(index,2);

        Rad = zeros(size(rho));
        tu = floor((n+abs(m))/2);
        td = floor((n-abs(m))/2);
        for s = 0:td,
           c = ( ((-1).^s) .* F(1+n-s) )./ (F(1+s).*F(1+tu-s).*F(1+td-s));
           Rad = Rad + c.*(rho.^(n-2*s));
        end; 

        BF(:,:,index) = mask.*Rad.*exp(1i*m*theta);
        WF(index)      = sqrt((n+1)./cnt);
    end;
    
    bfdata = struct;
    bfdata.number   = size(NM,1);
    bfdata.orders   = NM;
    bfdata.bf       = BF;
    bfdata.factor   = WF;

