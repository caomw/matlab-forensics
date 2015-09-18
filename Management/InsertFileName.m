AlgorithmName={'01', '02', '04', '05'};
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';

for ii=1:length(AlgorithmName)
    Algorithm=AlgorithmName{ii};
    FileList=getAllFiles([OutputRoot Algorithm '/'],'*.mat',true);
    for File=1:length(FileList)
        FullName=FileList{File};
        Loaded=load(FullName);
        if ~isfield(Loaded,'Name')
            Loaded.Name=strrep(FullName,[OutputRoot Algorithm '/' num2str(Loaded.Quality) '_' num2str(Loaded.Rescale) '/'],'');
            Loaded.Name=strrep(Loaded.Name,'.mat','');
            save(FullName,'-struct','Loaded','-v7.3');
        else
            disp(Loaded.Name);
        end
    end
end