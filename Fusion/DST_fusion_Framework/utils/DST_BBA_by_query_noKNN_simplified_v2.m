function [XT, XN, XTN] = DST_BBA_by_query_noKNN_simplified_v2(to_be_classified, training_array, gamma, alpha)
%function [XT, XN, XTN] = DST_BBA_by_query_noKNN_simplified(to_be_classified, training_array, gamma, alpha)
%
%This function implements the approach described in [1] to classify in
%using basic belief assignments a given sample basing on a set of training
%samples. Three values are returned: the mass for the sample belonging to
%class T, the mass for the sample belonging to class N and the mass for
%the doubt TN.
%
%--- INPUT PARAMS ---
%-> to_be_classified: (scalar value) the sample to be classified
%-> training_array: N-by-3 array with training samples. The first column
%       must contain sample values and the second column must contain ground truth
%       labels (0 means class N, 1 means class T).
%       Example:
%       [0.1123     0;
%       0.1892     0;
%       0.8991     1]
%       The third column is OPTIONAL, and can contain the Quality Factor of the
%       image. If this info is available, it can be used to dinamycally weigth
%       each training sample by the reliability of specified forensic_algorithm
%-> gamma: this parameter controls the speed of the decay of the contribution
%       of training examples, see [1]. gamma may be a scalar value or a 1-by-2
%       array. If it is scalar, the same gamma will be used for evaluating
%       the contribution of each training instance, independently from the
%       class. If it is 1-by-2, then gamma(1) will be used for the POSITIVE
%       class (label=1) and gamma(2) will be used for the NEGATIVE
%       (label=0). 
%-> [OPTIONAL] alpha: controls the amount of certainty that is assigned to
%       each training instance. Must be in the interval [0,1] (default =
%       0.8).
%       Alpha=0 -> all the mass is assigned to doubt, so nothing will be practically learned.
%       Alpha=1 -> all the mass is assigned to the class, no doubt will be
%       generated.
%
%--- OUTPUT PARAMS ---
%-> XT: mass for the sample belonging to class T
%-> XN: mass for the sample belonging to class N
%-> XTN: mass for the doubt
%
%--- Usage Example ---
% addpath(genpath('DStheory'));
% train =   [0.1123     0;    0.1892     0;    0.8991     1];
% test = 0.107;
% [beliefTamp beliefOrig doubt] = DST_BBA_by_query_noKNN_simplified(test,train)
%
%--- BIBLIOGRAPHY ----
%[1] J. Franc?ois, Y. Grandvalet, T. Den?ux, J.-M. Roger. Resample and combine: an approach to improving uncertainty representation 
%    in evidential pattern classification, Information Fusion 4 (2003), pp. 75-85
if ~exist('alpha','var')
    alpha = 0.8;
end

gammaP = gamma(1);
gammaN = gamma(end);

assert(alpha>=0 & alpha<=1,'Illegale value for alpha, must be a scalar in the interval [0,1], see the Help');
assert(size(training_array,2)>=2,'''training_array'' array must have at least 2 columns (the last column is the label of the training instance!).');
assert(sum(training_array(:,end)~=0 & training_array(:,end)~=1)==0  ,'The last column of ''training_array'' must contain the label of the training instance (i.e., it should be 0 or 1).');

XT=0;
XN=0;
XTN=1; %before observing nothing, there's only doubt :-)
for n=1:size(training_array,1)
    D = norm(to_be_classified-training_array(n,1:end-1));
    if training_array(n,end)==1 %if sample belongs to positive class
        mass = alpha*exp(-gammaP*(D.^2));            
        x = mass;
        y = 0;
        z = 1-mass;
    else %if sample belongs to negative class
        mass = alpha*exp(-gammaN*(D.^2));                    
        x = 0;
        y = mass;
        z = 1-mass;
    end
    
    K = XT.*y+XN.*x;
    XT = (XT.*x + XT.*z + XTN.*x)./(1-K);
    XN = (XN.*y + XN.*z + XTN.*y)./(1-K);
    XTN = (XTN*z)./(1-K);
    
end

if (1-(XT+XN+XTN))>0.001
    warning('Something went wrong, masses did not sum to 1 but to %.3f.',XT+XN+XTN); %#ok<*WNTAG>
end

end

