%FIT Fit data to Gaussian mixture model
%   G = GMDISTRIBUTION.FIT(X,K) creates an object G containing maximum
%   likelihood estimates of the parameters in a Gaussian mixture model with
%   K components for the data in X. X is an N-by-D matrix. Rows of X
%   correspond to points; columns correspond to variables. The
%   estimation uses the Expectation Maximization (EM) algorithm.
%
%   GMDISTRIBUTION treats NaNs as missing data. Rows of X with NaNs are
%   excluded from the fit.
%
%   G = GMDISTRIBUTION.FIT(...,'PARAM1',val1,'PARAM2',val2,...)
%   provides more control over the iterative EM algorithm. Parameters
%   and values are listed below.
%
%   'Start'  Method used to choose initial component parameters.
%            There are three choices:
%
%            'randSample'   Select K observations from X at random as the
%                           initial component means.  The mixing 
%                           proportions are uniform.  The initial
%                           covariance matrices for all clusters are
%                           diagonal, where the Jth element on the diagonal
%                           is the variance of X(:,J). This is the default.
%
%             A structure array S containing the following fields:
%
%                           S.PComponents:
%                           A 1-by-K vector specifying the mixing
%                           proportions of each component. The default
%                           is uniform.
%
%                           S.mu:
%                           A K-by-D matrix specifying the mean of each
%                           component.
%
%                           S.Sigma:
%                           An array specifying the covariance of each
%                           component. The size of Sigma is one of the
%                           following:
%                           * D-by-D-by-K array if there are no 
%                             restrictions on the form of covariance.  In
%                             this case, S.Sigma(:,:,J) is the covariance
%                             of component J.
%                           * 1-by-D-by-K array if the covariance matrices
%                             are restricted to be diagonal, but not
%                             restricted to be same across components. In
%                             this case, S.Sigma(:,:,J) contains the
%                             diagonal elements of the covariance of
%                             component J.
%                           * D-by-D matrix if the covariance matrices are
%                             restricted to be the same across clusters,
%                             but not restricted to be diagonal. In this
%                             case, S.Sigma is the pooled estimate of
%                             covariance.
%                           * 1-by-D vector if the covariance matrices are
%                             restricted to be diagonal and to be the same
%                             across clusters.  In this case, S.Sigma
%                             contains the diagonal elements of the pooled
%                             estimate of covariance.
%
%             A vector of length N containing the initial guess of the
%             component index for each point.
%
%   'Replicates'   A positive integer giving the number of times to
%                  repeat the EM algorithm, each with a new set of
%                  parameters. The solution with the largest likelihood
%                  is returned. The default number of replicates is 1.
%                  A value larger than 1 requires the 'randSample'
%                  start method.
%
%   'CovType'      'diagonal' if the covariance matrices are restricted to
%                  be diagonal; 'full' otherwise. The default is 'full'.
%
%   'SharedCov'    True if all the covariance matrices are restricted to be
%                  the same (pooled estimate); false otherwise. The default
%                  is false.
%
%   'Regularize'   A non-negative regularization number added to the
%                  diagonal of covariance matrices to make them positive-
%                  definite. The default is 0.
%
%   'Options'      Options structure for the iterative EM algorithm, as
%                  created by STATSET.  The following STATSET parameters
%                  are used:
%
%                     'Display'   Level of display output.  Choices are
%                                 'off' (the default), 'final', and 'iter'.
%                     'MaxIter'   Maximum number of iterations allowed.
%                                 Default is 100.
%                     'TolFun'    Positive number giving the termination
%                                 tolerance for the log-likelihood
%                                 function. The default is 1e-6.
%
%   The properties of the object G are listed below.
%   G.NDimensions  The dimension of multivariate Gaussian distribution.
%                  It equals D.
%   G.DistName       The name of distribution. In gmdistribution, it is
%                  'gaussian mixture distribution'
%   G.NComponents  The number of mixture components K.
%   G.PComponents  A 1-by-K vector containing the mixing proportion of
%                  each component.
%   G.mu           A K-by-D array of means.
%   G.Sigma        An array or a matrix containing the covariance of
%                  each component. The size of Sigma is:
%                  * D-by-D-by-K array if there are no restrictions on
%                    the form of covariance. In this case,
%                    G.Sigma(:,:,j) is the covariance of component j.
%                  * 1-by-D-by-K array if the covariance matrices are
%                    restricted to be diagonal, but not restricted to
%                    be same across components. In this case
%                    G.Sigma(:,:,j) contains the diagonal elements of
%                    the covariance of component j.
%                  * D-by-D matrix if the covariance matrices are
%                    restricted to be the same across clusters, but not
%                    restricted to be diagonal. In this case, G.Sigma
%                    is the pooled estimate of covariance.
%                  * 1-by-D vector if the covariance matrices are
%                    restricted to be diagonal and to be the same
%                    across clusters.  In this case, G.Sigma contains
%                    the diagonal elements of the pooled estimate of
%                    covariance.
%   G.NlogL        The negative of the log-likelihood of the data.
%   G.AIC          The Akaike information criterion, which is
%                  2*NlogL + 2*the number of estimated parameters.
%   G.BIC          The Bayes information criterion, which is
%                  2*NlogL + (the number of estimated parameters *
%                  log(N)).             
%   G.Converged    True if the algorithm has converged; false if the
%                  algorithm has not converged.
%   G.Iters        The number of iterations of the algorithm.
%   G.CovType      The value of the 'CovType' input parameter.
%   G.SharedCov    The value of the 'SharedCov' input parameter.
%   G.RegV         The value of the 'Regularize' input parameter.
%
%   Example:   Generate data from a mixture of two bivariate Gaussian
%              distributions and fit a Gaussian mixture model:
%                 mu1 = [1 2];
%                 Sigma1 = [2 0; 0 .5];
%                 mu2 = [-3 -5];
%                 Sigma2 = [1 0; 0 1];
%                 X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];
%                 G = gmdistribution.fit(X,2);
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/CLUSTER, KMEANS.

%   Reference:  McLachlan, G., and D. Peel, Finite Mixture Models, John
%               Wiley & Sons, New York, 2000.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:19 $