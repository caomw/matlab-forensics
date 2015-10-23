function [y, compIdx] = random(obj,n)
%RANDOM Random vector generation. 
%   Y = RANDOM(OBJ) generates an random row vector Y drawn from the
%    Gaussian mixture distribution with parameters given by OBJ.
%
%   Y = RANDOM(OBJ,N) generates an N-by-D matrix Y. Each row of Y is a
%   random vector drawn from the Gaussian mixture distribution with
%   parameters given by OBJ.
%
%   [Y, COMPIDX] = RANDOM(OBJ,N) returns an N-by-1 vector COMPIDX
%   which contains the index of the component used to generate each row of
%   Y.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:25 $

if nargin < 2 || isempty(n)
    n = 1;
end

covNames = { 'diagonal','full'};
CovType = strmatch(lower(obj.CovType),covNames);

if CovType==2 %full covariance
    [y, compIdx] = gmrnd(obj.mu,obj.Sigma,obj.PComponents,n);
else %diagonal covariance
    if obj.SharedCov
           [y, compIdx] =gmrnd(obj.mu,diag(sparse(obj.Sigma)),obj.PComponents,n);
    else %different covariance for each component
        Sigma=zeros(obj.NDimensions,obj.NDimensions,obj.NComponents);
        for j=1:obj.NComponents
            Sigma(:,:,j)=diag(sparse(obj.Sigma(:,:,j)));
        end
        [y, compIdx] = gmrnd(obj.mu,Sigma,obj.PComponents,n);
    end

end