classdef gmdistribution
    %GMDISTRIBUTION Creates a Gaussian mixture model.
    %   OBJ = GMDISTRIBUTION(MU,SIGMA,P) creates an object OBJ defining a mixture
    %   of Gaussian components. Input arguments are listed below.
    %   MU      A K-by-D matrix specifying the mean of each component,
    %           where K is the number of components. MU(J,:) is the mean of
    %           component J. MU is stored in OBJ.mu.
    %   SIGMA   Specifies the covariance of each component. SIGMA is stored
    %           in OBJ.Sigma. The size of SIGMA is:
    %           * D-by-D-by-K array if there are no restrictions on the
    %             form of the covariance. In this case, SIGMA(:,:,J) is the
    %             covariance of component J.
    %           * 1-by-D-by-K array if the covariance matrices are
    %             restricted to be diagonal, but not restricted to be same
    %             across components. In this case, SIGMA(:,:,J) contains
    %             the diagonal elements of the covariance of component J.
    %           * D-by-D matrix if the covariance matrices are restricted
    %             to be the same across components, but not restricted to be
    %             diagonal. In this case, SIGMA is the pooled estimate of
    %             covariance.
    %           * 1-by-D vector if the covariance matrices are restricted
    %             to be diagonal and the same across components. In this
    %             case, SIGMA contains the diagonal elements of the pooled
    %             estimate of covariance.
    %   P       A 1-by-K vector specifying the mixing proportions of each
    %           component. If P does not sum to 1, GMDISTRIBUTION
    %           normalizes it. The default is equal proportions if P is not
    %           given. P is stored in OBJ.PComponents.
    %
    %   OBJ has the following properties:
    %   OBJ.NDimensions  The dimension D of the multivariate Gaussian
    %                  distribution.
    %   OBJ.DistName     'gaussian mixture distribution', the name of
    %                  distribution
    %   OBJ.NComponents  The number of mixture components K.
    %   OBJ.PComponents  A 1-by-K vector containing the mixing proportion of
    %                  each component.
    %   OBJ.CovType      'diagonal' if the covariance matrices are restricted
    %                  to be diagonal; 'full' otherwise. 
    %   OBJ.SharedCov    True if all the covariance matrices are restricted
    %                  to be the same (pooled estimate); false otherwise. 
    %   An object created by GMDISTRIBUTION.FIT has additional
    %   properties related to the fit.
    %
    %   Example:   Create a gmdistribution object defining a 2-component
    %   Gaussian mixture.
    %            MU = [1 2;-3 -5];
    %            SIGMA = cat(3,[2 0; 0 .5],[1 0; 0 1]);
    %            MIXP = ones(1,2)/2;
    %            o = gmdistribution(MU,SIGMA,MIXP);
    %
    %   See also GMDISTRIBUTION/FIT, GMDISTRIBUTION/CLUSTER,
    %   GMDISTRIBUTION/PDF, GMDISTRIBUTION/CDF, GMDISTRIBUTION/RANDOM,
    %   GMDISTRIBUTION/POSTERIOR, GMDISTRIBUTION/MAHAL. 
    
    %   Reference:   McLachlan, G., and D. Peel, Finite Mixture Models, John
    %                Wiley & Sons, New York, 2000.

    %   Copyright 2007 The MathWorks, Inc.
    %   $Revision: 1.1.6.2.2.1 $  $Date: 2007/07/19 18:18:02 $


    properties(GetAccess='public', SetAccess='protected')
        NDimensions = 0;  % dimension of multivariate distribution
        DistName = 'gaussian mixture distribution';
        NComponents = 0;  % number of mixture components
        PComponents = zeros(0,1); % NComponents-by-1 vector of proportions
        mu = [];          % NComponents-by-NDimensions array for means
        Sigma = [];    % Covariance
        NlogL=[];      % Negative log-likelihood
        AIC = [];      % Akaike information criterion
        BIC = [];      % Bayes information criterion
        Converged=[];  %whether the EM is Converged
        Iters=[];      % The number of iterations
        SharedCov=[];
        CovType=[];
        RegV=0;
    end

    methods
        function obj = gmdistribution (mu, Sigma, p)
            if nargin==0
                return;
            end

            if nargin < 2
                error('stats:gmdistribution:TooFewInputs',...
                    'At least two input arguments required.');
            end
            if ndims(mu) ~= 2 || ~isnumeric(mu)
                error('stats:gmdistribution:BadMu',...
                    'MU must be a 2-D numeric matrix.');
            end

            [k,d]=size(mu);
            if nargin < 3 || isempty(p)
                p=ones(1,k);
            elseif  ~isvector(p)|| length(p) ~= k
                error('stats:gmdistribution:MisshapedInput',...
                    'The number of rows of MU must be equal to the length of P.');
            elseif any(p <= 0 )
                error('stats:gmdistribution:InvalidInitP',...
                    'The mixing proportions must be positive.')
            elseif size(p,1) ~= 1
                p = p'; % make it a row vector
            end

            p = p/sum(p);


            [d1,d2,k2]=size(Sigma);
            if  k2 == 1

                if d1 == 1 %diagonal covariance
                    if d2 ~= d
                        error('stats:gmdistribution:MisshapedSigma',...
                            'The shared diagonal covariance must be a row vector with the same number of columns as MU.');
                    elseif min(Sigma) <  max(Sigma) * eps
                        error('stats:gmdistribution:BadCovariance', ...
                            'The diagonal covariance matrix must be positive definite.');
                    end
                    obj.CovType='diagonal';

                else %full covariance
                    if ~isequal( size(Sigma),[d d] )
                        error('stats:gmdistribution:MisshapedSigma',...
                            ['The shared covariance must be a square matrix ',...
                            'with the same number of columns as MU.']);
                    end
                    [R,err] = cholcov(Sigma);
                    if err ~= 0
                        error('stats:gmdistribution:BadSigma', ...
                            ['The shared covariance matrix must be symmetric and \n',...
                            'positive definite.']);
                    end
                    obj.CovType='full';
                end

                obj.SharedCov=true;
            else %different covariance
                if k2 ~= k
                    error('stats:gmdistribution:MisshapedInput',...
                        'The number of rows of MU must equal to the pages of SIGMA \n');
                end
                if d1 == 1 %diagonal covariance
                    if d2 ~= d
                        error('stats:gmdistribution:MisshapedSigma',...
                            ['Each page of the diagonal covariance must be a row vector \n'...
                            'with the same number of columns as MU.']);
                    end
                    for j = 1:k
                        %check whether the covariance matrix is positive definite
                        if  min(Sigma(:,:,j)) < max(Sigma(:,:,j)) * eps
                            error('stats:gmdistribution:BadSigma', ...
                                'Each diagonal covariance matrix must be positive definite.');
                        end
                    end
                    obj.CovType='diagonal';
                else
                    if d1~= d || d2 ~= d
                        error('stats:gmdistribution:MisshapedInput',...
                            ['Each page of SIGMA must be a square matrix \n',...
                            'with the same number of columns as MU.']);
                    end
                    for j = 1:k
                        % Make sure Sigma is a valid covariance matrix
                        %check for positive definite
                        [R,err] = cholcov(Sigma(:,:,j));
                        if err ~= 0
                            error('stats:gmdistribution:BadCovariance', ...
                                'Each covariance matrix must be symmetric and positive definite.');
                        end
                    end
                    obj.CovType='full';
                end
                obj.SharedCov=false;
            end

            obj.NDimensions = d;
            obj.NComponents = k;
            obj.PComponents = p;
            obj.mu = mu;
            obj.Sigma = Sigma;

        end %constructor
    end

    methods ( Static = true)
        function obj = fit(X,k,varargin)

            if nargin < 2
                error('stats:gmdistribution:TooFewInputs',...
                    'At least two input arguments required.');
            end

            checkdata(X);

            if ~isscalar(k)||  ~isnumeric(k) || ~isfinite(k) ...
                    || k<1 || k~=round(k)
                error('stats:gmdistribution:BadK',...
                    'K must be an integer specifying the number of mixture components.');
            end

            %remove NaNs from X
            wasnan=any(isnan(X),2);
            hadNaNs=any(wasnan);
            if hadNaNs
                warning('stats:gmdistribution:MissingData',...
                    'Rows of X with missing data will not be used.');
                X = X( ~ wasnan,:);
            end

            [n, d] = size(X);
            if n <= d
                error('stats:gmdistribution:TooFewN',...
                    'X must have more rows than columns.');
            end


            if n <= k
                error('stats:gmdistribution:TooManyClusters', ...
                    'X must have more rows than the number of components.');
            end

            varX = var(X);
            I = find(varX < eps(max(varX))*n);
            if ~isempty(I)
                error('stats:gmdistribution:ZeroVariance',...
                    'The following column(s) of data are effectively constant: %s.', num2str(I));
            end

            % parse input and error check
            pnames = {      'start' 'replicates'  'covtype' 'sharedcov'  'regularize'  'options'};
            dflts =  { 'randSample'           1    'full'    false         0      []};
            [eid,errmsg,start,reps, CovType,SharedCov, RegV, options] ...
                = dfswitchyard('statgetargs',pnames, dflts, varargin{:});
            if ~isempty(eid)
                error(sprintf('stats:gmdistribution:%s',eid),errmsg);
            end

            options = statset(statset('gmdistribution'),options);

            if ~isnumeric(reps) ||  ~isscalar(reps) ||round(reps) ~=reps || reps < 1
                error('stats:gmdistribution:InvalidReps',...
                    '''Replicates'' must be a positive integer.');
            end


            if ~isnumeric(RegV) || ~isscalar(RegV) || RegV < 0
                error('stats:gmdistribution:InvalidReg',...
                    'The ''Regularize'' must be a non-negative scalar.')
            end

            if ischar(CovType)
                covNames = { 'diagonal','full'};
                i = strmatch(lower(CovType),covNames);
                if isempty(i)
                    error('stats:gmdistribution:UnknownCovType', ...
                        'Unknown ''CovType'' parameter value:  %s.', CovType);
                end
                CovType = i;
            else
                error('stats:gmdistribution:InvalidCovType', ...
                    'The ''CovType'' parameter value must be a string.');
            end

            if ~islogical(SharedCov)
                error('stats:gmdistribution:InvalidSharedCov', ...
                    'The ''SharedCov'' parameter value must be logical.');
            end

            if ischar(start)
                % parsing input and error check done
                start = lower(start);
                startNames = {'randsample'};
                i = strmatch(start, startNames);
                if isempty(i)
                    error('stats:gmdistribution:UnknownStart', ...
                        'Unknown ''Start'' parameter value:  %s.', start);
                end

            end

            options.Display= strmatch(lower(options.Display), {'off','notify','final','iter'}) - 1;


            try
                [S,NlogL,optimInfo] =...
                    gmcluster(X,k,start,reps, CovType,SharedCov, RegV, options);

                % Store results in object
                obj = gmdistribution;
                obj.NDimensions = d;
                obj.NComponents = k;
                obj.PComponents = S.PComponents;
                obj.mu = S.mu;
                obj.Sigma = S.Sigma;
                obj.Converged=optimInfo.Converged;
                obj.Iters=optimInfo.Iters;
                obj.NlogL=NlogL;
                obj.SharedCov=SharedCov;
                obj.RegV=RegV;
                if CovType==1
                    obj.CovType='diagonal';
                    if SharedCov
                        nParam=obj.NDimensions;
                    else
                        nParam=obj.NDimensions * k;
                    end
                else
                    obj.CovType='full';
                    if SharedCov
                        nParam=obj.NDimensions * (obj.NDimensions+1)/2;
                    else
                        nParam=k* obj.NDimensions*(obj.NDimensions+1)/2 ;
                    end

                end
                nParam = nParam + k-1 + k * obj.NDimensions ;
                obj.BIC= 2*NlogL + nParam*log(n);
                obj.AIC =2* NlogL + 2*nParam;

            catch
                err=lasterror;
                rethrow(err) ;
            end
        end

    end

    methods(Visible = false)

     
        function a = fields(varargin)
            a = fieldnames(varargin{:});
        end

        function a = fieldnames(varargin)
            a = {'NDimensions'; 'DistName'; 'NComponents'; 'PComponents';...
                'mu'; 'Sigma'; 'NlogL'; 'AIC';'BIC'; 'Converged'; 'Iters';...
                'SharedCov'; 'CovType'; 'RegV'};
        end
        % Methods that we inherit from opaque, but do not want
        function varargout = cat(varargin),     throwNoCatError; end
        function varargout = horzcat(varargin), throwNoCatError; end
        function varargout = vertcat(varargin), throwNoCatError; end

        function a = toChar(varargin),          throwUndefinedError; end

        function a = permute(varargin),         throwUndefinedError; end
        function a = transpose(varargin),       throwUndefinedError; end
        function a = ctranspose(varargin),      throwUndefinedError; end
        function a = reshape(varargin),         throwUndefinedError; end
        function a = tril(varargin),            throwUndefinedError; end
        function a = triu(varargin),            throwUndefinedError; end
        function a = diag(varargin),            throwUndefinedError; end

        function [a,b] = sort(varargin),        throwUndefinedError; end
        function [a,b] = ismember(varargin),    throwUndefinedError; end
        function [a,b] = setdiff(varargin),     throwUndefinedError; end
        function [a,b,c] = setxor(varargin),    throwUndefinedError; end
        function [a,b,c] = intersect(varargin), throwUndefinedError; end

    end % invisible methods block

    %end % methods block

end % classdef

function throwNoCatError
st = dbstack;
name = strread(st(2).name,'gmdistribution.%s');
error('stats:gmdistribution:NoCatAllowed', ...
    'Concatenation of GMDISTRIBUTION objects not allowed.\nUse a cell array to contain multiple objects.');
end

function throwUndefinedError
st = dbstack;
name = strread(st(2).name,'gmdistribution.%s');
error('stats:gmdistribution:UndefinedFunction', ...
    'Undefined function or method ''%s'' for input arguments of type ''gmdistribution''.',name{1});
end