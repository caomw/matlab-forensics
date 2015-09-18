function bfdata = FMTpl_bf(SZ, freq_m, radiusNum, anglesNum, freq_n, radiusMin)
%Comupte the Fourier-Mellin Transform functions with log-polar resample
%  bfdata = FMTpl_bf(SZ, freq_m, radiusNum, anglesNum, freq_n, radiusMin);
%
%        SZ is the size of patch
%    freq_m is a vector which indicates m
% radiusNum is the number of sampling points along the radius
% anglesNum is the number of sampling points along the circumferences
%    freq_n is a vector which indicates n
% radiusMin is the minimun radius
%
% bfdata is a structure with the following elements:
%  .number     number of basis functions, 
%  .orders     a matrix with 2 columns, where the first column indicates n and the second column m, 
%  .bf         a 3d matrix with the basis functions, 
%  .factor     factor for ortonormal basis functions, 
%  .freq0      is the frequency step.
%  
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


    if nargin<1 || isempty(SZ)       , SZ        = 24;   end;
    if nargin<2 || isempty(freq_m)   , freq_m    = 0:4;  end;
    if nargin<3 || isempty(radiusNum), radiusNum = 26;   end;
    if nargin<4 || isempty(anglesNum), anglesNum = 32;   end;
    if nargin<5 || isempty(freq_n)   , freq_n    = (1:radiusNum)-1; end;
    if nargin<6 || isempty(radiusMin), radiusMin = sqrt(2); end;
    
    num_freq_m = numel(freq_m);
    num_freq_n = numel(freq_n);
    
    gf = @(x,y) max(0,1-abs(x)).*max(0,1-abs(y)); % linear
    %gf = @(x,y) rectFunc(x).*rectFunc(y);        % nearest
    %gf = @(x,y) exp(-(x.^2+y.^2)./2)./(2*pi());  % gaussian
    
    [X,Y] = meshgrid(1:SZ,1:SZ);
    Y = (2.*Y-SZ-1)./2;
    X = (2.*X-SZ-1)./2;
    
    radiusMax = (SZ-1)/2;
    radiusPoints = (2.^(linspace(log2(radiusMin),log2(radiusMax),radiusNum)));
    
    BF = zeros(SZ,SZ,anglesNum,radiusNum);
    for indexA = 1:anglesNum;
        A  = (indexA-1)*360./anglesNum;
        for indexR = 1:radiusNum;
            R = radiusPoints(indexR);
            pX = X - R*cosd(A);
            pY = Y - R*sind(A);
            J = gf(pX,pY);
            %J = J/sum(J(:)); % correge eventuali imprecisioni;
            BF(:,:,indexA,indexR) = J;
        end;
    end;
    
    BF = fft(BF,[],3)./anglesNum;
    BF = fft(BF,[],4);
    BF = BF(:,:,freq_m+1,mod(freq_n,radiusNum)+1);
    
    [n,m] = meshgrid(freq_n,freq_m);
    WF = ones(num_freq_m,num_freq_n);
    
    bfdata = struct;
    bfdata.number   = num_freq_m*num_freq_n;
    bfdata.orders   = cat(2,n(:),m(:));
    bfdata.bf       = BF;
    bfdata.factor   = WF;
    bfdata.radiusStep  = log(radiusPoints(end))-log(radiusPoints(end-1));
    bfdata.freq0       = 1/(radiusNum*bfdata.radiusStep);
    
    