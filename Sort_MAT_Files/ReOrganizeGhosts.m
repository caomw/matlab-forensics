InBase='/home/marzampoglou/ImageForensicsFeatures/Ghosts/SyntheticData/';

Out_Base='/home/marzampoglou/ImageForensicsFeatures/Ghosts_PostCrash/';


FolderList=dir('/home/marzampoglou/ImageForensicsFeatures/Ghosts/SyntheticData/');
FolderList=FolderList(3:end);

for Folder=1:length(FolderList)
    FileList=getAllFiles([InBase FolderList(Folder).name],'*.mat',true);
    for ii=1:length(FileList)
        Loaded=load(FileList{ii});
        if strcmp(Loaded.Name(1:3),'D:\')
            Slashes=strfind(Loaded.Name,'\');
        else
            Slashes=strfind(Loaded.Name,'/');
        end
        Loaded.Name=strrep(Loaded.Name,'\','/');
        FinalSlash=Slashes(end);
        Dots=strfind(Loaded.Name,'.');
        FinalDot=Dots(end);
        Loaded.AlgorithmName='08 - Ghost';
        if strfind(Loaded.Name,'TwResJPEG')
            OutBaseInd=strfind(Loaded.Name,'TwResJPEG/')+10;
            Loaded.Quality=75;
            Loaded.Rescale=true;
            NameSuffix='_Tw';
        elseif strfind(Loaded.Name,'TwJPEG')
            OutBaseInd=strfind(Loaded.Name,'TwJPEG/')+7;
            Loaded.Quality=75;
            Loaded.Rescale=false;
            NameSuffix='_Tw';         
        else
            OutBaseInd=strfind(Loaded.Name,'/ImageForensics/Datasets/')+25;
            Loaded.Quality=00;
            Loaded.Rescale=false;
            NameSuffix='';
        end
        
        FinalOutputFolder=[Out_Base num2str(Loaded.Quality) '_' num2str(Loaded.Rescale) '/'];
        
        SubFolderStructure=Loaded.Name(OutBaseInd:FinalSlash);
        if ~exist([FinalOutputFolder SubFolderStructure], 'dir')
            mkdir([FinalOutputFolder SubFolderStructure]);
        end
        
        PlainName=Loaded.Name(FinalSlash+1:FinalDot-1);
        PlainName=strrep(PlainName,NameSuffix,'');
        PlainName=[PlainName Loaded.Name(FinalDot:end)];
        
        Loaded.Name=Loaded.Name(OutBaseInd:end);
        save([FinalOutputFolder SubFolderStructure PlainName '.mat'], '-struct', 'Loaded', '-v7.3');
        
    end
end