function [bfdata,mask] = const_bf(SZ,ORDER)
%Compute the simple CHT functions
%  bfdata = const_bf(SZ,ORDER)
% 
%    SZ is the size of patch
% ORDER is the number of basis functions
%
% bfdata is a structure with the following elements:
%  .number     number of basis functions, 
%  .orders     a matrix with 2 columns, where the first column indicates n and the second column m, 
%  .bf         a 3d matrix with the basis functions, 
%  .factor     factor for ortonormal basis functions. 
%

    NM  = cat(2,zeros(ORDER,1), (0:(ORDER-1))');
    len = size(NM,1);
  
    BF = zeros(SZ,SZ,len);
    WF = zeros(len,1);
   
    [X,Y] = meshgrid(1:SZ,1:SZ);
    rho   =  sqrt( (2.*Y-SZ-1).^2+(2.*X-SZ-1).^2)/SZ;
    theta = atan2(-(2.*Y-SZ-1),   (2.*X-SZ-1));
    mask  = (rho<=1);
    cnt   = sum(mask(:));
    for index = 1:len
        m = NM(index,2);
        BF(:,:,index) = mask.*exp(1i*m*theta);
        WF(index)     = sqrt(1./cnt);
    end;

    % ---- Package the whole thing into a structure
    bfdata = struct;
    bfdata.maxorder = ORDER;
    bfdata.orders   = NM;
    bfdata.bf       = BF;
    bfdata.factor   = WF;
