%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name: 
%       overlayContourOnImage
%
%   Abstract:
%       This function draws the contour lines given in C
%       on a given image, starting from a minimal contour level
%
%   Written by:
%       Ido Yerushalmy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Parameters - 
%       imgHandle - a handle to the image
%
%       C - a 2Xn matrix, as returned from the 'contour command'
%             threshold - the minimum value of contours that should be presented
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function overlayContourOnImage (imgHandle, C, threshold)

%plot the higher levels over the original figure
figure(imgHandle);
hold on;

printContour = 0;
levalDescriptorEntry = 1;
[r elemNum] = size(C);

while (levalDescriptorEntry < elemNum)
    contourValue = C(1,levalDescriptorEntry);
    if (contourValue >= threshold)
        
        %Don't print all contour lines, since it looks to crowded
        if (0 == mod(printContour,4))
            firstPointIndex = levalDescriptorEntry+1;
            pointsInLevel = C(2,levalDescriptorEntry);
            pointsOnContour = [C(1, firstPointIndex: firstPointIndex+pointsInLevel-1) ; ...
                C(2, firstPointIndex: firstPointIndex+pointsInLevel-1)];
            plot(pointsOnContour(1,:), pointsOnContour(2, :), '.b');
        end
        printContour = printContour+1;
    end
    %get the next contour level
    levalDescriptorEntry = levalDescriptorEntry + C(2,levalDescriptorEntry)+1;
end

hold off; %imgHandle



