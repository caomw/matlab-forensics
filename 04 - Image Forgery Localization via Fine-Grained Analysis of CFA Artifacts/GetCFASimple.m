function [bayer, F1]=GetCFASimple(im)
    
    %block size
    W1=16;
    %St. dev threshold
    StdThresh=5;
    
    SmallCFAList={[2 1;3 2] [2 3;1 2] [3 2;2 1] [1 2;2 3]};
    CFAList=SmallCFAList;
    
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
    
    bayer=CFAOut;

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