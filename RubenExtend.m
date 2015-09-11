FileList=getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Ruben/Reveal_Image_Manipulation_Dataset-2015-08-21/Reveal Image Manipulation Dataset/','*.jpg',true);
cd('./NotForEvaluations/03 - NADetection/');
    
for ii=1:length(FileList)
    slashes=strfind(FileList{ii},'/');
    OutFileName=['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Ruben/' FileList{ii}(slashes(end-1)+1:end) '.mat']
    Loaded=load(OutFileName,'Report','im','im_jpg');
    
    [k1,k2,Q,IPM,DIPM] = detectNA(Loaded.im_jpg,1,4,2.5,false);
    if Q > 0
        GridShift=[mod(9-k1,8) mod(9-k2,8)];
    else
        GridShift=[0 0];
    end
    
    Loaded.Report.F03_Gridshift=GridShift;
    Loaded.Report.F03_IPM=IPM;
    Loaded.Report.F03_DIPM=DIPM;
    Loaded.Report.F03_Q=Q;
    
    save(OutFileName,'-struct','Loaded');
    
    
end