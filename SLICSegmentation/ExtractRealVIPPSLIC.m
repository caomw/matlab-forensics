%BasePath='/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/VIPP/A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence/TIFS_RealisticDATASET/Forgery/';
%fileList=dir([BasePath '*.jpg']);
%fileList={fileList.name};
%fileList=fileList(3:end);

for ii=1:length(fileList)
    disp([num2str(ii) ' ' datestr(now,13)])
    im=CleanUpImage([BasePath fileList{ii}]);
    [l] = SLIC_Colour( im );
    save(['./RealVIPP/' fileList{ii} '.mat'],'l');
end