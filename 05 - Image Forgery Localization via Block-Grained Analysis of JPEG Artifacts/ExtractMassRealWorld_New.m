AlgorithmName='05';

Datasets=load('../Datasets_Linux.mat');

c2 = 6;

InputOrigRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';

Folders=dir(Datasets.MarkRealWorldSplices);
Folders=Folders(3:end);

for Folder=1:length(Folders)
    
    InputFolder=Folders(Folder).name;
    disp(InputFolder)
    
    OutDir=strrep([Datasets.MarkRealWorldSplices '/' Folders(Folder).name], InputOrigRoot, [OutputRoot AlgorithmName '/']);
    mkdir(OutDir);
    FileList=[];
    for fileExtension={'*.jpg','*.jpeg'}
        FileList=[FileList;dir([Datasets.MarkRealWorldSplices '/' Folders(Folder).name '/' fileExtension{1}])];
    end
    
    FileList=FileList(3:end);
    for fileInd=1:length(FileList)
        InputFileName=[Datasets.MarkRealWorldSplices '/' InputFolder '/' FileList(fileInd).name];
        OutputName=[strrep(InputFileName,InputOrigRoot,[OutputRoot AlgorithmName '/']) '.mat'];
        if ~exist(OutputName)
            Salvaged=[OutputRoot  AlgorithmName '/RW/' FileList(fileInd).name '.mat'];
            if exist(Salvaged)
                Salv=load(Salvaged);
                Salv.Name=strrep(InputFileName,InputOrigRoot,'');
                save(OutputName, '-struct','Salv');
            else
                im=jpeg_read(InputFileName);
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
                Name=strrep(InputFileName,InputOrigRoot,'');
                save(OutputName,'AlgorithmName','Result','Ks','Name','-v7.3');
            end
            if mod(fileInd,15)==0
                disp(fileInd)
            end
        end
    end
end
