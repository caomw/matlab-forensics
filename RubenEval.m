FileList=getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Ruben/Reveal_Image_Manipulation_Dataset-2015-08-21/Reveal Image Manipulation Dataset/','*.JPG',true);

for ii=1:length(FileList)
    slashes=strfind(FileList{ii},'/');
    OutFileName=['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Ruben/' FileList{ii}(slashes(end)+1:end) '.mat'];
    
    if ~exist(OutFileName)
        disp(OutFileName)
        im=imread(FileList{ii});
        im_jpg=jpeg_read(FileList{ii});
        Report = BuildForensicReport(im, im_jpg);
        
        save(OutFileName,'Report','im','im_jpg');
    end
    
end