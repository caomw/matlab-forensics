AlgorithmName='01';
Quality='0';

%if the algorithm returns multiple masks, which to use
MaskInd=1;
%at which value to threshold the mask
MaskThreshold=0.6;


ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
InputDir=[InputRoot AlgorithmName '/' num2str(Quality) '_0/1st Image Forensics Challenge/dataset-dist/phase-02/fake/'];

InputList=dir([InputDir '*.mat']);

OutputDir=['/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st Image Forensics Challenge/MySubmissions/' AlgorithmName '_' num2str(Quality) '/'];
mkdir(OutputDir);


for InputFile=1:length(InputList)
    L=load([InputDir InputList(InputFile).name]);
    Map=GetAlgorithmInputMap(L,AlgorithmName);
    Map=Map{MaskInd};
    ReferenceImage=CleanUpImage([ImageRoot L.Name]);
    Map=imresize(Map,[size(ReferenceImage,1) size(ReferenceImage,2)]);
    %Tampered should be 0, pristine should be 255
    BinMask=uint8((Map<MaskThreshold)*255);
    
    S=strel('disk',6);
    BinMask=imclose(BinMask,S);

    S=strel('disk',10);
    BinMask=imopen(BinMask,S);
    
    slashes=strfind(L.Name,'/');
    MaskName=strrep(L.Name(slashes(end)+1:end),'.png','.mask.png');
    imwrite(BinMask,[OutputDir MaskName]);
end

zip([strrep(OutputDir, [AlgorithmName '_' num2str(Quality) '/'],'') 'Subm_' AlgorithmName '_' num2str(Quality) '.zip'],[OutputDir '*.png']);