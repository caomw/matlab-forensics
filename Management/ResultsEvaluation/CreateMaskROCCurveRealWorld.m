function Report=CreateMaskROCCurveRealWorld(AlgorithmName, ThreshRange)
    
    ThreshStep=(ThreshRange(2)-ThreshRange(1))/500;
    ThreshValues=[-inf ThreshRange(1):ThreshStep:ThreshRange(2) inf];
    
    ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
    InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';
    Datasets=load('../../Datasets_Linux.mat');
    MatFileList=getAllFiles([InputRoot AlgorithmName '/WildWeb/'],'*.mat',true);
    
    
    Report.ThreshRange=ThreshValues;
    
    ActualSetInd=1;
    MatFileInd=1;
    while MatFileInd<=length(MatFileList)
        %wrap related subcases into one
        L=load(MatFileList{MatFileInd});
        [FilePath,FileName,Extension]=fileparts(MatFileList{MatFileInd});
        Undersc=strfind(FileName,'_');
        Undersc=Undersc(end);
        if ~isempty(str2num(FileName(Undersc-1)))
            NameEnd=Undersc-2;
            NameBase=FileName(1:Undersc-2);
        else
            NameEnd=Undersc-1;
            NameBase=FileName(1:Undersc-1);
        end
        MatFileInd=MatFileInd+1;
        if MatFileInd<=length(MatFileList)
            [FilePath,FileName2,Extension]=fileparts(MatFileList{MatFileInd});
        end
        %length(FileName)>=NameEnd
        while MatFileInd<=length(MatFileList) && length(FileName2)==length(FileName) && strcmp(FileName2(1:NameEnd),NameBase)
            L1=load(MatFileList{MatFileInd});
            L.Results=[L.Results;L1.Results];
            L.Names=[L.Names L1.Names];
            MatFileInd=MatFileInd+1;
            if MatFileInd<=length(MatFileList)
                [FilePath,FileName2,Extension]=fileparts(MatFileList{MatFileInd});
            end
        end
        
        
        for OutputMask=1:size(L.Results,2)
            Report.Curves(OutputMask,ActualSetInd).Name=NameBase;
            Report.Curves(OutputMask,ActualSetInd).NumImages=size(L.Results,1);
            if ~isempty(L.Results)
                DiffMedian=abs(cell2mat({L.Results(:,OutputMask).MaskMedian})-cell2mat({L.Results(:,OutputMask).OutsideMedian}));
                DiffMean=abs(cell2mat({L.Results(:,OutputMask).MaskMean})-cell2mat({L.Results(:,OutputMask).OutsideMean}));
                for ThreshInd=1:length(ThreshValues)
                    Thresh=ThreshValues(ThreshInd);
                    Report.Curves(OutputMask,ActualSetInd).MedianPositives(ThreshInd)=sum(DiffMedian>=Thresh);
                    Report.Curves(OutputMask,ActualSetInd).MeanPositives(ThreshInd)=sum(DiffMean>=Thresh);
                    
                end
                KSThreshValues=0:1/200:1;
                KSList={L.Results(:,OutputMask).KSStat};
                KSList(cellfun(@isempty,KSList))={repmat(0,[1 length(KSList(cellfun(@isempty,KSList)))])};
                KSList=cell2mat(KSList);
                for ThreshInd=1:201
                    Thresh=KSThreshValues(ThreshInd);
                    Report.Curves(OutputMask,ActualSetInd).KSPositives(ThreshInd)=mean(KSList>=Thresh);
                end
            end
        end
        ActualSetInd=ActualSetInd+1;
    end
    
    save(['ReportRealWorld_' AlgorithmName],'Report');