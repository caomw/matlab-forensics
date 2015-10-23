function Report=CreateMaskROCCurve(AlgorithmName, ThreshRange)
    
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
                    for OutputMask=1:size(L.Results,2)
                        Report.Curves{OutputMask,Dataset}.Name{subfolder}=Names{subfolder};
                        if ~isempty(L.Results)
                            DiffMedian=abs(cell2mat({L.Results(:,OutputMask).MaskMedian})-cell2mat({L.Results(:,OutputMask).OutsideMedian}));
                            DiffMean=abs(cell2mat({L.Results(:,OutputMask).MaskMean})-cell2mat({L.Results(:,OutputMask).OutsideMean}));
                            for ThreshInd=1:length(ThreshValues);
                                Thresh=ThreshValues(ThreshInd);
                                %disp ([sum(abs(cell2mat({L.Results.MaskMedian})-cell2mat({L.Results.OutsideMedian}))>Thresh) RowIndex ThreshInd])
                                Report.Curves{OutputMask,Dataset}.MedianPositives(RowIndex,ThreshInd)=mean(DiffMedian>=Thresh);
                                Report.Curves{OutputMask,Dataset}.MeanPositives(RowIndex,ThreshInd)=mean(DiffMean>=Thresh);
                                
                            end
                            KSThreshValues=0:1/200:1;
                            KSList={L.Results(:,OutputMask).KSStat};
                            KSList(cellfun(@isempty,KSList))={repmat(0,[1 length(KSList(cellfun(@isempty,KSList)))])};
                            KSList=cell2mat(KSList);
                            for ThreshInd=1:201
                                Thresh=KSThreshValues(ThreshInd);
                                Report.Curves{OutputMask,Dataset}.KSPositives(RowIndex,ThreshInd)=mean(KSList>=Thresh);
                            end
                        end
                    end
                end
            end
        end
    end
    
    save(['Report_' AlgorithmName],'Report');