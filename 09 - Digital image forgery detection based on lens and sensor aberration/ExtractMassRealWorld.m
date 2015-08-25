load('../Datasets_Linux.mat');
MarkRealWorldSplices_First=strrep(MarkRealWorldSplices_First,'\','/')
DataPath=dir(MarkRealWorldSplices_First)
DataPath=DataPath(3:end);

upLimit=inf;

for FolderInd=46:length(DataPath)
    disp (DataPath(FolderInd).name)
    
    Folder=[MarkRealWorldSplices_First '\' DataPath(FolderInd).name '\'];
    Folder=strrep(Folder,'\','/');
    OutPath=['RealWorldData\' DataPath(FolderInd).name '\'];
    OutPath=strrep(OutPath,'\','/');
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
            [OutlierPrmsMap, OutlierPrmsMap_filtered, OutlierErrMap, OutlierErrMap_filtered, OutputStatistics]=findAberrations_compact(im)
            Result.OutlierPrmsMap=OutlierPrmsMap;
            Result.OutlierPrmsMap_filtered=OutlierPrmsMap_filtered;
            Result.OutlierErrMap=OutlierErrMap;
            Result.OutlierErrMap_filtered=OutlierErrMap_filtered;
            Result.OutputStatistics=OutputStatistics;

            Name=List(ii).name;
            save([OutPath num2str(Counter)],'Result','Name','-v7.3');
            Counter=Counter+1;
        end
    end
end