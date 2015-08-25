JPEG_Qualities=[100 95 85 65];

load('../Datasets_Linux.mat');
DataPath={ColumbiauUncomp.au, ColumbiauUncomp.sp, VIPPDempSchaReal.au, VIPPDempSchaReal.sp, VIPPDempSchaSynth.au, VIPPDempSchaSynth.sp, FirstChallengeTrain.Sp, FirstChallengeTrain.Au, FirstChallengeTest.Sp, FirstChallengeTest2.Sp};
OutNames={'ColumbiauUncomp_au.mat', 'ColumbiauUncomp_sp.mat', 'VIPPDempSchaReal_au.mat', 'VIPPDempSchaReal_sp.mat', 'VIPPDempSchaSynth_au.mat', 'VIPPDempSchaSynth_sp.mat', 'FirstChallengeTrain_sp.mat','FirstChallengeTrain_au.mat', 'FirstChallengeTest_sp.mat'  'FirstChallengeTest2_sp.mat'};
Masks= {'', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET','/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/Masks/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake/','','',''};


upLimit=inf;
for Quality=JPEG_Qualities
    for FolderInd=1:length(DataPath)
        DataPath{FolderInd}=strrep(DataPath{FolderInd},'\','/');
        DataPath{FolderInd}
        
        List=[getAllFiles(DataPath{FolderInd},'*.jpg',true); getAllFiles(DataPath{FolderInd},'*.jpeg',true); getAllFiles(DataPath{FolderInd},'*.tif',true); getAllFiles(DataPath{FolderInd},'*.png',true); getAllFiles(DataPath{FolderInd},'*.gif',true); getAllFiles(DataPath{FolderInd},'*.bmp',true)];
        
        if ~strcmp(Masks{FolderInd},'')
            MaskList=getAllFiles(Masks{FolderInd},'*.png',true);
        else
            MaskList=cell(0);
        end
        
        OutPath=OutNames{FolderInd};
        disp(OutPath);
        dots=strfind(OutPath,'.');
        OutPath=OutPath(1:dots(end)-1);
        OutPath=['SyntheticData/' OutPath  '_' num2str(Quality) '/'];
        mkdir(OutPath);

        for ii=1:min(length(List),upLimit)
            if mod(ii,15)==0
                disp(ii);
            end
            
            filename=List{ii};
            
            imSource = CleanUpImage(filename);
            imwrite(imSource,'tmpjpg.jpg','Quality',Quality);
            im=CleanUpImage('tmpjpg.jpg');
            
            
            toCrop=mod(size(im),2);
            im=im(1:end-toCrop(1),1:end-toCrop(2),:);

            OutputMap=CFATamperDetection_Both(im);
            Result=OutputMap;

            Name=List{ii};
            
            if ~isempty(MaskList)
                if length(List)==length(MaskList)
                    fileslashes=strfind(filename,'/');
                    filedots=strfind(filename,'.');
                    PureFileName=filename(fileslashes(end)+1:filedots(end)-1);
                    if strcmp(PureFileName(end-2:end),'_Tw')
                        PureFileName=PureFileName(1:end-3);
                    end
                    match=0;
                    MaskInd=1;
                    while (~match) && MaskInd<=length(MaskList)
                        maskname=MaskList{MaskInd};
                        maskslashes=strfind(maskname,'/');
                        maskdots=strfind(maskname,'.');
                        PureMaskName=maskname(maskslashes(end)+1:maskdots(end)-1);
                        if strcmp(PureFileName,PureMaskName) || strcmp([PureFileName '-Mask'],PureMaskName) || strcmp([PureFileName '.mask'],PureMaskName)
                            match=1;
                        else
                            MaskInd=MaskInd+1;
                        end
                    end
                    
                    if MaskInd>length(MaskList)
                        disp('----------------')
                        disp(filename)
                        disp(maskname)
                        disp(PureFileName);
                        disp(PureMaskName);
                        error('Mask not found');
                    end
                    Mask=imread(MaskList{MaskInd});
                else
                    Mask=imread(MaskList{1});
                end
                BinMask=mean(double(Mask),3)>0;
            else
                BinMask=cell(0);
            end
            save([OutPath num2str(ii)],'Result','Name','BinMask','bayer','F1','-v7.3');
        end
    end
end