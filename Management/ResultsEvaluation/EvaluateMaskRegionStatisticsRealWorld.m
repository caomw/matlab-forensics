clear all;
AlgorithmNames={'06'}; %{'01' '02' '04' '05' '07' '10' '14' '16' };% '12' '08' {'01' '02' '04' '05' '07' '08' '10' '14' '16' }; % '12'  '16'

ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';

MaskRoot=[ImageRoot 'Masks/'];

Datasets=load('../../Datasets_Linux.mat');

Folders=dir(Datasets.MarkRealWorldSplices);
Folders=Folders(3:end);



for AlgorithmInd=1:length(AlgorithmNames)
    AlgorithmName=AlgorithmNames{AlgorithmInd};
    disp(AlgorithmName)
    mkdir([OutputRoot AlgorithmName '/WildWeb/']);
    for Folder=1:length(Folders)
        InputFolder=Folders(Folder).name;
        InputPath=[InputRoot AlgorithmName '/Wild Web Dataset/WildWeb/' InputFolder];
        MaskPath=[Datasets.MarkRealWorldSplices '/' InputFolder '/Mask/'];
        FileList=getAllFiles(InputPath,'*.mat',true);
        MaskList=getAllFiles(MaskPath,'*.png',true);
        
        for MaskInd=1:length(MaskList)
            OutputFile=[OutputRoot AlgorithmName '/WildWeb/' InputFolder '_' num2str(MaskInd) '.mat'];
            Mask=CleanUpImage(MaskList{MaskInd});
            Results=[];
            Names={};
            for InputFile=1:length(FileList)
                Input=load(FileList{InputFile});
                ResultMap=GetAlgorithmInputMap(Input,AlgorithmName);
                Mask=mean(Mask,3);
                if isfield(Input,'Name')
                    Names{InputFile}=Input.Name;
                else
                    Names{InputFile}=FileList{InputFile};
                end
                for MapInd=1:length(ResultMap)
                    ResultMap{MapInd}(isnan(ResultMap{MapInd}))=0;
                    if isempty(ResultMap{MapInd})
                        ResultMap{MapInd}=zeros(1024);
                        disp(['empty map: '  Input.Name]);
                    end
                    
                    if numel(Mask)<numel(ResultMap{MapInd})
                        MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                        MaskResize=imresize(Mask,size(ResultMap{MapInd}),'nearest')>MaskThresh;
                        ResultMap{MapInd}=ResultMap{MapInd};
                    else
                        MaskThresh=mean([min(min(Mask)) max(max(Mask))]);
                        MaskResize=Mask>MaskThresh;
                        ResultMap{MapInd}=imresize(ResultMap{MapInd},size(Mask),'nearest');
                    end
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
                    HistBinEdges=MinValue:(MaxValue-MinValue)/20:MaxValue;
                    HistBinEdges=HistBinEdges(1:end-1);
                    Results(InputFile,MapInd).MaskHist=histc(ResultMap{MapInd}(MaskResize),HistBinEdges);
                    Results(InputFile,MapInd).OutsideHist=histc(ResultMap{MapInd}(~MaskResize),HistBinEdges);
                    Results(InputFile,MapInd).MaskHist=Results(InputFile).MaskHist/sum(Results(InputFile).MaskHist);
                    Results(InputFile,MapInd).OutsideHist=Results(InputFile).OutsideHist/sum(Results(InputFile).OutsideHist);
                    Results(InputFile,MapInd).KSStat=max(abs(cumsum(Results(InputFile).MaskHist(:))-cumsum(Results(InputFile).OutsideHist(:))));
                    if isempty(Results(InputFile,MapInd).MaskHist)
                        Results(InputFile,MapInd).MaskHist=1;
                        Results(InputFile,MapInd).OutsideHist=1;
                        Results(InputFile,MapInd).KSStat=0;
                    end
                end
            end
            
            save(OutputFile,'Results','Names');
            %disp('done');
            %disp(OutputFile)
            %pause
        end
    end
end