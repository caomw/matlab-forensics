%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name: 
%       analyzeLine
%
%   Abstract:
%       The purpose of this function is to find weak traces of purple fringes
%       in an image, using the xyY color space characteristics.
%
%   Written by:
%       Ido Yerushalmy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Parameters - 
%
%   orgIm - an image to work on, in RGB format
%   lineX - a vector with the X cordinates of the line (columns values)
%   lineY - a vector with the Y cordinates of the line (rows values)
%   plotRes - 1 if a plot should be generated, 0 otherwise
%
%Return Values -
%   err - the nomalized error according to the ideal line
%
%   deltaX/Y/Z - the differenc in X/Y/Z color space between the star and
%                            end points
%
%   errDirection - the direction the aberration "points" to. 0 if the
%                                   direction is from the start point to the end point (as given in the
%                                      input) and 1 otherwise
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [err deltaX deltaY deltaZ errDirection]  = analyzeLine (orgIm, lineX, lineY, plotRes)

% Local Variables:
%   This parameter defines the offset of the point used as "maximum distance point
%   from the ideal line". For example: if this flag is set to 0, the furthest
%   away point is chosen. If it is set to 2, the point which is only 2nd from 
%   the most further point is used. 
%   This parameter allows skipping some points to avoid image noise interferance 
maxPntToUseOffset = 2;


%Cast to integer type required by functions below
orgIm = uint8(orgIm);
lineX = uint16(lineX);
lineY = uint16(lineY);

