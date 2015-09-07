ColumbPath='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/Columbia Uncompressed/4cam_splc/MaskSource/';
OutPath='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/Columbia Uncompressed/4cam_splc/';
Masks=dir([ColumbPath '*.jpg']);

for ii=1:length(Masks)
    if ~exist([OutPath strrep(Masks(ii).name,'_edgemask.jpg','.png')],'file')
        Mask=double(CleanUpImage([ColumbPath Masks(ii).name]));
        Mask=Mask(:,:,2)>128;
        circle=strel('disk',10);
        Mask=imclose(Mask,circle);
        imwrite(Mask,[OutPath strrep(Masks(ii).name,'_edgemask.jpg','.png')]);
    end
end