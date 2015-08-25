function [F1Map, F2Map, CFAOut]=CFATamperDetection(im,NoiseThresh)
    
    if nargin<2
        NoiseThresh=1;
    end
    
    StdThresh=5;
    Depth=3;
    
    im=im(1:round(floor(end/(2^Depth))*(2^Depth)),1:round(floor(end/(2^Depth))*(2^Depth)),:);
    
    SmallCFAList={[2 1;3 2] [2 3;1 2] [3 2;2 1] [1 2;2 3]};
    %LargeCFAList={ [1 2;2 3] [3 2;2 1] [2 1;3 2]  [2 3;1 2] [1 2; 3 1] [1 3;2 1] [2 1;1 3] [3 1;1 2] [3 1;2 3] [3 2;1 3] [1  3;3 2] [2 3;3 1]                  [1 2;1 3] [1 3;1 2] [1 1;2 3] [1 1;3 2] [2 1;3 1] [3 1;2 1] [2 3;1 1] [3 2;1 1] [3 1;3 2] [3 2;3 1] [3 3;1 2] [3 3;2 1] [1 3;2 3] [2 3;1 3] [1 2;3 3] [2 1;3 3]                                                   [2 1;2 3] [2 3;2 1] [2 2;1 3] [2 2;3 1]  [1 2;3 2] [3 2;1 2] [1 3;2 2] [3 1;2 2]};
    
    CFAList=SmallCFAList;
    
    %block size
    W1=16;
    W2=96;
    W2Overlap=round(W2/2);
    
    GChannel=double(im(:,:,2));
    GDenoised=DTWDenoise(GChannel,NoiseThresh,Depth);
    GNoiseResidue=GChannel-GDenoised;

    
    
    MeanError=inf(length(CFAList),1);
    for TestArray=1:length(CFAList)
        BinFilter=[];
        ProcIm=[];
        CFA=CFAList{TestArray};
        R=CFA==1;
        G=CFA==2;
        B=CFA==3;
        BinFilter(:,:,1)=repmat(R,size(im,1)/2,size(im,2)/2);
        BinFilter(:,:,2)=repmat(G,size(im,1)/2,size(im,2)/2);
        BinFilter(:,:,3)=repmat(B,size(im,1)/2,size(im,2)/2);
        CFAIm=uint8(double(im).*BinFilter);
        BilinIm=bilinInterp(CFAIm,BinFilter,CFA);
        
        ProcIm(:,:,1:3)=im;
        ProcIm(:,:,4:6)=BilinIm;
        BlockResult=blockproc(ProcIm,[W1 W1],@eval_block);
        
        Stds=BlockResult(:,:,4:6);
        BlockDiffs=BlockResult(:,:,1:3);
        NonSmooth=Stds>StdThresh;
        
        MeanError(TestArray)=mean(mean(mean(BlockDiffs(NonSmooth))));
        BlockDiffs=BlockDiffs./repmat(sum(BlockDiffs,3),[1 1 3]);
        
        %imagesc(BlockDiffs);
        %pause;
        
        Diffs(TestArray,:)=reshape(BlockDiffs(:,:,2),1,numel(BlockDiffs(:,:,2)));
        
        F1Maps{TestArray}=BlockDiffs(:,:,2);
    end
    Diffs(isnan(Diffs))=0;
    
    [bbb,val]=min(MeanError);
    U=sum(abs(Diffs-0.25),1);
    F1=median(U);
    CFAOut=CFAList{val}==2;
    F1Map=F1Maps{val};
    
    CFAGreen=repmat(CFAOut,round(size(GChannel,1)/2),round(size(GChannel,2)/2));
    
    ForVarExtraction(:,:,1)=GNoiseResidue;
    ForVarExtraction(:,:,2)=CFAGreen;
    Vars=blockproc(ForVarExtraction,[W2-W2Overlap W2-W2Overlap],@getCFAVar,'BorderSize',[W2Overlap W2Overlap],'PadMethod','symmetric','TrimBorder',0);
    VarRatios(:,:,1)=Vars(:,:,1)./Vars(:,:,2);
    VarRatios(:,:,2)=Vars(:,:,2)./Vars(:,:,1);
    F2Map=1./max(VarRatios,[],3);
end

function [ Out ] = eval_block( block_struc )
    %EVAL_BLOCK Summary of this function goes here
    %   Detailed explanation goes here
    im=double(block_struc.data);
    Out(:,:,1:3)=mean(mean((double(block_struc.data(:,:,1:3))-double(block_struc.data(:,:,4:6))).^2));
    Out(:,:,4)=std(reshape(im(:,:,1),1,numel(im(:,:,1))));
    Out(:,:,5)=std(reshape(im(:,:,2),1,numel(im(:,:,2))));
    Out(:,:,6)=std(reshape(im(:,:,3),1,numel(im(:,:,3))));
end


function [ Var ] = getCFAVar( block_struc )
        blockdata=double(block_struc.data);
        G=blockdata(:,:,1);
        G_CFA=boolean(blockdata(:,:,2));
        GOrig=G(G_CFA);
        GInterp=G(~G_CFA);
        Var(:,:,1)=var(GOrig);
        Var(:,:,2)=var(GInterp);
end
