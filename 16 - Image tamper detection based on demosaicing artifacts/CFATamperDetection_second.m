function F2=CFATamperDetection(im)
    %block size
    W2=48;
    W2Overlap=round(W2/2);
    
    GChannel=double(im(:,:,2));
    %We don't need CFA estimation here! The two diagonals are
    %interchangeable in any case...
    %CFAOut = DetectCFAPattern(im);
    CFAOut=[0 1;1 0]>0;
    CFAGreen=repmat(CFAOut,round(size(GChannel,1)/2),round(size(GChannel,2)/2));
    
    PT=double(CFAGreen>0);
    P=double(PT(1:W2,1:W2));
    
    ForVarExtraction(:,:,1)=GChannel;
    ForVarExtraction(:,:,2)=CFAGreen;
    F2=blockproc(ForVarExtraction,[W2-W2Overlap W2-W2Overlap],@getCFAVar,'BorderSize',[W2Overlap W2Overlap],'PadMethod','symmetric','TrimBorder',0,'UseParallel',1);
end

function [ F2 ] = getCFAVar( block_struc )
    %Wavelet Depth
    Depth=5;
    
    blockdata=double(block_struc.data);
    G=blockdata(:,:,1);
    GNoise=DTWDenoise(G,Depth);
    G_CFA=boolean(blockdata(:,:,2));
    GOrig=GNoise(G_CFA);
    GInterp=GNoise(~G_CFA);
    var1=var(GOrig);
    var2=var(GInterp);
    F2=max([var1/var2 var2/var1]);
end