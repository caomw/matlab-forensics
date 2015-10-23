function display(obj,objectname)
%DISPLAY Display a Gaussian mixture distribution object.
%   DISPLAY(A) prints a text representation of the gmdistribution
%   object A.  DISPLAY is called when a semicolon is not used to
%   terminate a statement.
%
%   DISPLAY(A,OBJECTNAME) uses objectname as the object name.
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/DISP.



%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/14 05:26:17 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');
if nargin<2
     objectname = inputname(1);
end
if isempty(objectname)
    objectname = 'ans';
end

if (isLoose)
    fprintf('\n');
end
fprintf('%s = \n', objectname);
disp(obj)

if (isLoose)
    fprintf('\n');
end
