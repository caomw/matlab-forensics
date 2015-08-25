load('../Datasets.mat');
DataPath=dir(MarkRealWorldSplices_First);

upLimit=inf;

% set parameters
checkDisplacements=0;
smoothFactor=1;

for FolderInd=1:length(DataPath)
    
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
            filename=[Folder List(ii).name];
              
            im = CleanUpImage(filename);
            
            if strcmp(class(im),'uint16')
                im=uint8(floor(double(im)/256))
            end
            
            [Results.OutputX, Results.OutputY, Results.dispImages, Results.imin, Results.Qualities, Results.Mins]=Ghost(im, checkDisplacements, smoothFactor);
            Name=List(ii).name;
            
            save([OutPath num2str(Counter)],'Results','Name','-v7.3');
            Counter=Counter+1;
        end
    end
    
end
