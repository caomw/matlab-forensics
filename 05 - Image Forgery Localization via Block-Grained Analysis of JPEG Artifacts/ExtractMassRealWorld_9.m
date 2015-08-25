load('../Datasets.mat');
DataPath=dir(MarkRealWorldSplices_First);

upLimit=inf;
c2 = 6;

for FolderInd=3:length(DataPath)
    
    disp ([num2str(FolderInd) ' ' DataPath(FolderInd).name])
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
            
            Result=cell(5,2);
            Ks=cell(2,1);
            
            [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
            map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
            Result{1,1}=LLRmap;
            Result{2,1}=LLRmap_s;
            Result{3,1}=q1table;
            Result{4,1}=alphat;
            Result{5,1}=map_final;
            
            [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
            map_final = smooth_unshift(sum(LLRmap,3),k1e,k2e);
            Result{1,2}=LLRmap;
            Result{2,2}=LLRmap_s;
            Result{3,2}=q1table;
            Result{4,2}=alphat;
            Result{5,2}=map_final;
            Ks{1}=k1e;
            Ks{2}=k2e;
                        
            Name=List(ii).name;
            save([OutPath num2str(Counter)],'Result','Ks','Name','-v7.3');
            Counter=Counter+1;
        end
    end
    
end
