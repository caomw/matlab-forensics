DatasetDir='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';

In_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
FolderIn='SLIC';

SortedOutDir=['/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/SortedOut/' FolderIn '/'];
mkdir(SortedOutDir);

Out_Base='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
FolderOut='SLIC';

FinalOutputFolder=[Out_Base FolderOut '/'];

InList=dir([In_Base FolderIn '/*.mat']);

for ii=1:length(InList)
    Loaded=load([In_Base FolderIn '/' InList(ii).name]);
    
    dots=strfind(InList(ii).name,'.');
    PureImageName=InList(ii).name(1:dots(end)-1);
    
    [~,FindOutput]=system(['find /media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st\ Image\ Forensics\ Challenge/ | grep ' PureImageName]);
    disp(FindOutput)
    
    Name=strrep(FindOutput(1:end-1),DatasetDir,'');
    l=Loaded.l;
    AlgorithmName='SLIC';
    
    slashes=strfind(Name,'/');
    SubFolderStructure=Name(1:slashes(end)-1);
    
    if ~exist([FinalOutputFolder SubFolderStructure], 'dir')
        mkdir([FinalOutputFolder SubFolderStructure]);
    end
    
    save([FinalOutputFolder Name '.mat'],'Name','l','AlgorithmName', '-v7.3');
end