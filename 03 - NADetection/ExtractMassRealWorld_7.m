load('../Datasets.mat');
DataPath=dir(MarkRealWorldSplices_First);

upLimit=inf;

% threshold on min-entropy of IPM
th1 = 4;
% threshold on min-entropy of DIPM
th2 = 2.5;

for FolderInd=3:length(DataPath)
    
    disp (DataPath(FolderInd).name)
    Folder=[MarkRealWorldSplices_First '\' DataPath(FolderInd).name '\'];
    OutPath=['RealWorldData\' DataPath(FolderInd).name '\'];
    mkdir(OutPath);
    List=[dir([Folder '*.jpg']); dir([Folder '*.jpeg'])];
    
    Counter=1;
    for ii=1:min(length(List),upLimit)
        if mod(ii,15)==0
            disp(ii);
        end
        if ~(strcmpi(List(ii).name,'Mask') | strcmp(List(ii).name,'Crops - PostSplices'))
            filename=[Folder List(ii).name];
            im = jpeg_read(filename);
            [H1,H2] = minHNA(im);
            [k1,k2,Q,IPM,DIPM] = detectNA(im,1,th1,th2,false);
            
            Result.Feature=[Q H1 H2 k1 k2];
            Result.IPM=IPM;
            Result.DIPM=DIPM;
            
            Name=List(ii).name;
            save([OutPath num2str(Counter)],'Result','Name','-v7.3');
            Counter=Counter+1;
        end
    end
    
end
