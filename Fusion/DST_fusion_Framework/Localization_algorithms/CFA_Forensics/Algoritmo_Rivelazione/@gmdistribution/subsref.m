function [varargout] = subsref(t,s)
%SUBSREF Subscripted reference for a gmdistribution object.
%   B = SUBSREF(T,S) is called for the syntax T(X) when T is a
%   gmdistribution object.  S is a structure array with the fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.
%
%
%   See also GMDISTRIBUTION.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:28 $

switch s(1).type
    case '()'
         error('stats:gmdistribution:subsref:ArraySubscript', ...
                'The GMDISTRIBUTION class does not support () indexing.');
       

    case '{}'
        error('stats:gmdistribution:subsref:CellSubscript', ...
            'The GMDISTRIBUTION class does not support cell array indexing.');

    case '.'
        methodnames = {'cdf' 'cluster' 'disp' 'display' 'mahal' ...
            'pdf' 'posterior' 'random' };
        if ismember(s(1).subs,methodnames)
            % Support dot subscripting to call methods
            if isscalar(s)
                args = {};
            elseif numel(s)>2 || ~isequal(s(2).type,'()')
                error('stats:gmdistribution:subsref:BadSubscript', ...
                    'Invalid subscripting for gmdistribution object.');
            elseif numel(s)==2
                args = s(2).subs;
            end
            
            if isequal(s(1).subs,'display') %% nargout==0
                display(t,inputname(1));
            else
            [varargout{1:nargout}] = feval(s(1).subs,t,args{:});
            end
            
        else
            staticmethodnames ={'fit'};
            if ismember(s(1).subs,staticmethodnames)
                error('stats:gmdistribution:subsref:InstCallStatic', ...
                    'Static method ''%s'' must be called by using the class name ''gmdistribution''. ',s(1).subs);
            end
            % A reference to a variable or a property.
            b = t.(s(1).subs);

            if isscalar(s)
                % If there's no cascaded subscripting, only ever assign the var itself.
                varargout{1} = b;
            else
                % Now let the variable's subsref handle the remaining subscripts in
                % things like a.name(...) or  a.name{...} or a.name.attribute. This
                % may return a comma-separated list, so ask for and assign to as many
                % outputs as we're given.  If there's no LHS to the original expression,
                % then we're given nargout==0, and this only assigns one output and
                % drops everything else in the CSL.
                 try
                    [varargout{1:nargout}] = subsref(b,s(2:end));
                catch
                    rethrow(lasterror);
                end
            end
        end
end
