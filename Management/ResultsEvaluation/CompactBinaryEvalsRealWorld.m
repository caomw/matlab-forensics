function Report=CompactBinaryEvalsRealWorld(AlgorithmName)
    
    ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
    InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';
    Datasets=load('../../Datasets_Linux.mat');
    MatFileList=getAllFiles([InputRoot AlgorithmName '/WildWeb_MaskArea/'],'*.mat',true);
    
    
    ActualSetInd=1;
    MatFileInd=1;
    while MatFileInd<=length(MatFileList)
        %wrap related subcases into one
        L=load(MatFileList{MatFileInd});
            if size(L.Results,2<102)
                L.Results(1,102,1,1,1).F1=0;
            end
            if size(L.Results,5<15)
                L.Results(1,1,1,1,15).F1=0;
            end
            
        
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
            if size(L1.Results,2<102)
                L1.Results(1,102,1,1,1).F1=0;
            end
            if size(L1.Results,5<15)
                L1.Results(1,1,1,1,15).F1=0;
            end
            
            L.Results=[L.Results;L1.Results];
            L.Names=[L.Names L1.Names];
            MatFileInd=MatFileInd+1;
            if MatFileInd<=length(MatFileList)
                [FilePath,FileName2,Extension]=fileparts(MatFileList{MatFileInd});
            end
        end
        
        for Ind=1:size(L.Results,1)
            Report(ActualSetInd).FolderName=NameBase;
            Report(ActualSetInd).F1(Ind)=max(cell2mat({L.Results(Ind,:,:,:,:).F1}));
            Report(ActualSetInd).IoU(Ind)=max(cell2mat({L.Results(Ind,:,:,:,:).IoU}));
            Report(ActualSetInd).MarkMeasure(Ind)=max(cell2mat({L.Results(Ind,:,:,:,:).MarkMeasure}));
            Report(ActualSetInd).FileName{Ind}=L.Names{Ind};
        end
        
        ActualSetInd=ActualSetInd+1;
    end
    
    save(['ReportBinaryRealWorld_' AlgorithmName],'Report');