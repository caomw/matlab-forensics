function disp(obj)
%DISP Display a Gaussian mixture distribution object.
%   DISP(OBJ) prints a text representation  of the gmdistribution
%   OBJ, without printing the object name.  In all other ways it's
%   the same as leaving the semicolon off an expression.
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/DISPLAY.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/14 05:26:15 $


isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose)
    fprintf('\n');
end


fprintf('Gaussian mixture distribution with %d components in %d dimensions\n',...
        obj.NComponents,obj.NDimensions);
if obj.NComponents > 0 && obj.NDimensions < 6
    for j =1 :obj.NComponents
        fprintf('Component %d:\n', j);
        fprintf('Mixing proportion: %f\n',obj.PComponents(j));
        fprintf('Mean: ');
        disp(obj.mu(j,:));
        
    end
end

if (isLoose)
    fprintf('\n');
end
