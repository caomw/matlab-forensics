function BuildOutputZip(AlgorithmName,Quality,MaskInd,MaskThreshold,CloseR,OpenR,Close2R)
    
    if nargin==0
        AlgorithmName='01';
        Quality=0;
        %if the algorithm returns multiple masks, which to use
        MaskInd=1;
        %at which value to threshold the mask
        MaskThreshold=0.6;
        CloseR=6;
        OpenR=10;
        Close2R=0;
    end
    
    
    if Quality==0
        ImageRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
    else
        ImageRoot=['/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Resaved/' num2str(Quality) '_0/'];
    end
    
    InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';
    InputDir=[InputRoot AlgorithmName '/' num2str(Quality) '_0/1st Image Forensics Challenge/dataset-dist/phase-02/fake/'];
    
    InputList=dir([InputDir '*.mat']);
    
    OutputDir=['/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st Image Forensics Challenge/MySubmissions/' AlgorithmName '_' num2str(Quality) '_' num2str(MaskInd) '_' num2str(MaskThreshold) '_' num2str(CloseR) '_' num2str(OpenR) '_' num2str(Close2R) '/']
    mkdir(OutputDir);
    
    
    for InputFile=1:length(InputList)
        L=load([InputDir InputList(InputFile).name]);
        Map=GetAlgorithmInputMap(L,AlgorithmName);
        Map=Map{MaskInd};
        ReferenceImage=CleanUpImage([ImageRoot L.Name]);
        Map=imresize(Map,[size(ReferenceImage,1) size(ReferenceImage,2)]);
        %Tampered should be 0, pristine should be 255
        BinMask=(Map<MaskThreshold);
        
        S=strel('disk',CloseR);
        BinMask=imclose(BinMask,S);
        
        S=strel('disk',OpenR);
        BinMask=imopen(BinMask,S);
        
        S=strel('disk',Close2R);
        BinMask=imclose(BinMask,S);
        
        BinMask=uint8(double(BinMask)*255);
        slashes=strfind(L.Name,'/');
        MaskName=strrep(L.Name(slashes(end)+1:end),'.png','.mask.png');
        if Quality~=0
            MaskName=strrep(MaskName,'.jpg','');
        end
        imwrite(BinMask,[OutputDir MaskName]);
    end
    
    zip([strrep(OutputDir, [AlgorithmName '_' num2str(Quality) '_' num2str(MaskInd) '_' num2str(MaskThreshold) '_' num2str(CloseR) '_' num2str(OpenR) '_' num2str(Close2R) '/'],'') 'Subm_' AlgorithmName '_' num2str(Quality) '_' num2str(MaskInd) '_' num2str(MaskThreshold) '_' num2str(CloseR) '_' num2str(OpenR) '_' num2str(Close2R) '.zip'],[OutputDir '*.png']);

    disp([strrep(OutputDir, [AlgorithmName '_' num2str(Quality) '_' num2str(MaskInd) '_' num2str(MaskThreshold) '_' num2str(CloseR) '_' num2str(OpenR) '_' num2str(Close2R) '/'],'') 'Subm_' AlgorithmName '_' num2str(Quality) '.zip'])