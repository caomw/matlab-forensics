AlgorithmName='07';

Qualities=[0 100 95 85 75 65];
Rescales=[false];

Datasets=load('../Datasets_Linux.mat');
DatasetList={'Carvalho','ColumbiauUncomp','FirstChallengeTrain', 'FirstChallengeTest2','VIPPDempSchaReal','VIPPDempSchaSynth'};

InputOrigRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputResaveRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Resaved';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
MaskRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/';
load('../Datasets_Linux.mat');

c2 = 6;

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
                    
                    if ~exist(OutputName)
                        
                        slashes=strfind(OutputName,'/');
                        if ~exist(OutputName(1:slashes(end)))
                            mkdir(OutputName(1:slashes(end)));
                        end
                        
                        
                        im=jpeg_read(FileList{fileInd});
                        [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
                        map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
                        
                        [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
                        map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
                        
                        
                        Result{1,1}=LLRmap;
                        Result{2,1}=LLRmap_s;
                        Result{3,1}=q1table;
                        Result{4,1}=alphat;
                        Result{5,1}=map_final;
                        Result{1,2}=LLRmap;
                        Result{2,2}=LLRmap_s;
                        Result{3,2}=q1table;
                        Result{4,2}=alphat;
                        Result{5,2}=map_final;
                        Ks{1}=k1e;
                        Ks{2}=k2e;
                        
                        Name=strrep(FileList{fileInd},[InputResaveRoot '/' num2str(Quality) '_' num2str(Rescale) '/'],'');
                        Name=strrep(Name,InputOrigRoot,'');
                        MaskFile=strrep(FileList{fileInd},[InputResaveRoot '/' num2str(Quality) '_' num2str(Rescale) '/'], MaskRoot);
                        MaskFile=strrep(MaskFile,InputOrigRoot, MaskRoot);
                        maskdots=strfind(MaskFile,'.');
                        MaskFile=strrep(MaskFile,MaskFile(maskdots(end):end),'.png');
                        if exist(MaskFile,'file')
                            BinMask=mean(CleanUpImage(MaskFile),3)>0;
                        else
                            slashes=strfind(MaskFile,'/');
                            MaskPath=MaskFile(1:slashes(end));
                            MaskList=dir([MaskPath '*.png']);
                            if length(MaskList)==1
                                BinMask=mean(CleanUpImage([MaskPath MaskList(1).name]),3)>0;
                            elseif length(MaskList)==0
                                BinMask={};
                            else
                                error('Something is wrong with the masks');
                            end
                        end
                        save(OutputName,'Quality','Rescale','BinMask','AlgorithmName','Result','Ks','Name','-v7.3');
                    end
                    if mod(fileInd,15)==0
                        disp(fileInd)
                    end
                end
            end
        end
    end
end