load('../Datasets.mat');
DataPath=dir(MarkRealWorldSplices_First);

upLimit=inf;

ncomp = 1;
c2 = 6;
k1 = 8;
k2 = 4;
alpha0 = 0.5;
dLmin = 100;
maxIter = 100;

for FolderInd=1:length(DataPath)
    
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
        if ~(strcmpi(List(ii).name,'.') || strcmpi(List(ii).name,'..') ||  strcmpi(List(ii).name,'Mask') || strcmp(List(ii).name,'Crops - PostSplices'))
            filename=[Folder List(ii).name];
            im = jpeg_read(filename);
            
            Results=cell(2,1);
            map = getJmapNA_EM_oracle(im,ncomp,c2,k1,k2,true,alpha0,dLmin,maxIter);
            map_final = smooth_unshift(sum(map,3),k1,k2);
            Result{1}=map;
            Result{2}=map_final;
            
            Name=List(ii).name;
            save([OutPath num2str(Counter)],'Result','Name','-v7.3');
            Counter=Counter+1;
        end
    end
    
end
