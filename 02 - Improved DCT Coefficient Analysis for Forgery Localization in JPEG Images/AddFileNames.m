AlgorithmName='02';

Qualities=[0 100 95 85 75 65];
Rescales=[false];

Datasets=load('../Datasets_Linux.mat');
DatasetList={'Carvalho', 'ColumbiauUncomp','FirstChallengeTrain', 'FirstChallengeTest2','VIPPDempSchaReal','VIPPDempSchaSynth'};

InputOrigRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputResaveRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Resaved';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
MaskRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/';
load('../Datasets_Linux.mat');


for Quality=Qualities
    for Rescale=Rescales
        for Dataset=1:length(DatasetList)
            disp(DatasetList{Dataset});
            InputSet=DatasetList{Dataset};
            InputPaths={};
            InputData=getfield(Datasets,InputSet);
            if isstruct(InputData)
                Names=fieldnames(InputData);
                for jj=1:length(Names);
                    InputPaths=[InputPaths;getfield(InputData,Names{jj})];
                end
            else
                InputPaths={InputData};
            end
            for subfolder=1:length(InputPaths);
                if Quality==0 && Rescale==false
                    InputPath=InputPaths{subfolder};
                else
                    InputPath=strrep(InputPaths{subfolder}, InputOrigRoot, [InputResaveRoot '/' num2str(Quality) '_' num2str(Rescale) '/']);
                end
                FileList={};
                for fileExtension={'*.jpg','*.jpeg'}
                    FileList=[FileList;getAllFiles(InputPath,fileExtension{1},true)];
                end
                
                
                for fileInd=1:length(FileList)
                    if Quality==0 && Rescale==0
                        OutputName=[strrep(FileList{fileInd},InputOrigRoot,[OutputRoot AlgorithmName '/0_0/']) '.mat'];
                    else
                        OutputName=[strrep(FileList{fileInd},InputResaveRoot,[OutputRoot AlgorithmName]) '.mat'];
                    end
                    
                    if exist(OutputName)

                        L=load(OutputName);
                        
                        Name=strrep(FileList{fileInd},[InputResaveRoot '/' num2str(Quality) '_' num2str(Rescale) '/'],'');
                        Name=strrep(Name,InputOrigRoot,'');
                        
                        L.Name=Name;
                        save(OutputName,'-struct','L','-v7.3');
                    end
                    if mod(fileInd,15)==0
                        disp(fileInd)
                    end
                end
            end
        end
    end
end