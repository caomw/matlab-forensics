function F=TestParametersOnTrainSet(AlgorithmName,Quality,MaskInd,MaskThreshold,CloseR,OpenR,Close2R,WriteFiles,WriteRaw)
    
    if nargin==0
        AlgorithmName='01';
        Quality=100;
        MaskInd=1;
        MaskThreshold=0.6;
        CloseR=6;
        OpenR=10;
        Close2R=0;
        WriteFiles=false;
        WriteRaw=false;
    end
    
    %if the algorithm returns multiple masks, which to use
    
    %at which value to threshold the mask
    
    if Quality==0
        ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
    else
        ImageRoot=['/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Resaved/' num2str(Quality) '_0/'];
    end
    
    InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
    InputDir=[InputRoot AlgorithmName '/' num2str(Quality) '_0/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake/'];
    MaskRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/';
    
    InputList=dir([InputDir '*.mat']);
    
    OutputDir=['/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st Image Forensics Challenge/MyTrainingTests/' AlgorithmName '_' num2str(Quality) '_' num2str(MaskInd) '_' num2str(MaskThreshold) '_' num2str(CloseR) '_' num2str(OpenR) '_' num2str(Close2R) '/'];
    
    if WriteFiles
        mkdir(OutputDir);
    end
    for InputFile=1:length(InputList)
        L=load([InputDir InputList(InputFile).name]);
        Map=GetAlgorithmInputMap(L,AlgorithmName);
        Map=Map{MaskInd};
        if Quality==0
            MaskFile=L.Name;
        else
            MaskFile=L.Name(1:end-4);
        end
        TrueMask=CleanUpImage([MaskRoot MaskFile]);
        TrueMask=mean(double(TrueMask),3)>0;
        if mean(TrueMask(:))<0.55
            TrueMask=~TrueMask;
        end
        
        Map=imresize(Map,size(TrueMask));
        %Tampered should be 0, pristine should be 255
        BinMask=(Map<MaskThreshold);
        
        S=strel('disk',CloseR);
        BinMask=imclose(BinMask,S);
        
        S=strel('disk',OpenR);
        BinMask=imopen(BinMask,S);
        
        S=strel('disk',Close2R);
        BinMask=imclose(BinMask,S);
        
        TP=sum(BinMask(TrueMask==0)==0);
        %FP=sum(BinMask(TrueMask==1)==1);
        if TP>0
            Prec=TP/sum(~BinMask(:));
            Rec=TP/sum(~TrueMask(:));
            F(InputFile)=2*(Prec*Rec)/(Prec+Rec);
        else
            F(InputFile)=0;
        end
        %SuccessMap=~xor(BinMask,TrueMask);
        
        if WriteFiles
            OutputIm=[BinMask zeros(size(BinMask,1),20) TrueMask];
            [pathstr,MaskName,MaskExt]=fileparts(L.Name);
            imwrite(OutputIm,[OutputDir MaskName '.' MaskExt]);
            if WriteRaw
                imwrite(Map/max(max(Map)),[OutputDir MaskName '_raw.' MaskExt]);
            end
        end
    end
end