%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name: 
%       analyzeCroppedImage
%
%   Abstract:
%       The purpose of this function is to analyze the success rate of the
%       algorithm over a cropped image. This rate is defined by the ratio
%       between the original image size and shape and the restored image,
%       based on the algorithm.
%
%   Written by:
%       Ido Yerushalmy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Parameters - 
% 	center - a vector (1x2) of the form (xCenter, yCenter) which
%                                  defines the location of the calculated center point
%
%   cropPercentage - cropped section size from the original image [0..1/2].
%                                            Note that it is assumed that the cropped image 
%                                            contains the center of the
%                                            original image.
%
%   imName - image name. Its suffix defines what part of the original image
%                       was cropped ('top', 'bottom', 'right', or 'left')
%   imRows - number of rows in the image
%
%   imCols - number of columns in the image   
%   croppedFigHandle - handle to the cropped image figure
%
%   croppedLogFid, swDebugLogFid - file descriptors for log and result
%                                                                              purposes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function analyzeCroppedImage (center, cropPercentage, imName, imRows, imCols, croppedFigHandle, croppedLogFid, swDebugLogFid)

geoCntrCol = round(imCols/2);
geoCntrRow = round(imRows/2);


%Get the part of the image that was cropped based on its name's
%suffix ('top', 'bottom', 'right' or 'left'.
%Then, calculate the expected row and col of the original geometric
%center in the given (cropped) image
remainderPercentage = 1- cropPercentage;
remainderToOrgGeoCntr = 0.5 - cropPercentage;
%sanity check- the original geometric center is always assumed to
%be present in the cropped image as well
if (remainderPercentage < 0 || remainderToOrgGeoCntr < 0)
    fprintf(swDebugLogFid, 'Bad percentage calculation for cropped image: %s. remainderPercentage= %1.4f, remainderToOrgGeoCntr= %1.4f \n',imName,  remainderPercentage, remainderToOrgGeoCntr);
    return;
end

%calculate the percentage of the shift of the original geometric
%center, in the cropped image
cntrShiftPercentage = remainderToOrgGeoCntr / remainderPercentage;

%calculate the percentage of the removed rows (cols)  relative to the
%CROPPED IMAGE
rmvdSectionPercentage = cropPercentage / remainderPercentage;


%Calculate the image restoration rate, based on the location of
%the calculated center. Restoration rate is defined by the ratio
%between the covered and uncovered parts of the original image.
if (~isempty(findstr('Bottom', imName)))
    expectedCntrCol = geoCntrCol;
    expectedCntrRow = (1-cntrShiftPercentage)*imRows;

    uncoveredCols = 0; %since the width has not changed, all the columns are always covered
    exceedingCols = abs(expectedCntrCol - center(1))*2;%the number of cols that are out of the range of the un-cropped (original) image
    if (center(2)>= geoCntrRow)
        uncoveredRows = max((expectedCntrRow-center(2))*2, 0);%the number of rows of the original image that are un-covered
        exceedingRows = max((center(2)-expectedCntrRow)*2, 0);
    else
        uncoveredRows = rmvdSectionPercentage*imRows;%the entire section that was cropped is un-covered
        exceedingRows = (geoCntrRow - center(2))*2;
    end

    %calc the size of the original (un-cropped) image
    uncroppedRowsNum = expectedCntrRow*2;
    uncroppedColsNum = expectedCntrCol*2;

else
    if (~isempty(findstr('Top', imName)))
        expectedCntrCol = geoCntrCol;
        expectedCntrRow = cntrShiftPercentage*imRows;

        uncoveredCols = 0; %since the width has not changed, all the columns are always covered
        exceedingCols = abs(expectedCntrCol - center(1))*2;%the number of cols that are out of the range of the un-cropped (original) image
        if (center(2)<= geoCntrRow)
            uncoveredRows = max((center(2)-expectedCntrRow)*2, 0);%the number of rows of the original image that are un-covered
            exceedingRows = max((expectedCntrRow-center(2))*2, 0);
        else
            uncoveredRows = rmvdSectionPercentage*imRows;%the entire section that was cropped is un-covered
            exceedingRows = (center(2) - geoCntrRow)*2;
        end

        %calc the size of the original (un-cropped) image
        uncroppedRowsNum = (imRows-expectedCntrRow)*2;
        uncroppedColsNum = expectedCntrCol*2;

    else
        if (~isempty(findstr('Left', imName)))
            expectedCntrCol = cntrShiftPercentage*imCols;
            expectedCntrRow = geoCntrRow;

            uncoveredRows = 0; %since the hight has not changed, all the rows are always covered
            exceedingRows = abs(expectedCntrRow - center(2))*2;%the number of rows that are out of the range of the un-cropped (original) image
            if (center(1)<= geoCntrCol)
                uncoveredCols = max((center(1)-expectedCntrCol)*2, 0);%the number of cols of the original image that are un-covered
                exceedingCols = max((expectedCntrCol-center(1))*2, 0);
            else
                uncoveredCols = rmvdSectionPercentage*imCols;%the entire section that was cropped is un-covered
                exceedingCols = (center(1) - geoCntrCol)*2;
            end

            %calc the size of the original (un-cropped) image
            uncroppedRowsNum = expectedCntrRow*2;
            uncroppedColsNum = (imCols-expectedCntrCol)*2;

        else
            if  (~isempty(findstr('Right', imName)))
                expectedCntrCol = (1-cntrShiftPercentage)*imCols;
                expectedCntrRow = geoCntrRow;

                uncoveredRows = 0; %since the hight has not changed, all the rows are always covered
                exceedingRows = abs(expectedCntrRow - center(2))*2;%the number of rows that are out of the range of the un-cropped (original) image
                if (center(1)>= geoCntrCol)
                    uncoveredCols = max((expectedCntrCol-center(1))*2, 0);%the number of cols of the original image that are un-covered
                    exceedingCols = max((center(1)-expectedCntrCol)*2, 0);
                else
                    uncoveredCols = rmvdSectionPercentage*imCols;%the entire section that was cropped is un-covered
                    exceedingCols = (geoCntrCol - center(1))*2;
                end

                %calc the size of the original (un-cropped) image
                uncroppedRowsNum = expectedCntrRow*2;
                uncroppedColsNum = expectedCntrCol*2;

            else
                fprintf(swDebugLogFid, 'Unable to anlyze name of image: %s \n', imName);
                return;
            end
        end
    end
end

%plot the expected center on the original image
figure(croppedFigHandle);
hold 'on';
plot(expectedCntrCol, expectedCntrRow,'-mo',  'MarkerEdgeColor','k', 'MarkerFaceColor','r',  'MarkerSize',10);
hold 'off';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate the difference between the covered and exssesive
%regions, and normalize by the size of the original (un-cropped)
%image
uncroppedImSize = uncroppedColsNum * uncroppedRowsNum;
uncoveredSize = (uncoveredCols*uncroppedRowsNum) + (uncoveredRows*uncroppedColsNum);
%remove the region that was counted twice, if such exists
uncoveredSize = uncoveredSize - (uncoveredCols*uncoveredRows);
cvrdSize = uncroppedImSize - uncoveredSize;

%get the number of rows/cols of the un-cropped image, BASED ON THE
%CALCULATED CENTER
imRowsBasedOnCalcCntr = max(center(2), imRows-center(2)) * 2;
imColsBasedOnCalcCntr = max(center(1), imCols-center(1)) * 2;
excessiveSize = (exceedingCols*imRowsBasedOnCalcCntr) + (exceedingRows*imColsBasedOnCalcCntr);
%remove the region that was counted twice, if such exists
excessiveSize = excessiveSize - (exceedingCols*exceedingRows);
sizeRatio = (cvrdSize) / (uncroppedImSize+excessiveSize);

%save the result to a file
fprintf(croppedLogFid, '%s , %3.5f , %d , %d , %d \n', imName, sizeRatio, uncroppedImSize, cvrdSize, excessiveSize);
