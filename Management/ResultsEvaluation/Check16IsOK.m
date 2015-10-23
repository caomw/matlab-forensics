List=getAllFiles('/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/16/','*.mat',true);

for ii=22000:length(List)
    load(List{ii});
    if mod(ii,1000)==0
        disp([ii length(List)])
    end
end