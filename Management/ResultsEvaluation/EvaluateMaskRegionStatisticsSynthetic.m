clear all;

AlgorithmNames={'12'};%{'01' '02' '04' '05' '06' '07' '10' '14' '16' };

ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';

MaskRoot=[ImageRoot 'Masks/'];

Qualities=  [0 100 95 85 75 65]; %[0 100 95 85 75 65];
Rescales=[false];

Datasets=load('../../Datasets_Linux.mat'); %
DatasetList= {'Carvalho','ColumbiauUncomp','FirstChallengeTrain','VIPPDempSchaReal', 'VIPPDempSchaSynth'};%  'VIPP2',  'FirstChallengeTest2','VIPPDempSchaReal','VIPPDempSchaSynth'};

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
                    FieldNames=fieldnames(InputData);
                    for jj=1:length(FieldNames);
                        InputPaths=[InputPaths;InputData.(FieldNames{jj})];
                        OutputFiles=[OutputFiles;[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' FieldNames{jj} '.mat']];
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
                                Mask=CleanUpImage([MaskPath '/' AllMasks(3).name]);
                            else
                                Mask=zeros(1024);
                                Mask(385:640,385:640)=1;
                            end
                        end
                        Mask=mean(Mask,3);
                        
                        for MapInd=1:length(ResultMap)
                            if isempty(ResultMap{MapInd})
                                ResultMap{MapInd}=zeros(1024);
                                disp(['empty map: '  Input.Name]);
                            end
                            ResultMap{MapInd}(isnan(ResultMap{MapInd}))=0;
                            ResultMap{MapInd}(isinf(ResultMap{MapInd}))=0;
                            if numel(Mask)<numel(ResultMap{MapInd})
                                MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                                MaskResize=imresize(Mask,size(ResultMap{MapInd}),'nearest')>MaskThresh;
                                ResultMap{MapInd}=ResultMap{MapInd};
                            else
                                MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                                MaskResize=Mask>MaskThresh;
                                ResultMap{MapInd}=imresize(ResultMap{MapInd},size(Mask),'nearest');
                            end
                            
                            Names{InputFile}=Input.Name;
                            
                            %Median under and outside mask
                            Results(InputFile,MapInd).MaskMedian=median(ResultMap{MapInd}(MaskResize));
                            Results(InputFile,MapInd).OutsideMedian=median(ResultMap{MapInd}(~MaskResize));
                            
                            %Mean under and outside mask
                            Results(InputFile,MapInd).MaskMean=mean(ResultMap{MapInd}(MaskResize));
                            Results(InputFile,MapInd).OutsideMean=mean(ResultMap{MapInd}(~MaskResize));
                            
                            if isnan(Results(InputFile,MapInd).MaskMedian) | isnan(Results(InputFile,MapInd).OutsideMedian) | isnan(Results(InputFile,MapInd).MaskMean) | isnan(Results(InputFile,MapInd).OutsideMean)
                                disp('nan');
                                pause
                            end
                            
                            %K-S statistic
                            MinValue=min(min(ResultMap{MapInd}));
                            MaxValue=max(max(ResultMap{MapInd}));
                            HistBinEdges=[MinValue:(MaxValue-MinValue)/20:MaxValue inf];
                            HistBinEdges=HistBinEdges(1:end-1);
                            Results(InputFile,MapInd).MaskHist=histc(ResultMap{MapInd}(MaskResize),HistBinEdges);
                            Results(InputFile,MapInd).OutsideHist=histc(ResultMap{MapInd}(~MaskResize),HistBinEdges);
                            Results(InputFile,MapInd).MaskHist=Results(InputFile,MapInd).MaskHist/sum(Results(InputFile,MapInd).MaskHist);
                            Results(InputFile,MapInd).OutsideHist=Results(InputFile,MapInd).OutsideHist/sum(Results(InputFile,MapInd).OutsideHist);
                            Results(InputFile,MapInd).KSStat=max(abs(cumsum(Results(InputFile,MapInd).MaskHist(:))-cumsum(Results(InputFile,MapInd).OutsideHist(:))));
                            if isempty(Results(InputFile,MapInd).MaskHist)
                                Results(InputFile,MapInd).MaskHist=1;
                                Results(InputFile,MapInd).OutsideHist=1;
                                Results(InputFile,MapInd).KSStat=0;
                            end
                        end
                        if mod(InputFile,50)==0
                            disp(InputFile)
                        end
                    end
                    
                    slashes=strfind(OutputFiles{subfolder},'/');
                    mkdir(OutputFiles{subfolder}(1:slashes(end)));
                    save(OutputFiles{subfolder},'Results','Names');
                    %disp('saved');
                    %pause
                end
            end
        end
    end
end