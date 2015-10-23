function  D2 = mahal(obj,X)
% MAHAL Mahalanobis distance from X to component means.
%    D2 = MAHAL(OBJ,X) returns the Mahalanobis distance (in squared units)
%    from points in X to the mean of each Gaussian component in OBJ. OBJ is
%    a GMDISTRIBUTION object. X is a N-by-D matrix. Rows of X correspond to
%    points, columns correspond to variables. D2(I,J) is the
%    Mahalanobis distance of point I from the mean of component J.
%
%    See also GMDISTRIBUTION, GMDISTRIBUTION/POSTERIOR,
%    GMDISTRIBUTION/CLUSTER.

%    Copyright 2007 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:21 $

% Check for valid input
if nargin ~= 2
    error('stats:gmdistribution:mahal:TooFewInputs',...
        'Two input arguments are required.');
end

checkdata(X,obj);

covNames = { 'diagonal','full'};
CovType = strmatch(lower(obj.CovType),covNames);
[log_lh,D2]=wdensity(X,obj.mu, obj.Sigma, obj.PComponents, obj.SharedCov, CovType);

