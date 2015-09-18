function [E,A,V] = mvfAffineMtx2Error(r)
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


    [X,Y] = meshgrid(-r:r,-r:r);
    D = double((X.^2+Y.^2)<=(r^2)); D = D(:);
    M = D(:)*(D');
    x = (cat(2,X(:),Y(:),ones(numel(X),1)))';
    x = x.*repmat(D',[3,1]);
    B = (x')/(x*(x')); %pinv(x)
    A = B*x; A = M.*(A+A')/2;
    E = diag(D)-A;
    
    if nargout>2,
        [V,S] = eig(A);
        V = V(:,find(diag(S>0.5)));
        V = cat(2,D,V);
        V = reshape(V,[2*r+1,2*r+1,4]);
    end;
    
    