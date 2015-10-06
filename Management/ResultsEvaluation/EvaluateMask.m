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
                OutputPaths={};
                InputData=Datasets.(InputSet);
                if isstruct(InputData)
                    Names=fieldnames(InputData);
                    for jj=1:length(Names);
                        InputPaths=[InputPaths;InputData.(Names{jj})];
                        OutputFiles=[OutputPaths;[OutputRoot AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' Names{jj} '.mat']];
                    end
                else
                    InputPaths={InputData};
                    OutputFiles=[OutputRoot '/' AlgorithmName num2str(Quality) '_' num2str(Rescale) '/' InputSet '_' Names{jj}];
                end
                
                for subfolder=1:length(InputPaths);
                    InputPath=strrep(InputPaths{subfolder},ImageRoot,[InputRoot '/' AlgorithmName '/' num2str(Quality) '_' num2str(Rescale) '/']);
                    disp(InputPath)
                    disp(OutputFiles)
                    FileList=getAllFiles(InputPath,'*.mat',true);
                    
                    Results=[];
                    for InputFile=1 %:length(FileList)
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
                                Mask=[];
                            end
                        end
                        
                        if ~isempty(Mask)
                            
                            for MapInd=1:length(ResultMap)
                                MaskResize=imresize(Mask,size(ResultMap{MapInd}))>0;
                                figure(1);
                                imagesc(ResultMap{MapInd})
                                figure(2);
                                imagesc(MaskResize)
                                pause
                            end
                        end
                    end
                    
                    
                end
            end
        end
    end
end