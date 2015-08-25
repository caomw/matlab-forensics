PathSource='/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/Columbia Uncompressed Image Splicing Detection Evaluation Dataset';


FileList=getAllFiles(PathSource,'*.tif',true);

for ii=1:length(FileList)
    [lc,lc_t,lc_comb] = SegmentImage(FileList{ii});
    
    ColorMaps{ii}=lc;
    TextureMaps{ii}=lc_t;
    MixedMaps{ii}=lc_comb;
    
    OutPath=strrep(FileList{ii},'/ImageForensics/Datasets/','/ImageForensics/Datasets/Segmentations/');
    OutPath=strrep(OutPath,'.tif','.mat');
    save(OutPath,'lc','lc_t','lc_comb');
    disp(ii)
end

save('test.mat','ColorMaps','TextureMaps','MixedMaps');