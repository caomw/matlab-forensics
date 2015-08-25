%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name:
%       findAberrations
%
%   Abstract:
%       This function finds and analyzes the edges inside the image to detect
%       chromatic aberrations. It then removes outliers and marks the image
%       center based on the aberrations. Finally,  regions suspected in
%       forgery are marked on the image
%
%   Written by:
%       Ido Yerushalmy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function findAberrations_Mark(FileName,orgIm)


%%%%%%%%%%%%%%%%%%%%
%       Flags  & Parameters        %
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%
% Debug flags:

%defines if the anlysis of the segment perp. to the edge should be plotted or not
plotEdgeAnal = 0;
%display image anlyzed
diplayRes = 1;


OutputPathBase= 'D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Yerushalmy\';


%%%%%%%%%%%%%%%%%%%%
% Edge analysis parameters:

%length of the segment to be analyzed across an edge
segLen = 18;
%length of edge region that assits to calculate the perpendicular segment
calcDelta = 7;
%the threshold used to define what change in the first derivative of the
%analyzed segment will be considered as a peak/edge
peakThreshold = 10;
%defines the number of iterations that outliers removal is performed
outliersItrNum = 2;
%defines the minimum value of an outlier's weighted distance, which defines
%it as a forgery suspected region
forgeryThresh = 700000 ;

%%%%%%%%%%%%%%%%%%%%
% Cropped image analysis:

%if this flag is true, the algorithm adds analysis for cropped images
analyzeCroppedImages = 0 ;
%the part of rows (or cols) that was removed from the original image
cropPercentage = (1/3) ;






%%%%%%%%%%%%%%%%
%  Global Variables    %
%%%%%%%%%%%%%%%%

%global vector that saves the parameters of the lines calculated in this
%function. It is used in 'disFrmImgCntr' function in the process of finding
%the center of the image.
%
%Vector structure:
%   10 rows (a,b,c, sigma, borderX1, borderY1, borderX2, borderY2, lglZoneX, lglZoneY). One column per
%   analyzed aberration. Explanation:
%   1- (a,b,c) signs corrspond to the line formula: ax + by +  c = 0.
%   2- borderWW depict 2 points on the analyzed edge
%   3- lglZoneX/Y depict a point in the "legal zone" of the edge based on
%        the aberration's direction
global linesPrms;

%global variables that save the size of the analyzed image. They are used
%in 'disFrmImgCntr' function to normalize the distance of the given center
%point from the legal x,y range or a spesific arrow
global imRows;
global imCols;

%global array that holds distances for each line to the geometric
%center of the image. Filled in 'disFrmImgCntr' function
global disToExptcdCntr;


imName=FileName;

slashLocation = find(imName == '/');
dotLocation = find(imName == '.');

saveName = [OutputPathBase imName(slashLocation(end)+1:dotLocation(end)-1) '_Y.png'];
ErrorLogName=[OutputPathBase imName(slashLocation(end)+1:dotLocation(end)-1) '_Y_log.txt'];
swDebugLogName=[OutputPathBase imName(slashLocation(end)+1:dotLocation(end)-1) '_Y_debugLog.txt'];
croppedLogName=[OutputPathBase imName(slashLocation(end)+1:dotLocation(end)-1)  '_Y_croppedLog.txt'];



%Close all images currently open
close all;


%open the file containing the images names to test, for reading
%imgNameFid = fopen('..\imagesNames.txt');


%open a log file in append mode. Create the file if it does not exist
errLogFid = fopen(ErrorLogName, 'a');
%open a log file in overwirte mode. Create the file if it does not exist
swDebugLogFid = fopen(swDebugLogName, 'w');

if (1 == analyzeCroppedImages)
    %open a log file for the cropped images in append mode. Create the file if it does not exist
    croppedLogFid = fopen(croppedLogName, 'a');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop over the images defined in the file. The
% string "stopHere" in the images names file defines
% the last image to analyze.

%Get the image
%orgIm = imread(FileName);
imSize = size(orgIm);
imRows = imSize(1,1);

%Reduce image size so that analysis will not take forever.
%no need to reduce cropped image. They have already been reduce
%during crop
if (imRows >1300) && (0 == analyzeCroppedImages)
    orgIm = imresize(orgIm, 0.65);
end

%Get image dimensions
imSize = size(orgIm);
imRows = imSize(1,1);
imCols = imSize(1,2);

%Display the image
orgFigHandle = figure;
imshow(orgIm);
%title(imName);

%Run Canny detector to find the edhes in the image
edgesIm= edge(orgIm(:,:,3), 'canny', 0.2);


