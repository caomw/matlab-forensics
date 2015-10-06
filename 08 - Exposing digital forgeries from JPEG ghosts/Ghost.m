function [OutputX, OutputY, dispImages, imin, Qualities, mins]=Ghost(imorig, checkDisplacements, smoothFactor)

%checkDisplacements: whether to run comparisons for all 8x8 displacements in order to find the
%best NA-match. 1 for true, 0 for false (just use (0,0)).

%smoothFactor=moving average size

%close all;
%clear all;

minQ=51;
maxQ=100;
stepQ=1;

if checkDisplacements==1
    maxDisp=7;
else
    maxDisp=0;
end

mins=[];
Output=[];

smoothing_b=17;

Offset=(smoothing_b-1)/2;
    
for ii=minQ:stepQ:maxQ
    imwrite(imorig,'tmpResave.jpg','JPEG','Quality',ii);
    tmpResave=double(imread('tmpResave.jpg'));
    Deltas=[];
    overallDelta=[];
    for dispx=0:maxDisp
        for dispy=0:maxDisp
            DisplacementIndex=dispx*8+dispy+1;
            tmpResave_disp=tmpResave(1+dispx:end,1+dispy:end,:);
            imorig_disp=double(imorig(1:end-dispx,1:end-dispy,:));            
            Comparison=(imorig_disp-tmpResave_disp).^2;

            h = fspecial('average', smoothing_b);
            for jj=1:size(Comparison,3)
                Comparison(:,:,jj)=filter2(h,Comparison(:,:,jj));
            end
            Comparison=Comparison(Offset+1:end-Offset,Offset+1:end-Offset,:);
            
            Deltas{DisplacementIndex}=mean(Comparison,3);
            %Deltas{DisplacementIndex}(1:5,1:5)
            %Deltas{DisplacementIndex}(end-4:end,end-4:end)
            overallDelta(DisplacementIndex)=mean(mean(Deltas{DisplacementIndex}));
        end
    end
    
    
    [minOverallDelta,minInd]=min(overallDelta);
    mins((ii-minQ)/stepQ+1)=minInd;
    Output((ii-minQ)/stepQ+1)=minOverallDelta;
    delta=Deltas{minInd};
    delta=(delta-min(min(delta)))/(max(max(delta))-min(min(delta)));
    
    dispImages{(ii-minQ)/stepQ+1}=imresize(single(delta),round(size(delta)/4),'method','box');
end



OutputY=Output;
OutputX=minQ:stepQ:maxQ;
%OutputY=smooth(OutputY,smoothFactor);
[xmax,imax,xmin,imin] = extrema(OutputY);
imin=sort(imin);
Qualities=imin*stepQ+minQ-1;
