load('../Datasets_Linux.mat');
DataPath=dir(MarkRealWorldSplices_First);

AlreadyExtracted=dir('./RealWorldData/');
AlreadyExtracted={AlreadyExtracted(3:end).name};


% set parameters
checkDisplacements=0;
smoothFactor=1;



upLimit=inf;

for FolderInd=3:length(DataPath)
    
    disp (DataPath(FolderInd).name)
    
    if ~ismember(DataPath(FolderInd).name,AlreadyExtracted)
        
        Folder=[MarkRealWorldSplices_First '/' DataPath(FolderInd).name '/'];
        OutPath=['RealWorldData/' DataPath(FolderInd).name '/'];
        mkdir(OutPath);
        List=[dir([Folder '*.jpg']); dir([Folder '*.jpeg'])];
        
        Counter=1;
        for ii=1:min(length(List),upLimit)
            if mod(ii,15)==0
                disp(ii);
            end
            if ~(strcmpi(List(ii).name,'Mask') | strcmp(List(ii).name,'Crops - PostSplices'))
                filename=[Folder List(ii).name];
                    im = CleanUpImage(filename);

                [Results.OutputX, Results.OutputY, Results.dispImages, Results.imin, Results.Qualities, Results.Mins]=Ghost(im, checkDisplacements, smoothFactor);
                Name=List(ii).name;
                save([OutPath num2str(Counter)],'Results','Name','-v7.3');
                Counter=Counter+1;
            end
        end
    end
end


%%%%%%%%%%%% Cleanup
mkdir('OldRealWorld');
AlreadyExtracted=dir('./RealWorldData/');
AlreadyExtracted={AlreadyExtracted(3:end).name};

DataPath={DataPath(3:end).name};

for FolderInd=1:length(AlreadyExtracted)
    AlreadyExtracted{FolderInd}
    if ~ismember(AlreadyExtracted{FolderInd},DataPath)
        movefile(['./RealWorldData/' AlreadyExtracted{FolderInd}],['./OldRealWorld/' AlreadyExtracted{FolderInd}]);
    end
end