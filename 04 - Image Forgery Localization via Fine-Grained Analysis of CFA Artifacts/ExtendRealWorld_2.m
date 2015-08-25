load('../Datasets_Linux.mat');
DataPath=dir(MarkRealWorldSplices_First);

AlreadyExtracted=dir('./RealWorldData/');
AlreadyExtracted={AlreadyExtracted(3:end).name};

% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;
% Pattern of CFA on green channel
%bayer = [0, 1; 1, 0];

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
                ext_dots=strfind(filename,'.');
                
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
                save([OutPath num2str(Counter)],'Result','Name','-v7.3');
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