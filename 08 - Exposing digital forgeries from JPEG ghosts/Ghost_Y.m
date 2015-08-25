function [OutputX, OutputY, dispImages, imin, Qualities]=Ghost_Y(imorig, checkDisplacements, smoothFactor)

%checkDisplacements: whether to run comparisons for all 8x8 displacements in order to find the
%best NA-match. 1 for true, 0 for false (just use (0,0)).

%close all;
%clear all;

minQ=15;
maxQ=100;
stepQ=1;

if checkDisplacements==1
    maxDisp=7;
else
    maxDisp=0;
end

mins=[];
Output=[];

imYCbCr=rgb2ycbcr(imorig);

for ii=minQ:stepQ:maxQ
    imwrite(imorig,'tmpResave.jpg','JPEG','Quality',ii);
    tmpResave=imread('tmpResave.jpg');
    
    tmpResaveYCbCR=rgb2ycbcr( tmpResave);
    
    
    Deltas=[];
    overallDelta=[];
    for dispx=0:maxDisp
        for dispy=0:maxDisp
            DisplacementIndex=dispx*8+dispy+1;
            tmpResave_disp=tmpResaveYCbCR(1+dispx:end,1+dispy:end,:);
            imorig_disp=imYCbCr(1:end-dispx,1:end-dispy,:);
            
            Comparison=(imorig_disp(:,:,1)-tmpResave_disp(:,:,1)).^2;
            h = fspecial('average', 3);
            
            Comparison=filter2(h,Comparison);
            
            Deltas{DisplacementIndex}=Comparison;
            overallDelta(DisplacementIndex)=mean(mean(Deltas{DisplacementIndex}));
            
        end
    end
    
    
    [minOverallDelta,minInd]=min(overallDelta);
    mins((ii-minQ)/stepQ+1)=minInd;
    Output((ii-minQ)/stepQ+1)=minOverallDelta;
    delta=Deltas{minInd};
    delta=(delta-min(min(delta)))/(max(max(delta))-min(min(delta)));
    
    dispImages{(ii-minQ)/stepQ+1}=delta;
end

OutputY=Output;
OutputX=minQ:stepQ:maxQ;
OutputY=smooth(OutputY,smoothFactor);
[xmax,imax,xmin,imin] = extrema(OutputY);
Qualities=imin*stepQ+minQ-1;


%does this ever return ~=1???
%disp(mins);