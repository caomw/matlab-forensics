FileList=getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Ruben/Reveal_Image_Manipulation_Dataset-2015-08-21/Reveal Image Manipulation Dataset/','*.jpg',true);
<<<<<<< HEAD
<<<<<<< HEAD
FileList=[FileList;getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Ruben/Reveal_Image_Manipulation_Dataset-2015-08-21/Reveal Image Manipulation Dataset/','*.JPG',true)];
cd('./03 - NADetection/');
        
for ii=1:length(FileList)
    slashes=strfind(FileList{ii},'/');
    OutFileName=['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Ruben/' FileList{ii}(slashes(end-1)+1:end) '.mat']
    Loaded=load(OutFileName);
    if ~isfield(Loaded.Report,'F03_H1')

        [H1,H2] = minHNA(Loaded.im_jpg);
        Loaded.Report.F03_H1=H1;
        Loaded.Report.F03_H2=H2;
        save(OutFileName,'-struct','Loaded');
    end
=======
=======
>>>>>>> origin/master
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
    
    
<<<<<<< HEAD
>>>>>>> 9c91a43a5f9f9606503509c0f3394d63a8a749de
=======
>>>>>>> origin/master
end