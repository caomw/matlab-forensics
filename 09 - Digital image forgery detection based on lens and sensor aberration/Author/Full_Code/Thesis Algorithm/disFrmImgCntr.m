%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name: 
%       disFrmImgCntr
%
%   Abstract:
%       This function uses the line equations calculated for the edges of the
%       image, and calculates the total distance of the center point given in the
%       input parameter from the lines.
%       The function is used by fminsearch in order to minimize the total
%       distance of the center point from all lines
%
%   Written by:
%       Ido Yerushalmy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Parameters - 
%       cntrCords - a vector (1x2) of the form (xCenter, yCenter) which
%                                  defines the location of the tested center point
%
% Return Values -
%       totDistance - The total distance of all lines from the given point
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function totDistance = disFrmImgCntr (cntrCords )

% This global vector is set in 'findAberrations' function
% Vector structure:
%   10 rows (a,b,c, sigma, borderX1, borderY1, borderX2, borderY2, lglZoneX, lglZoneY). One column per
%   calculated line
global linesPrms;

%global variables that hold the size of the analyzed image. They are set in
%'findAberrations' function
global imRows;
global imCols;

%global array that holds distances for each line to the geometric 
%center of the image
global disToExptcdCntr;

%maximum distance across the image's diagonal
maxDistance = sqrt(imRows^2 + imCols^2);

%init the return value
totDistance = 0;

%get the number of calculated lines
[r linesNum] = size(linesPrms);

for i=1: linesNum
    %if the center point is in the illegal zone (not inside the valid
    %region of x and y coordiantes), calculate a penalty factor
    
    %use the fact that if the sign of the determinant of the 3 given points
    %(which reside inside the legal zone) is different than the sign of
    %detrminant of the 2 border points + the cntr tested ten the center is
    %in the ILLEGAL zone
    legalDet = det([1 linesPrms(5,i) linesPrms(6,i); 1 linesPrms(7,i) linesPrms(8,i); 1 linesPrms(9,i) linesPrms(10,i)]);
    cntrDet  = det([1 linesPrms(5,i) linesPrms(6,i); 1 linesPrms(7,i) linesPrms(8,i); 1 cntrCords(1) cntrCords(2)]);
    
    if ( sign(legalDet) == sign(cntrDet) )
        cntrInValidZone = true;
    else
        cntrInValidZone = false;
    end



    if ( true == cntrInValidZone )
        %this is a point in the leagal range of this 'arrow'
        penaltyFactor = 0;

    else

        %this point is in the 'wrong' dirction of the 'arrow'. Add a
        %penalty factor to the distance calculation

        %calculate the shortest distance from the tested center to the
        %border of the legal zone

        %1- get the normalized vector of the border line (edge)
        lineVector = [linesPrms(5,i) linesPrms(6,i)] - [linesPrms(7,i) linesPrms(8,i)];
        m = lineVector ./ normest(lineVector);

        %2- get the vector to the tested center point
        l = [cntrCords(1); cntrCords(2)] - [linesPrms(7,i);linesPrms(8,i)];
        
        %3- calculate the actual distance of the center point along the border line from the start point
        d1 = (l'*m')'; 
        
        %4-get the un-normalized vector along the border line
        newM = (m' .* repmat(d1,2,1))';

        %5- calculate the angle. Use the fact that:
        %angle(2 vectors x and y)= arccos((x*y) ./ (norm(x).*norm(y)))
        angle = acosd((newM*l)./ (norm(newM) * norm(l)));

        %6- use the fact that tan(angle) is the distance of the tested point from
        %the border line / its distance along the border line (which was already
        %calculated in d1)
        distToLegalRange = abs(d1 .* tand(real(angle)));

        %7- normalize the distance as a factor of the image's size
        distToLegalRange = distToLegalRange ./ maxDistance;
        
        %8- give penalty relative to the distance of the
        %point from the leagal range. Note that distToLegalRange is already
        %normalized (percentage of maximum possible distance). 
        penaltyFactor = max(10, linesPrms(4,i) * 50000000000 * distToLegalRange); 

    end %end of: center is in the illegal zone

    
    %save the distance of each line from the tested center point.
    %This information is used later to dtect lines which do not point
    %towards the expected center, thus presumed to be forged.
    disToExptcdCntr(i) = ( ((linesPrms(1,i)*cntrCords(1) +...
        linesPrms(2,i)*cntrCords(2) + linesPrms(3,i)) / ...
        (1-linesPrms(4,i))) ^2 ...
        ) + penaltyFactor;

    totDistance = totDistance +  disToExptcdCntr(i);


end %end of: for loop



