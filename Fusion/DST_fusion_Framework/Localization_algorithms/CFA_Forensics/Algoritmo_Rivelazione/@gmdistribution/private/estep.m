function  [ll, post, logpdf]=estep(log_lh)
%ESTEP E-STEP for Gaussian mixture distribution
%   LL = ESTEP(LOG_LH) returns the loglikelihood of data in LL.  LOG_LH
%   is the log of component conditional density weighted by the component
%   probability.
%
%   [LL, POST] = ESTEP(LOG_LH) returns the posterior probability in the
%   matrix POST. POST(i,j) is the posterior  probability of point i
%   belonging to cluster j.
%
%   [LL, POST, DENSITY] = ESTEP(LOG_LH)  returns the pdf values of data in
%   the vector density.
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/14 05:26:30 $



maxll = max (log_lh,[],2);
%minus maxll to avoid underflow
post = exp(bsxfun(@minus, log_lh, maxll));
%density(i) is \sum_j \alpha_j P(x_i| \theta_j)/ exp(maxll(i))
density = sum(post,2);
%normalize posteriors
post = bsxfun(@rdivide, post, density);
logpdf = log(density) + maxll;
ll = sum(logpdf) ;

