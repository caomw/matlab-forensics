In_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
FolderIn='08';
OutSuffix='RW';

SortedOutDir=['/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/SortedOut/' FolderIn '/' OutSuffix '/'];
mkdir(SortedOutDir);

Out_Base='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';

Duplicates_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/Duplicates/';

FinalOutputFolder=[Out_Base FolderIn '/' OutSuffix '/'];

FinalDuplicateFolder=[Duplicates_Base FolderIn '/' OutSuffix '/'];
mkdir(FinalDuplicateFolder);


InList=dir([In_Base FolderIn '/*.mat']);
disp('Starting');
for ii=1:length(InList)
    Loaded=load([In_Base FolderIn '/' InList(ii).name]);
    if strcmp(Loaded.Name(1:3),'D:\')
        Slashes=strfind(Loaded.Name,'\');
    else
        Slashes=strfind(Loaded.Name,'/');
    end
    if isempty(Slashes)
        if ~exist([FinalOutputFolder], 'dir')
            mkdir([FinalOutputFolder]);
        end
        if ~exist([FinalOutputFolder Loaded.Name '.mat'],'file')
            save([FinalOutputFolder Loaded.Name '.mat'],'-struct','Loaded');
            %system(['cp ' In_Base FolderIn '/' InList(ii).name ' ' FinalOutputFolder Loaded.Name '.mat']);
            system(['mv ' In_Base FolderIn '/' InList(ii).name ' ' SortedOutDir]);
        else
            LExist=load([FinalOutputFolder Loaded.Name '.mat']);
            if isequal(Loaded,LExist)
                system(['mv ' In_Base FolderIn '/' InList(ii).name ' ' SortedOutDir]);
            else
                movefile([FinalOutputFolder Loaded.Name '.mat'],[FinalDuplicateFolder Loaded.Name '.mat '])
            end
            
        end
        
    end
    if ~mod(ii,500)
        disp(ii)
    end
end