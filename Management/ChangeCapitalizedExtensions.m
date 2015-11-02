AllFiles=getAllFiles('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Wild Web Dataset/WildWeb/','*.*',true);

for ii=1:length(AllFiles)
    [~,~,Extension]=fileparts(AllFiles{ii});
    if ~strcmp(lower(Extension),Extension)
        NewFileName=strrep(AllFiles{ii},Extension,lower(Extension));
        disp({AllFiles{ii};NewFileName});
        disp('--');
        movefile(AllFiles{ii},NewFileName);
    end
end