%Go over some of the points on the edges and check the perpendicular
%segment for aberrations.
[pointsRow , pointsCol] = find(edgesIm == 1);
points = horzcat(pointsRow,pointsCol);
pointsNum = size(points);
i = 1;

%Init the progress indicator
progressPercentage = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over points along the image edges. Inside this loop
% perpendicular segments to the edges are analyzed for aberration

for interestPoint=1 : 5 : pointsNum(1,1)
    
    %print progress every once in a whileto notify the user that everything is fine
    if (0 <= rem(interestPoint, pointsNum(1,1)/20) && rem(interestPoint, pointsNum(1,1)/20)<= 5)
        progressPercentage = progressPercentage + 5; %#ok<NOPRT>
    end
    
    
    %generate the perpendicular segment to the chosen edge
    %make sure that the angle of the edge is accurate - the other point
    %that is used during this calculation must be close enough to be
    %considered on the same edge
    
    %find another point which is at distance "calcDelta" from the current point
    tempX = ( (points(:,2) .* (-1)) + points(interestPoint,2) ).^2;
    tempY = ( (points(:,1) .* (-1)) + points(interestPoint,1) ).^2;
    [neighborsRow, neighborsCol] = find((tempX+tempY) <calcDelta & (tempX+tempY) >calcDelta/2  );
    neighbors = horzcat(neighborsRow,neighborsCol);
    neighborsSize = size(neighbors);
    %continue to analyze this point's region only if there is enough
    %neighbors to calculate the perpendicular segmant, AND the point is not
    %too close to the figure's edge
    if (neighborsSize(1,1) >= 2) && ((points(interestPoint,2) - segLen/2) > 0) && ...
            ((points(interestPoint,1) - segLen/2) > 0) && ...
            ((points(interestPoint,2)+segLen/2) < imCols) && ((points(interestPoint,1)+segLen/2) < imRows)
        
        %init the flags.
        % unsuitableSeg - true if the segment can not be used for
        %                                       aberration analysis (e.g. - it doesn't contain enough pixels)
        % verticalLine   - true if the segment is vertical
        unsuitableSeg = false;  %#ok<NASGU>
        verticalLine = false;
        
        %find the segment perpendicular to the edge
        %the edge's slope
        deltaX = points(neighbors(1,1),2)-points(neighbors(2,1),2);
        deltaY = points(neighbors(1,1),1)-points(neighbors(2,1),1);
        if 0 == deltaX
            deltaX = 0.0000000001;
        end
        edgeSlope = deltaY/deltaX;
        if 0 == edgeSlope
            edgeSlope = 0.0000000001;
        end
        perpSegSlope = -(1/edgeSlope);
        
        
        %The line is in the format of y=ax+b. First use the
        %known point to calculate b, which is: b=y-ax
        bVal = points(interestPoint,1) - perpSegSlope*points(interestPoint,2);
        
        %now, the end points of the line can be calculated. y=ax+b
        xStrt =points(interestPoint,2) - segLen/2;
        yStrt =perpSegSlope*xStrt+bVal;
        
        
        %take care of the vertical lines
        if yStrt < points(interestPoint,1) - segLen/2
            xStrt =points(interestPoint,2);
            yStrt = points(interestPoint,1) - segLen/2;
            verticalLine = true; %mark this is a vertical line
        else
            if yStrt > points(interestPoint,1) + segLen/2
                xStrt =points(interestPoint,2);
                yStrt = points(interestPoint,1) + segLen/2;
                verticalLine = true; %mark this is a vertical line
            end
        end
        
        
        xEnd = points(interestPoint,2)+segLen/2;
        yEnd = perpSegSlope*xEnd + bVal;
        
        
        %take care of the vertical lines
        if yEnd < points(interestPoint,1) - segLen/2
            xEnd =points(interestPoint,2);
            yEnd = points(interestPoint,1) - segLen/2;
            verticalLine = true; %mark this is a vertical line
        else
            if yEnd > points(interestPoint,1) + segLen/2
                xEnd =points(interestPoint,2);
                yEnd = points(interestPoint,1) + segLen/2;
                verticalLine = true; %mark this is a vertical line
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Verify that the segment contains enough pixels and that it
        %  doesn't cross more than a single edge in the image
        %
        
        %spline the start and end points to get all the points on the line
        %between them
        
        %spline can not manage identical values. Since when the line is
        %analyzed the x and y coordinates are casted to UINT16, the following change
        %does not affect the analysis result
        if xStrt == xEnd
            xStrt = xStrt +0.1;
        end
        if yStrt == yEnd
            yStrt = yStrt +0.1;
        end
        
        if xStrt < xEnd
            %assure that even if this is a vertical line, there are enough
            %values to analyze
            xSteps = min((xEnd - xStrt)/20, 1);
            lineXvals = xStrt : xSteps :xEnd; %spline steps
        else
            xSteps = min((xStrt - xEnd)/20, 1);
            lineXvals = xStrt : -xSteps :xEnd; %spline steps
        end
        lineYvals = spline([xStrt xEnd],  [yStrt yEnd], lineXvals);
        
        %%%%%%%
        %assure that the segment has one edge, thus- not crossing to an
        %adjacent region
        
        %get the segment's G values
        workingSeg = (single( diag(orgIm(uint16(lineYvals), uint16(lineXvals), 2)) ))';
        
        %Calculate the discrete derivative of the segment
        [r c] = size(workingSeg);
        workSegDerv =  ([workingSeg(1) workingSeg(1:c-1)] - workingSeg);
        
        %Locate the peaks of the derivative, which correspond to the edges
        %in the image
        peaks = zeros(1, c);
        peaks( (abs(workSegDerv)) >= peakThreshold) = 1;
        
        %Make sure that at least 1/5 of the segmnet length before and after
        %the peak is "smooth" to be sure that the segment is long enough to
        %be significant
        
        %first- remove noises of peaks of length 1
        mask = (1/3).*ones(1,3);
        orgPeaks = peaks;
        peaks = round(imfilter(peaks,mask, 'replicate', 'conv'));
        %remove single peaks that may have been left
        while (0 ~= sum(orgPeaks ~= peaks))
            orgPeaks = peaks;
            peaks = round(imfilter(peaks,mask, 'replicate', 'conv'));
        end
        workSegPeaks = find(peaks > 0);
        [rSeg cSeg]= size(workSegPeaks);
        
        %if the segment starts with an edge, try to find a "smooth" region
        startOffset = 0;
        while (cSeg > 1) && (workSegPeaks(1,1) < (1/5)*c)
            peaks = peaks(2:c-startOffset);
            startOffset = startOffset + 1;
            workSegPeaks = find(peaks > 0);
            [rSeg cSeg]= size(workSegPeaks);
        end
        lineXvals = lineXvals(1, startOffset+1:c);
        lineYvals = lineYvals(1, startOffset+1:c);
        xStrt = lineXvals(1, 1);
        yStrt = lineYvals(1, 1);
        
        [rSeg cSeg]= size(workSegPeaks);
        %now- check for the lengths
        if (cSeg > 0) && (workSegPeaks(1,1) >= (1/5)*c)
            n = workSegPeaks(1,1);
            edgeLen = 0;
            while (n <= c-startOffset) && 1 == peaks(1,n)
                n = n+1;
                edgeLen = edgeLen+1;
            end
            %require a minimal length for the edge
            if edgeLen >= 2
                %require a minimal length for the "smooth" suffix
                suffixLen = 0;
                while (n <= c-startOffset) && 0 == peaks(1,n)
                    n = n+1;
                    suffixLen = suffixLen+1;
                end
                if (suffixLen <  (1/5)*c)
                    unsuitableSeg = true;
                else
                    unsuitableSeg = false;
                end %end of: suffix is too short
            else
                unsuitableSeg = true;
            end
        else
            unsuitableSeg = true;
        end %end of: at least 1/5 of the segment's start is "smooth"
        
        
        
        
        if false == unsuitableSeg
            
            %%%%%%%%%%%%%%%%%%
            %   Analyze the segment   %
            %%%%%%%%%%%%%%%%%%
            
            %Only segments that were found suitable for analysis reach
            %this code
            
            if (n-1 < c-startOffset)
                lineXvals = lineXvals(1,1:n-1);
                lineYvals= lineYvals(1,1:n-1);
                xEnd = lineXvals(1, n-1);
                yEnd = lineYvals(1, n-1);
            end
            
            %Call the utility function to analyze the segment
            %perpendicular to the edge for aberratiobns
            
            [err(i) deltaX deltaY deltaZ errDirection]  = analyzeLine (orgIm, lineXvals, lineYvals, plotEdgeAnal); %#ok<AGROW>
            
            
            %fill in the a,b,c and sigma values for a line
            %equation of the form: ax+by+c=0
            if (false == verticalLine)
                linesPrms(1, i) = -perpSegSlope;%a parameter
                linesPrms(2, i) = 1;%b parameter
                linesPrms(3, i) = -bVal;%c parameter
            else
                linesPrms(1, i) = 1;%a parameter
                linesPrms(2, i) = 0;%b parameter
                linesPrms(3, i) = -xStrt;%c parameter
            end
            linesPrms(4, i) = err(i);%sigma parameter
            
            
            %%%%%%%%%%%%%%%%%%%%%%%
            %set the x and y leagal ranges
            if (1 == errDirection)
                xHead = xStrt;
                yHead = yStrt;
            else
                xHead = xEnd;
                yHead = yEnd;
            end
            
            %save the position of the arrow's head to later mark the
            %suspicious arrows and to identify the legal zone of the arrow
            linesPrms(9,i) = xHead;
            linesPrms(10,i) = yHead;
            
            %save the 2 points defining the edge which the arrow
            %corresponds to. If the arrow was defined as "vertical", stay
            %consistent with it when sending the edge points
            linesPrms(5, i) = points(neighbors(1,1),2);
            linesPrms(7, i) = points(neighbors(2,1),2);
            if (false == verticalLine)
                linesPrms(6, i) = points(neighbors(1,1),1);
                linesPrms(8, i) = points(neighbors(2,1),1);
            else
                linesPrms(6, i) = points(neighbors(2,1),1);
                linesPrms(8, i) = points(neighbors(2,1),1);
            end
            
            
            %for display purposes
            arrowHeadSize = max (err(i), 0.001)  *  1000;
            
            %Don't display arrows that are very small
            if (1 == diplayRes) && (arrowHeadSize > 13)
                showArrowLine = 1;
                figure(orgFigHandle);
                hold on;
                %display the arrow head in the right direction
                scatter(xHead,  yHead,  uint16(arrowHeadSize),   uint16 (arrowHeadSize),  'filled', 'yd',...
                    'MarkerEdgeColor','k');
                hold off;
            else
                showArrowLine = 0;
            end
            
            i = i+1;
            
        end %end of: false == unsuitableSeg
        
    else
        %the segment is not suitable for analysis
        unsuitableSeg = true;
        
    end %end of: points segment are not too close to the image's edge
    
    
    if (false == unsuitableSeg)
        if (1 == diplayRes) && (1 == showArrowLine)
            %Display the arrow's lineon the image
            figure(orgFigHandle);
            hold on;
            line( [xStrt xEnd], [yStrt yEnd],'color','r', 'LineWidth', 1);
            hold off;
        end
    end
    
    %reset the flag
    unsuitableSeg = false;  %#ok<NASGU>
    
end %end of: interestPoint for loop


%normalize the line parameters
linesPrms(4, : ) =linesPrms(4, : ) ./ (max(linesPrms(4, : )) * 3); % for the meanwhile, just make sure that the sigma values are not more than 1

%remove any left overs
linesPrms = linesPrms(:, 1:i-1);


figure(orgFigHandle);
hold on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find the center and remove outliers in an iterative manner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%init the array in which the outliers data is saved
outliersPrms = [];

for outlierRemCtr = 1 : outliersItrNum
    %init the array which will shortly be used by 'disFrmImgCntr'
    disToExptcdCntr = zeros(1,i-1);
    
    %find the point which minimizes the total distance to all lines. This
    %algorithm takes into account the direction to which the arrows point
    [center, fval] = fminsearch(@disFrmImgCntr,[imCols/2, imRows/2]); %#ok<NASGU>
    
    %plot the calculated center point on the image. As we progress with
    %the removal of the outliers, the center is plotted bigger
    plot(center(1), center(2),'-mo',  'MarkerEdgeColor','k', 'MarkerFaceColor','g',  'MarkerSize',5*outlierRemCtr);
    
    %%%%%%%%%%%%%%%%%%
    %Remove outliers               %
    %%%%%%%%%%%%%%%%%%
    %The outliers are calculated using a median outlier filter, based on
    %the weighted distance of each arrow to the calculated center. The
    %weighted distance of each arrow was calculated in 'disFrmImgCntr'.
    [filteredData outliersIndices] = medoutlierfilt(disToExptcdCntr', 0.8, 0);
    
    %save the removed outliers aside to plot them later
    outliersPrms = [outliersPrms, [linesPrms(9:10, outliersIndices) ; disToExptcdCntr(outliersIndices)] ]; %#ok<AGROW>
    %remove the outliers from the arrows matrix
    linesPrms(:, outliersIndices) = [];
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate the average angular error between
%   the geometric and calculated centers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
geoCntrCol = round(imCols/2);
geoCntrRow = round(imRows/2);


%init a matrix with the X values of each pixel
xVals = repmat([1:imCols], imRows, 1); %#ok<NBRAK>
%init a matrix with the Y values of each pixel
yVals = repmat([1:imRows]', 1, imCols); %#ok<NBRAK>
%calculate the X and Y errors from each pixel to the calculated center
calcCntrXerr = center(1) - xVals;
calcCntrYerr = center(2) - yVals;
%calculate the angle (in radians) of each pixel to the calculated
%center
angToCalcCntr = angle(calcCntrXerr + calcCntrYerr.*j);

%calculate the X and Y errors from each pixel to the geometric center
calcCntrXerr = geoCntrCol - xVals;
calcCntrYerr = geoCntrRow - yVals;
%calculate the angle (in radians) of each pixel to the geometric
%center
angToGeoCntr = angle(calcCntrXerr + calcCntrYerr.*j);

%calculate the absolute difference between the 2 angles at each pixel
angleErr = abs(angToCalcCntr - angToGeoCntr);
%if an angle was calculated to be bigger than 180 degrees (pi)
%bring it back to the range of 0-pi
bigAnglesIndices = angleErr > pi;
angleErr(bigAnglesIndices) = (2*pi) - angleErr(bigAnglesIndices);

%to do a smiliar work to farid, remove the vectors closest (2%) to the
%calculated center and to the real center. This simulates the removal of
%vectors with small norm
rowArea = (round(imRows*.01))
colArea = (round(imCols*.01))
realCntr = [geoCntrRow geoCntrCol]
calcCntr = round([center(2) center(1)])

if sum(calcCntr<0)
    calcCntr(calcCntr<0)=0;
    calcCntr=calcCntr+(calcCntr==0).*[rowArea+1 colArea+1];
end


[calcCntr(1)-rowArea :calcCntr(1)+rowArea, calcCntr(2)-colArea :calcCntr(2)+colArea]
angleErr(calcCntr(1)-rowArea :calcCntr(1)+rowArea, calcCntr(2)-colArea :calcCntr(2)+colArea) = 0;
angleErr(realCntr(1)-rowArea :realCntr(1)+rowArea, realCntr(2)-colArea :realCntr(2)+colArea) = 0;

averageAngleErr = rad2deg(mean2(angleErr));


%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results to the log file
%%%%%%%%%%%%%%%%%%%%%%%%%

%Save in file the following data:
%  1- image name
%  2- average angular error
%  3- Number of analyzed PBA events
%  4- Average strength of PBA events
%  5- STD of PBA events' strength
% 6- Number of events per 10-degrees slice (relative to the
%     geometric center)


fprintf(errLogFid, '%s , %3.2f, %d, %d, %d ', imName, averageAngleErr, i, mean (err(1:i-1)),  std (err(1:i-1)) );
%calculate the histogram for PBA events num per 10 dgrees slices
bins = -180 : 10 : 180;
histRes = histc (rad2deg (angToGeoCntr), bins);
numOfBins = size(bins);
for binIndex = 1 : numOfBins(2)
    %write the value to the file
    fprintf (errLogFid, ', %d ', sum (histRes (binIndex,:)) );
end
fprintf(errLogFid,' \n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display suspected regions on the image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create an intensity map of the errors
imgIntensityMap = zeros(imRows, imCols);
[r c] = size(outliersPrms);
for i=1 : c
    imgIntensityMap(round(outliersPrms(2,i)),round(outliersPrms(1,i))) ...
        = outliersPrms(3,i);
end

%soften the edges a bit
maskSize = 20;
mask = ones(2*maskSize, 2*maskSize) / ((2*maskSize)^2);
imgIntensityMap = imfilter(imgIntensityMap,mask);
imgIntensityMap = imfilter(imgIntensityMap,mask);
ContMap=contourc(imgIntensityMap, 15);

%display the contours of the suspected regions (highest contours
%levels) on the original image
overlayContourOnImage (orgFigHandle, ContMap, forgeryThresh);



%%%%%%%%%%%%%%%%%%%%%%%%
%analyze cropped images
%%%%%%%%%%%%%%%%%%%%%%%%
if (1 == analyzeCroppedImages)
    analyzeCroppedImage (center, cropPercentage, imName, imRows, imCols, orgFigHandle, croppedLogFid, swDebugLogFid)
end




%save the image with the center location and suspected regions marks

%hgsave(orgFigHandle,[dirName saveName]);
%export_fig(saveName);

%close images
close all;

%read the next image name


%end of: while loop over images to analyze


%%%%%%%%%%%
% Cleanup
%%%%%%%%%%%

%close the log file
fclose(errLogFid);
%close the images names file
%fclose(imgNameFid);
%close the SW debug log file
fclose(swDebugLogFid);

if (1 == analyzeCroppedImages)
    %close the log file for the cropped images
    fclose(croppedLogFid);
end