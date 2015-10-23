function y=cdf(obj,X)
%CDF CDF for the Gaussian mixture distribution.
%   Y=CDF(OBJ,X) returns Y, a vector of length N containing the values of
%   the cumulative distribution function (CDF) for the gmdistribution OBJ,
%   evaluated at the N-by-D data matrix X. Rows of X correspond to points,
%   columns correspond to variables. Y(I) is the cdf value of point I.
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/PDF.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/14 05:26:12 $

% Check for valid input

if nargin ~= 2
    error('stats:gmdistribution:cdf:TooFewInputs',...
       'Two input arguments are required.');
end

checkdata(X,obj);

covNames = { 'diagonal','full'};
CovType = strmatch(lower(obj.CovType),covNames);

y = zeros(size(X,1),1);
if obj.SharedCov
    if CovType==1 %diagonal covariance
        for j=1:obj.NComponents
            c = normcdf(X(:,1),obj.mu(j,1), sqrt(obj.Sigma(1,1)));
            for t=2:obj.NDimensions
                c = c .* normcdf(X(:,t),obj.mu(j,t), sqrt(obj.Sigma(1,t))) ;
            end
            y = y + obj.PComponents(j) * c;
        end
    else%full covariance
        for j=1:obj.NComponents
            y = y + obj.PComponents(j) * mvncdf(X,obj.mu(j,:),obj.Sigma);
        end
    end
else %different covariance for each component
    if CovType==1 %diagonal covariance
        for j=1:obj.NComponents
             c = normcdf(X(:,1),obj.mu(j,1), sqrt(obj.Sigma(1,1,j)));
             for t=2:obj.NDimensions
                c = c .* normcdf(X(:,t),obj.mu(j,t), sqrt(obj.Sigma(1,t,j))) ;
             end
            y = y + obj.PComponents(j) * c;
        end
    else%full covariance
        for j=1:obj.NComponents
            y = y + obj.PComponents(j) * mvncdf(X,obj.mu(j,:),obj.Sigma(:,:,j));
        end
    end
end

