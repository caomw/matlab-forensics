MaskThresholds=[0:0.05:1];


AlgorithmNames={'01'  '02' '04' '05' '07' '10' '14' '16'}; % {'08'} % '12'  '16'

ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';

MaskRoot=[ImageRoot 'Masks/'];

Qualities= [0 100 95 85 75 65];
Rescales=[false];

Datasets=load('../../Datasets_Linux.mat'); %
DatasetList={'VIPP2', 'Carvalho','ColumbiauUncomp','FirstChallengeTrain','VIPPDempSchaReal', 'VIPPDempSchaSynth'};%  'FirstChallengeTest2','VIPPDempSchaReal','VIPPDempSchaSynth'};

for AlgorithmInd=1:length(AlgorithmNames)
    AlgorithmName=AlgorithmNames{AlgorithmInd};
    for Quality=Qualities
        for Rescale=Rescales
            for Dataset=1:length(DatasetList)
                disp(DatasetList{Dataset});
                InputSet=DatasetList{Dataset};
                InputPaths={};
                OutputFiles={};
                InputData=Datasets.(InputSet);
                if isstruct(InputData)
                    Names=fieldnames(InputData);
                    for jj=1:length(Names);
                        InputPaths=[InputPaths;InputData.(Names{jj})];
                        OutputFiles=[OutputFiles;[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' Names{jj} '_MaskArea.mat']];
                    end
                else
                    InputPaths={InputData};
                    OutputFiles={[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_MaskArea.mat']};
                end
                
                for subfolder=1:length(InputPaths);
                    InputPath=strrep(InputPaths{subfolder},ImageRoot,[InputRoot '/' AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/']);
                    FileList=getAllFiles(InputPath,'*.mat',true);
                    clear Results
                    for InputFile=1:length(FileList)
                        Input=load(FileList{InputFile});
                        ResultMap=GetAlgorithmInputMap(Input,AlgorithmName);
                        MaskFile=[MaskRoot Input.Name];
                        dots=strfind(MaskFile,'.');
                        MaskFile=strrep(MaskFile,MaskFile(dots:end),'.png');
                        if exist(MaskFile)
                            Mask=CleanUpImage(MaskFile);
                        else
                            Slashes=strfind(MaskFile,'/');
                            MaskPath=MaskFile(1:Slashes(end)-1);
                            AllMasks=dir(MaskPath);
                            if length(AllMasks)==3
                                Mask=CleanUpImage([MaskPath '/' AllMasks(3).name]);
                            else
                                Mask=zeros(1024);
                            end
                        end
                        Mask=mean(Mask,3);
                        
                        for MapInd=1:length(ResultMap)
                            
                            if numel(Mask)<numel(ResultMap{MapInd})
                                MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                                MaskResize=imresize(Mask,size(ResultMap{MapInd}),'nearest')>MaskThresh;
                                ResultMap{MapInd}=ResultMap{MapInd};
                            else
                                MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                                MaskResize=Mask>MaskThresh;
                                ResultMap{MapInd}=imresize(ResultMap{MapInd},size(Mask),'nearest');
                            end
                            if Dataset==2 || Dataset==4
                                Mask=~Mask;
                            end
                            
                            Names{InputFile}=Input.Name;
                            
                            for MaskThresholdInd=1:length(MaskThresholds)
                                MaskThreshold=MaskThresholds(MaskThresholdInd);
                                ResultThresholded{1}=ResultMap{MapInd}>=MaskThreshold;
                                ResultThresholded{2}=ResultMap{MapInd}<MaskThreshold;
                                for ResultVersion=1:2
                                    [ProcessedMasks,Processes]=ProcessMask(ResultThresholded{ResultVersion});
                                    for ProcessInd=1:length(ProcessedMasks)
                                        Result=[];
                                        Result.PixelCount=numel(ResultThresholded);
                                        Result.Positives=sum(MaskResize(:));
                                        Result.Negatives=sum(~MaskResize(:));
                                        Result.ReturnedPositives=sum(sum(ProcessedMasks{ProcessInd}));
                                        Result.ReturnedNegatives=sum(sum(~ProcessedMasks{ProcessInd(:)}));
                                        Result.TP=sum(sum(ProcessedMasks{ProcessInd}&MaskResize));
                                        Result.FP=sum(sum(ProcessedMasks{ProcessInd}&~MaskResize));
                                        Result.TN=sum(sum(~ProcessedMasks{ProcessInd}&~MaskResize));
                                        Result.FN=sum(sum(~ProcessedMasks{ProcessInd}&MaskResize));
                                        Result.Prec=Result.TP/Result.ReturnedPositives;
                                        if isnan(Result.Prec)
                                            Result.Prec=0;
                                        end
                                        Result.Rec=Result.TP/Result.Positives;
                                        if isnan(Result.Rec)
                                            Result.Rec=0;
                                        end
                                        Result.F1=2*(Result.Prec*Result.Rec)/(Result.Prec+Result.Rec);
                                        if isnan(Result.F1)
                                            Result.F1=0;
                                        end
                                        Result.Union=sum(sum(ProcessedMasks{ProcessInd}|MaskResize));
                                        Result.IoU=Result.TP/Result.Union;
                                        if isnan(Result.IoU)
                                            Result.IoU=0;
                                        end
                                        Result.MarkMeasure=(Result.TP^2)/(Result.ReturnedPositives*Result.Positives);
                                        if isnan(Result.MarkMeasure)
                                            Result.MarkMeasure=0;
                                        end
                                        
                                        Results(InputFile,MaskThresholdInd,ProcessInd,ResultVersion,MapInd)=Result;
                                    end
                                end
                            end
                        end
                        if mod(InputFile,50)==0
                            disp(InputFile)
                        end
                    end
                    
                    slashes=strfind(OutputFiles{subfolder},'/');
                    mkdir(OutputFiles{subfolder}(1:slashes(end)));
                    OutputFiles{subfolder}
                    save(OutputFiles{subfolder},'Results','Names','Processes','-v7.3');
                    %disp('saved');
                    %pause
                end
            end
        end
    end
end