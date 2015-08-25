function l = SLIC_Colour( im )
    %SEGMENTIMAGE Summary of this function goes here
    %   Detailed explanation goes here
    
    maxSize=1*2*2^20; %2 MPixel max (*rgb), otherwise split
    
    BaseSegmentNumber=750;
    
    if numel(im)<maxSize
        l = slic(im, round(numel(im)/3/BaseSegmentNumber), 5, 1, 'median',0,3);
    else
        tic
        nsegments=ceil(numel(im)/maxSize);
        D=size(im);
        l=zeros([D(1) D(2)]);
        BaseAdd=0;
        XMax=2;
        YMax=2;
        if nsegments>4 && nsegments<=6 
            [~,LargeDim]=max(D);
            if LargeDim==1
                XMax=3;
            else
                YMax=3;
            end
        elseif nsegments<=9 
            XMax=3;
            YMax=3;
        else 
            XMax=3;
            YMax=3;
            [~,LargeDim]=max(D);
            if LargeDim==1
                XMax=4;
            else
                YMax=4;
            end            
        end
        disp([XMax YMax])
        SegHeight=ceil(D(1)/XMax);
        SegWidth=ceil(D(2)/YMax);
        for X=1:SegHeight:D(1)-SegHeight+1
            for Y=1:SegHeight:D(2)-SegWidth+1
                tic
                ImSegment=im(X:min(X+SegHeight-1,end),Y:min(Y+SegWidth-1,end),:);
                lSeg = slic(ImSegment, round(numel(ImSegment)/3/BaseSegmentNumber), 5, 1, 'median',0,3);
                lSeg=lSeg+BaseAdd;
                BaseAdd=max(max(lSeg));
                l(X:X+SegHeight-1,Y:Y+SegWidth-1)=lSeg;
                toc
            end
        end
        toc
    end
end