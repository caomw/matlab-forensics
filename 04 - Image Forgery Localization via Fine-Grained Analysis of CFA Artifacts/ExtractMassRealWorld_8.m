load('../Datasets.mat');
DataPath=dir(MarkRealWorldSplices_First);

upLimit=inf;

% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;
% Pattern of CFA on green channel
%bayer = [0, 1; 1, 0];

for FolderInd=52:length(DataPath)
    
    disp (DataPath(FolderInd).name)
    Folder=[MarkRealWorldSplices_First '\' DataPath(FolderInd).name '\'];
    OutPath=['RealWorldData\' DataPath(FolderInd).name '\'];
    mkdir(OutPath);
    List=dir(Folder);
    
    Counter=1;
    for ii=1:min(length(List),upLimit)
        if mod(ii,15)==0
            disp(ii);
        end
        if ~(strcmpi(List(ii).name,'.') || strcmpi(List(ii).name,'..') ||  strcmpi(List(ii).name,'Mask') || strcmp(List(ii).name,'Crops - PostSplices'))
            filename=[Folder List(ii).name]
            im = CleanUpImage(filename);
            
            toCrop=mod(size(im),2);
            im=im(1:end-toCrop(1),1:end-toCrop(2),:);
            
            [bayer, F1]=GetCFASimple(im);
            Result=cell(2,1);
            
            for j = 1:2
                [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
                Result{j}=map;
            end
            
            Name=List(ii).name;
            save([OutPath num2str(Counter)],'Result','Name','bayer','F1','-v7.3');
            Counter=Counter+1;
        end
    end
    
end
