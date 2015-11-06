clear all;
FileList=getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Anastasia/Anastasia Images/Sp','*.jpg',true);
FileList=[FileList;getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Anastasia/Anastasia Images/Sp','*.JPG',true)];

for ii=1:length(FileList)
    slashes=strfind(FileList{ii},'/');
    OutFileName=['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Anastasia/' FileList{ii}(slashes(end)+1:end) '.mat'];
    
    if ~exist(OutFileName)
        disp(OutFileName)
        im=imread(FileList{ii});
        im_jpg=jpeg_read(FileList{ii});
        Report = BuildForensicReport(im, im_jpg);
        
        save(OutFileName,'Report','im','im_jpg');
    end
end