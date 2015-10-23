function checkdata(X,obj)
%CHECKDATA Check the size of data
%   CHECKDATA(X) returns an error if data X is not a 2 dimensional numeric
%   matrix.
%
%   CHECKDATA(X.OBJ) returns an error if the columns of X does not equal
%   the OBJ.NDimensions.

%    Copyright 2007 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:29 $
if ndims(X)>2 || ~isnumeric(X)
    error('stats:gmdistribution:RequiresMatrixData',...
       'X must be a numeric 2-D matrix.');
end

if nargin>1
[n, d] = size(X);
if d ~= obj.NDimensions
    error('stats:gmdistribution:XSizeMismatch',...
        'X must be a matrix with %d columns.',obj.NDimensions);
end

end