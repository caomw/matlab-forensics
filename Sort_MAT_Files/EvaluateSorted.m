list=dir('/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/04 - Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts/75_0/Columbia Uncompressed Image Splicing Detection Evaluation Dataset/4cam_splc/4cam_splc/');

count=0;
for ii=3:length(list)
    L=load(['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/04 - Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts/75_0/Columbia Uncompressed Image Splicing Detection Evaluation Dataset/4cam_splc/4cam_splc/' list(ii).name]);
    if ~iscell(L.Result)
        count=count+1;
    end
end
count