%get the relevant section that should be analyzed
imToAnalyze = orgIm(lineY,lineX,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Transform the analyzed segment from RGB to xyY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a color transformation structure for XYZ
transStruc = makecform('srgb2xyz');

%Perform the conversion to XYZ
XYZImageSq = xyz2double( applycform(imToAnalyze, transStruc)  );
%get only the points at the requested line, not the entire square denoted
%by lineX and lineY
[sqImgRows, sqImgCols, sqImgLayers] = size(XYZImageSq);
XYZImage = zeros(sqImgRows, 1, sqImgLayers);
for i=1 : sqImgLayers
    XYZImage(:,:,i) = diag( XYZImageSq(:,:,i));
end

%turn from XYZ into xyY
transStruc = makecform('xyz2xyl');
xyYImage = applycform(XYZImage, transStruc);

[rows, cols] = size(xyYImage(:,:,1));

if 1 == plotRes
    %Plot the data for different zones
    figure;
    plot3( xyYImage(:,:,1),xyYImage(:,:,2), xyYImage(:,:,3) , '*g', 'MarkerSize', 8, ...
        'MarkerEdgeColor','k') ;
    hold on;
    grid on;
    axis square;

    title('xyY color space' ,'FontSize',18);
    xlabel('x','FontSize',14);
    ylabel('y','FontSize',14);
    zlabel('Y','FontSize',14);
end %plotRes == 1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate the difference between the ideal linear line and the current result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xPoints = reshape( xyYImage(:,:,1), 1, rows*cols);
yPoints = reshape( xyYImage(:,:,2), 1, rows*cols);

%get the first and last points of the analyzed segment
xStart = xyYImage(1,1,1);
yStart = xyYImage(1,1,2);
YStart = xyYImage(1,1,3);
xEnd = xyYImage(rows,cols,1);
yEnd = xyYImage(rows,cols,2);
YEnd = xyYImage(rows,cols,3);


if 1 == plotRes
    %plot the ideal line on the same axis
    line([xStart,xEnd], [yStart,yEnd], [YStart,YEnd], 'LineWidth',4,'Color',[.8 .8 .8]);
    %mark the start and end points
    plot3(xStart, yStart,YStart, '-ms',  'MarkerEdgeColor','k', 'MarkerFaceColor','r',  'MarkerSize',15);
    plot3(xEnd, yEnd,YEnd, '-mo', 'MarkerEdgeColor','k', 'MarkerFaceColor','k',  'MarkerSize',15);
end % 1 == plotRes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate the error:
%calculate the point-to-segment distance of all points from the ideal line.

%1- get the normalized vector of the ideal line
lineVector = [xEnd yEnd] - [xStart yStart];
m = lineVector ./ normest(lineVector);

l = [xPoints ; yPoints] - repmat([xStart ; yStart], 1,rows*cols);

%2- the actual distance of the points  along the idal line from the
%start point
d1 = (l'*m')';


%3- All d1 points that are less than 0, are beyond the limits of the ideal line.
%For those points, do not calculate the distance to the
%ideal line extension, but the euclidian dstance to the start point
eucDistance = zeros(1, rows*cols);
%points of interest in d1
eucPoints = (find(d1<0));
eucDistance(eucPoints) =sqrt(  (l(1,eucPoints)).^2   + (l(2,eucPoints)).^2  );


%4- All d1 points that are bigger than the distance between the start and
%end points of the ideal line, are beyond the limits of the ideal line.
%For those points, do not calculate the distance to the
%ideal line extension, but the euclidian dstance to the start point

%points of interest in d1
eucPoints = (find(d1>d1(rows*cols) ));
%calculate the distance from the end point
idealLineLen =  [xPoints ; yPoints] - repmat([xEnd ; yEnd], 1,rows*cols);
eucDistance(eucPoints) =sqrt(  (idealLineLen(1,eucPoints)).^2   +...
    (idealLineLen(2,eucPoints)).^2  );

if 1 == plotRes
    %mark the points
    plot3(xPoints(eucPoints), yPoints(eucPoints), ones(size(eucPoints)), 'Vc', 'MarkerSize', 12, ...
        'MarkerEdgeColor','k', 'MarkerFaceColor', 'k');
end%1 == plotRes


% 5- Get the distance of the points from the ideal line

%first, find the angle between the 2 vectors (1 vector along the ideal line
%and the other pointing from the start point towards the tested point)

%(a) - get the un-normalized vector along the ideal line
newM = (repmat(m',1,rows*cols) .*repmat(d1,2,1))';

angle = zeros(1,rows*cols);
%first and last points are the start and end points, so we already know
%they have an angle of 0 with themselves
for i=2 : ((rows*cols)-1)
    % (b) - calculate the angle. Use the fact that: 
    %angle(2 vectors x and y)= arccos((x*y) ./ (norm(x).*norm(y)))
    angle(i) = acosd((newM(i,:)*l(:,i))./ (norm(newM(i,:)) * norm(l(:,i))));
end

%points very close to the ideal line have an imaginary part, although they
%should be treated as 0. Handle that
angle = real(angle);

% (c) - use the fact that tan(angle) is the distance of the tested point from
%the ideal line / its distance along the ideal line (which was already
%calculated in d1)
d2 = abs(d1 .* tand(angle));

%Merge the distance calculated for points beyond the ideal line with the
%distance of those inside the accepted region
d2 = max(d2, eucDistance);

%Find and plot the point of (almost) maximum distance from the ideal line.
%Skip the maximum point by 'maxPntToUseOffset' to avoid getting confused by image noises
d3 = sort(d2, 'descend');
maxDisPoint = find( d2 == d3(1,1+maxPntToUseOffset) );
maxDisPoint = maxDisPoint(1,1);


if 1 == plotRes
    plot3(xPoints(maxDisPoint), yPoints(maxDisPoint),2, ...
        '-mh', 'MarkerEdgeColor','k', 'MarkerFaceColor','y',  'MarkerSize',14);
end

%Return the change in values between the start and end colors in the XYZ
%domain
deltaX = abs(XYZImage(1,1,1) - XYZImage(rows,cols,1) );
deltaY = abs(XYZImage(1,1,2) - XYZImage(rows,cols,2) );
deltaZ = abs(XYZImage(1,1,3) - XYZImage(rows,cols,3) );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the aberration along the vector pointing towards the blue-purple region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if this is a blue-purple aberration, it "points" from the darker region
%to the brigter one. If the aberration is more yellow, it is the other way around.
%The luminocity is calculated as (X+Y+Z)/3

xMidPoint = (xEnd+xStart)/2;
yMidPoint= (yEnd+yStart)/2;
%generate a normalized vector from the midpoint of the tested segment to 
%the blue region of the xy color space (chromaticity-plane) 
xBlue = 0.2;
yBlue = 0.1;
blueVector = [xMidPoint ; yMidPoint] - [xBlue ; yBlue];
m = blueVector ./ normest(blueVector);
%gnerate a vector from the midpoint to the error-defining point
l =  [xMidPoint yMidPoint] - [xPoints(maxDisPoint), yPoints(maxDisPoint)];

%calculate the length of the error-vector in the blue direction.
%If it is negative  the aberration is towards the yellow section
distFromBlue = (l*m);


if 1 == plotRes
    %mark the refference blue point
    plot3(xBlue, yBlue,1, '-mo', 'MarkerEdgeColor','k', 'MarkerFaceColor',[0.1 0.1 .5],  'MarkerSize',8);
    hold off;
end % plotRes == 1



%%%%%%%%%%%%%%%%%
% Calculate the error
%%%%%%%%%%%%%%%%%


%Version 1:
% the maximum point-to-segment distance from the ideal line
err = d3(1,1+maxPntToUseOffset);


%Vesion 2:
%take into account the direction of the error
err = abs(err * distFromBlue)*50; %*50 just to have similar values as version 1

%Version 4:
% Take into account the abberation model. If the analyzed segment has
% crossed regions of SMILAR luminocity, the error should be smaller
startLuminocity = (XYZImage(1,1,1) +XYZImage(1,1,2) + XYZImage(1,1,3)) / 3;
endLuminocity = (XYZImage(rows,cols,1) +XYZImage(rows,cols,2) + XYZImage(rows,cols,3)) / 3;
err = err *(abs(startLuminocity - endLuminocity));


if startLuminocity < endLuminocity
    if distFromBlue > 0
        errDirection = 0;
    else
        errDirection = 1;
    end
else
    if distFromBlue > 0
        errDirection = 1;
    else
        errDirection = 0;
    end
end



