%AllFiles=getAllFiles('/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/04/','*.mat',true);

for File=2:length(AllFiles)
    L=load(AllFiles{File});
    
    for ii=1:2
        expMap=exp(L.Result{ii});
        probMap=1./(expMap+1);
        L.Result{ii}=probMap;
    end
    
    save(AllFiles{File}, '-struct', 'L');
    if mod(File,50)==0
       disp([num2str(File) '/' num2str(length(AllFiles))]);
    end
end