In_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
FolderIn='04/TwRes';
NameSuffix='_Tw';

SortedOutDir=['/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/SortedOut/' FolderIn '/'];
mkdir(SortedOutDir);

Out_Base='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
FolderOut='04 - Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts/';
Quality=75;
Rescale=true;

FinalOutputFolder=[Out_Base FolderOut num2str(Quality) '_' num2str(Rescale) '/'];

InList=dir([In_Base FolderIn '/*.mat']);

for ii=1:length(InList)
    Loaded=load([In_Base FolderIn '/' InList(ii).name]);
    if strcmp(Loaded.Name(1:3),'D:\')
        Slashes=strfind(Loaded.Name,'\');
    else
        Slashes=strfind(Loaded.Name,'/');
    end
    Loaded.Name=strrep(Loaded.Name,'\','/');
    if ~isempty(Slashes)
        FinalSlash=Slashes(end);
        
        Dots=strfind(Loaded.Name,'.');
        FinalDot=Dots(end);
        
        OutBaseInd=strfind(Loaded.Name,'TwResJPEG/')+10;
        
        
        SubFolderStructure=Loaded.Name(OutBaseInd:FinalSlash);
        if ~exist([FinalOutputFolder SubFolderStructure], 'dir')
            mkdir([FinalOutputFolder SubFolderStructure]);
        end
        
        
        PlainName=Loaded.Name(FinalSlash+1:FinalDot-1);
        PlainName=strrep(PlainName,NameSuffix,'');
        PlainName=[PlainName Loaded.Name(FinalDot:end)];
        
        
        BinMask=Loaded.BinMask;
        F1=Loaded.F1;
        Name=[SubFolderStructure PlainName];
        Result=Loaded.Result;
        bayer=Loaded.bayer;
        
        if ~exist([FinalOutputFolder SubFolderStructure PlainName '.mat'],'file')
            save([FinalOutputFolder SubFolderStructure PlainName '.mat'], 'BinMask', 'F1', 'Name', 'Result', 'bayer', 'Quality', 'Rescale', '-v7.3');
            system(['mv ' In_Base FolderIn '/' InList(ii).name ' ' SortedOutDir]);
        else
            Existing=load([FinalOutputFolder SubFolderStructure PlainName '.mat']);
            if iscell(Existing.Result)
                if ~iscell(Loaded.Result)
                    system(['mv ' In_Base FolderIn '/' InList(ii).name ' ' SortedOutDir]);
                else
                    if Existing.F1==Loaded.F1 && sum(sum(Existing.Result{1}~=Loaded.Result{1}))==0
                        system(['mv ' In_Base FolderIn '/' InList(ii).name ' ' SortedOutDir]);
                    else
                        disp(['Both Cells, but different!' FinalOutputFolder SubFolderStructure PlainName '.mat']);
                    end
                end
            else
                if iscell(Loaded.Result)
                    system(['mv ' FinalOutputFolder SubFolderStructure PlainName '.mat ' SortedOutDir]);
                    save([FinalOutputFolder SubFolderStructure PlainName '.mat'], 'BinMask', 'F1', 'Name', 'Result', 'bayer', 'Quality', 'Rescale', '-v7.3');
                else
                    disp(['None is a Cell!' FinalOutputFolder SubFolderStructure PlainName '.mat']);
                end
            end
            %disp(['File exists! ' FinalOutputFolder SubFolderStructure PlainName '.mat']);
        end
    else
        disp(['No slashes! ' Loaded.Name]);
    end
end