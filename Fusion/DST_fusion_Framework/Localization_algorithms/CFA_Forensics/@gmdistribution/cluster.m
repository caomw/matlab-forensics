function [ idx,NlogL,post,logpdf,mahalaD]=cluster(obj,X)
%GMDISTRIBUTION/CLUSTER Cluster data for Gaussian mixture distribution.
%   IDX = CLUSTER(OBJ,X) partitions the points in the N-by-D data matrix X
%   using the parameters in gmdistribution OBJ. Rows of X correspond to
%   points, columns correspond to variables. CLUSTER returns an N-by-1
%   vector IDX containing the cluster index of each point. The cluster
%   index refers to the component giving the largest posterior probability
%   for the point.
%
%   CLUSTER treats NaNs as missing data. Rows of X with NaNs are
%   excluded from the partition.
%
%   [IDX,NLOGL] = CLUSTER(OBJ,X) returns NLOGL, the negative of the
%   log-likelihood of the X.
%
%   [IDX,NLOGL,POST] = CLUSTER(OBJ,X) returns POST, a matrix containing the
%   posterior probability of each point for each component. POST(I,J) is
%   the posterior probability of point I belonging to component J, i.e.,
%   Pr{component J | point I}. 
%
%   [IDX,NLOGL,POST,LOGPDF] = CLUSTER(OBJ,X) returns LOGPDF, a vector of
%   length N containing estimates of the logs of probability density
%   function (PDF). LOGPDF(I) is the log of the PDF of point I. The PDF
%   value of point I is the sum of p(point I | component J)*Pr{component J}
%   taken over all components, where p() is the multivariate normal pdf. 
%
%   [IDX,NLOGL,POST,LOGPDF,MAHALAD] = CLUSTER(OBJ,X) returns MAHALAD, a
%   N-by-K matrix containing the Mahalanobis distance in squared units.
%   MAHALAD(I,J) is the Mahalanobis distance of point I from the mean of
%   component J.
%
%   See also GMDISTRIBUTION/FIT, GMDISTRIBUTION/POSTERIOR,
%   GMDISTRIBUTION/MAHAL.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/14 05:26:14 $

% Check for valid input
if nargin ~= 2
    error('stats:gmdistribution:cluster:TooFewInputs',...
        'Two input arguments are required.');
end

checkdata(X,obj);

%remove NaNs
wasnan=any(isnan(X),2);
hadNaNs=any(wasnan);
if hadNaNs
    warning('stats:gmdistribution:cluster:MissingData','Rows of X with missing data will not be used.');
    X = X( ~ wasnan,:);
end

covNames = { 'diagonal','full'};
CovType = strmatch(lower(obj.CovType),covNames);
[log_lh, mahalaD]=wdensity(X,obj.mu, obj.Sigma, obj.PComponents, obj.SharedCov, CovType);
[ll, post,logpdf] = estep(log_lh);
[ignore,idx] = max (post,[],2);
NlogL=-ll;

if hadNaNs
    [idx,post,logpdf,mahalaD] = dfswitchyard('statinsertnan',wasnan,idx,post, logpdf,mahalaD);

end

