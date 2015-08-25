function [b, eH, HorzMid, eV, VertMid, BlockDiff] = GetBlockGrid(im)

    
    YCbCr=rgb2ycbcr(double(im));
    Y=YCbCr(:,:,1);
    
    % This thresh is used to remove extremely strong edges:
    % block edges are definitely going to be weak
    DiffThresh=50;
    
    %Accumulator size. Larger may overcome small splices, smaller may not
    %aggregate enough.
    AC=33;
    
    
    Im2DiffY=-diff([Y(1,:); Y ; Y(end,:)],2);
    Im2DiffY(abs(Im2DiffY)>DiffThresh)=0;
    padded=padarray(Im2DiffY,[0 round((AC-1)/2)],'symmetric');
    summedH = filter2(ones(1,AC), abs(padded),'same');
    summedH = summedH(:,round((AC-1)/2)+1:end-round((AC-1)/2));
    mid=medfilt2(summedH,[AC 1],'symmetric');
    eH=summedH-mid;
    paddedHorz=padarray(eH,[16 0],'symmetric');
    HorzMid(:,:,1)=paddedHorz(1:end-32,:);
    HorzMid(:,:,2)=paddedHorz(9:end-24,:);
    HorzMid(:,:,3)=paddedHorz(17:end-16,:);
    HorzMid(:,:,4)=paddedHorz(25:end-8,:);
    HorzMid(:,:,5)=paddedHorz(33:end,:);
    HorzMid=median(HorzMid,3);
    
    
    
    Im2DiffX=-diff([Y(:,1) Y Y(:,end)] ,2,2);
    Im2DiffX(abs(Im2DiffX)>DiffThresh)=0;
    padded=padarray(Im2DiffX,[round((AC-1)/2) 0],'symmetric');
    summedV = filter2(ones(AC,1), abs(padded),'same');
    summedV = summedV(round((AC-1)/2)+1:end-round((AC-1)/2),:);
    mid=medfilt2(summedV,[1 AC],'symmetric');
    eV=summedV-mid;
    paddedVert=padarray(eV,[0 16],'symmetric');
    VertMid(:,:,1)=paddedVert(:,1:end-32);
    VertMid(:,:,2)=paddedVert(:,9:end-24);
    VertMid(:,:,3)=paddedVert(:,17:end-16);
    VertMid(:,:,4)=paddedVert(:,25:end-8);
    VertMid(:,:,5)=paddedVert(:,33:end);
    VertMid=median(VertMid,3);
	
    
    BlockDiff=HorzMid+VertMid;
    
    b=blockproc(BlockDiff,[8 8],@BlockValue,'PadPartialBlocks',1);
    
end