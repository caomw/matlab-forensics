AlgorithmNames={'01' '02' '04' '05' '07' '10' '12' '14' '16'};

ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';

MaskRoot=[ImageRoot 'Masks/'];

Qualities=100; %[0 100 95 85 75 65];
Rescales=[false];

Datasets=load('../../Datasets_Linux.mat');
DatasetList={'Carvalho','ColumbiauUncomp','FirstChallengeTrain', 'FirstChallengeTest2','VIPPDempSchaReal','VIPPDempSchaSynth'};

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
                        OutputFiles=[OutputFiles;[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' Names{jj} '.mat']];
                    end
                else
                    InputPaths={InputData};
                    OutputFiles={[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '.mat']};
                end
                
                for subfolder=1:length(InputPaths);
                    InputPath=strrep(InputPaths{subfolder},ImageRoot,[InputRoot '/' AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/']);
                    FileList=getAllFiles(InputPath,'*.mat',true);
                    
                    Results=[];
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
                                Mask=CleanUpImage(MaskFile);
                            else
                                Mask=zeros(1024);
                                Mask(385:640,385:640)=1;
                            end
                        end
                        Mask=mean(Mask,3);
                            
                        for MapInd=1:length(ResultMap)
                            MaskResize=imresize(Mask,size(ResultMap{MapInd}),'nearest')>0;
                            
                            Names{InputFile}=Input.Name;
                            
                            %Median under and outside mask
                            Results(InputFile).MaskMedian=median(ResultMap{MapInd}(MaskResize));
                            Results(InputFile).OutsideMedian=median(ResultMap{MapInd}(~MaskResize));
                            
                            %Mean under and outside mask
                            Results(InputFile).MaskMean=mean(ResultMap{MapInd}(MaskResize));
                            Results(InputFile).OutsideMean=mean(ResultMap{MapInd}(~MaskResize));
                            
                            %K-S statistic
                            MinValue=min(min(ResultMap{MapInd}));
                            MaxValue=max(max(ResultMap{MapInd}));
                            HistBinEdges=MinValue:(MaxValue-MinValue)/20:MaxValue;
                            HistBinEdges=HistBinEdges(1:end-1);
                            Results(InputFile).MaskHist=histc(ResultMap{MapInd}(MaskResize),HistBinEdges);
                            Results(InputFile).OutsideHist=histc(ResultMap{MapInd}(~MaskResize),HistBinEdges);
                            Results(InputFile).MaskHist=Results(InputFile).MaskHist/sum(Results(InputFile).MaskHist);
                            Results(InputFile).OutsideHist=Results(InputFile).OutsideHist/sum(Results(InputFile).OutsideHist);
                            Results(InputFile).KSStat=max(abs(cumsum(Results(InputFile).MaskHist)-cumsum(Results(InputFile).OutsideHist)));
                        end
                    end
                    
                    slashes=strfind(OutputFiles{subfolder},'/');
                    mkdir(OutputFiles{subfolder}(1:slashes(end)));
                    save(OutputFiles{subfolder},'Results','Names');
                    disp('saved');
                    pause
                end
            end
        end
    end
end