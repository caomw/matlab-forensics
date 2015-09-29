InFolder='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/CASIA2/';
fileList=dir([InFolder '*.png']);
fileList=fileList(3:end);

for ii=1:length(fileList)
    S=strel('disk',6);
    Sdil=strel('disk',2);
    Im=imread([InFolder  fileList(ii).name]);
    Im=imopen(Im,S);
    Im=imdilate(Im,Sdil);
    imwrite(Im,[InFolder  'Opened/' fileList(ii).name]);
end