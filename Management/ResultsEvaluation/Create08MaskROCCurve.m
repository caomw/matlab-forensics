function Report=Create08MaskROCCurve(AlgorithmName, ThreshRange)
    
    AlgorithmName='08';
    
    ThreshStep=(ThreshRange(2)-ThreshRange(1))/500;
    ThreshValues=[-inf ThreshRange(1):ThreshStep:ThreshRange(2) inf];
    
    ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
    InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';
    Qualities=[0 100 95 85 75 65];
    Rescales=[false];
    Datasets=load('../../Datasets_Linux.mat');
    DatasetList={'VIPP2', 'Carvalho','ColumbiauUncomp','FirstChallengeTrain','VIPPDempSchaReal','VIPPDempSchaSynth'}; %, 'FirstChallengeTest2'
    
    
    Report.ThreshRange=ThreshValues;
    Report.Qualities=Qualities';
    
    for Dataset=1:length(DatasetList)
        for QualityInd=1:length(Qualities)
            Quality=Qualities(QualityInd);
            for Rescale=Rescales
                InputSet=DatasetList{Dataset};
                InputFiles={};
                InputData=Datasets.(InputSet);
                if isstruct(InputData)
                    Names=fieldnames(InputData)';
                    for jj=1:length(Names);
                        InputFiles=[InputFiles;[InputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' Names{jj} '.mat']];
                    end
                else
                    Names={''};
                    InputFiles={[InputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '.mat']};
                end
                Report.DatasetNames{Dataset,1}=InputSet;
                
                for subfolder=1:length(InputFiles);
                    RowIndex=(QualityInd-1)*length(InputFiles)+subfolder;
                    L=load(InputFiles{subfolder});
                    Report.Curves{1,Dataset}.Name{subfolder}=Names{subfolder};
                    if ~isempty(L.Results)
                        MaskMedians=reshape(cell2mat({L.Results.MaskMedian}),size(L.Results,1),size(L.Results,2));
                        OutsideMedians=reshape(cell2mat({L.Results.OutsideMedian}),size(L.Results,1),size(L.Results,2));
                        MaskMeans=reshape(cell2mat({L.Results.MaskMean}),size(L.Results,1),size(L.Results,2));
                        OutsideMeans=reshape(cell2mat({L.Results.OutsideMean}),size(L.Results,1),size(L.Results,2));
                        
                        MedianDiff=max(abs(MaskMedians-OutsideMedians),[],2);
                        MeanDiff=max(abs(MaskMeans-OutsideMeans),[],2);
                        for ThreshInd=1:length(ThreshValues)
                            Thresh=ThreshValues(ThreshInd);
                            %disp ([sum(abs(cell2mat({L.Results.MaskMedian})-cell2mat({L.Results.OutsideMedian}))>Thresh) RowIndex ThreshInd])
                            Report.Curves{1,Dataset}.MedianPositives(RowIndex,ThreshInd)=mean(MedianDiff>=Thresh);
                            Report.Curves{1,Dataset}.MeanPositives(RowIndex,ThreshInd)=mean(MeanDiff>=Thresh);
                        end
                        KSThreshValues=0:1/200:1;
                        KSs=reshape(cell2mat({L.Results.KSStat}),size(L.Results,1),size(L.Results,2));
                        KSs(isnan(KSs))=0;
                        MaxKS=max(KSs,[],2);
                        for ThreshInd=1:201
                            Thresh=KSThreshValues(ThreshInd);
                            Report.Curves{1,Dataset}.KSPositives(RowIndex,ThreshInd)=mean(MaxKS>=Thresh);
                        end
                    end
                end
            end
        end
    end
    
    save(['Report_' AlgorithmName],'Report');