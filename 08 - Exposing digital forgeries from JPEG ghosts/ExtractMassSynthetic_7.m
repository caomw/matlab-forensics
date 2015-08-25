load('../Datasets_Linux.mat');
%DataPath={CASIA2.au, CASIA2.tp, ColumbiaImage.au, ColumbiaImage.sp, ColumbiauUncomp.au, ColumbiauUncomp.sp, UCID.au, VIPPDempSchaReal.au, VIPPDempSchaReal.sp, VIPPDempSchaSynth.au, VIPPDempSchaSynth.sp, CASIA2Tw.au, CASIA2Tw.tp, ColumbiaImageTw.au, ColumbiaImageTw.sp, ColumbiauUncompTw.au, ColumbiauUncompTw.sp, UCIDTw.au, VIPPDempSchaRealTw.au, VIPPDempSchaRealTw.sp, VIPPDempSchaSynthTw.au, VIPPDempSchaSynthTw.sp, CASIA2TwRes.au, CASIA2TwRes.tp, ColumbiaImageTwRes.au, ColumbiaImageTwRes.sp, ColumbiauUncompTwRes.au, ColumbiauUncompTwRes.sp, UCIDTwRes.au, VIPPDempSchaRealTwRes.au, VIPPDempSchaRealTwRes.sp, VIPPDempSchaSynthTwRes.au, VIPPDempSchaSynthTwRes.sp};
%OutNames={'CASIA2_au.mat', 'CASIA2_tp.mat', 'ColumbiaImage_au.mat', 'ColumbiaImage_sp.mat', 'ColumbiauUncomp_au.mat', 'ColumbiauUncomp_sp.mat', 'UCID_au.mat', 'VIPPDempSchaReal_au.mat', 'VIPPDempSchaReal_sp.mat', 'VIPPDempSchaSynth_au.mat', 'VIPPDempSchaSynth_sp.mat', 'CASIA2Tw_au.mat', 'CASIA2Tw_tp.mat', 'ColumbiaImageTw_au.mat', 'ColumbiaImageTw_sp.mat', 'ColumbiauUncompTw_au.mat', 'ColumbiauUncompTw_sp.mat', 'UCIDTw_au.mat', 'VIPPDempSchaRealTw_au.mat', 'VIPPDempSchaRealTw_sp.mat', 'VIPPDempSchaSynthTw_au.mat', 'VIPPDempSchaSynthTw_sp.mat', 'CASIA2TwRes_au.mat', 'CASIA2TwRes_tp.mat', 'ColumbiaImageTwRes_au.mat', 'ColumbiaImageTwRes_sp.mat', 'ColumbiauUncompTwRes_au.mat', 'ColumbiauUncompTwRes_sp.mat', 'UCIDTwRes_au.mat', 'VIPPDempSchaRealTwRes_au.mat', 'VIPPDempSchaRealTwRes_sp.mat', 'VIPPDempSchaSynthTwRes_au.mat', 'VIPPDempSchaSynthTwRes_sp.mat'};
%Masks={'', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET', '', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET', '', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET'};

DataPath={FirstChallengeTrain.Sp, FirstChallengeTrain.Au, FirstChallengeTest.Sp, FirstChallengeTest2.Sp};  %{CASIA2.au, CASIA2.tp, ColumbiaImage.au, ColumbiaImage.sp, ColumbiauUncomp.au, ColumbiauUncomp.sp, UCID.au, VIPPDempSchaReal.au, VIPPDempSchaReal.sp, VIPPDempSchaSynth.au, VIPPDempSchaSynth.sp, CASIA2Tw.au, CASIA2Tw.tp, ColumbiaImageTw.au, ColumbiaImageTw.sp, ColumbiauUncompTw.au, ColumbiauUncompTw.sp, UCIDTw.au, VIPPDempSchaRealTw.au, VIPPDempSchaRealTw.sp, VIPPDempSchaSynthTw.au, VIPPDempSchaSynthTw.sp, CASIA2TwRes.au, CASIA2TwRes.tp, ColumbiaImageTwRes.au, ColumbiaImageTwRes.sp, ColumbiauUncompTwRes.au, ColumbiauUncompTwRes.sp, UCIDTwRes.au, VIPPDempSchaRealTwRes.au, VIPPDempSchaRealTwRes.sp, VIPPDempSchaSynthTwRes.au, VIPPDempSchaSynthTwRes.sp};
OutNames={'FirstChallengeTrain_sp.mat','FirstChallengeTrain_au.mat', 'FirstChallengeTest_sp.mat'  'FirstChallengeTest2_sp.mat'}; {'CASIA2_au.mat', 'CASIA2_tp.mat', 'ColumbiaImage_au.mat', 'ColumbiaImage_sp.mat', 'ColumbiauUncomp_au.mat', 'ColumbiauUncomp_sp.mat', 'UCID_au.mat', 'VIPPDempSchaReal_au.mat', 'VIPPDempSchaReal_sp.mat', 'VIPPDempSchaSynth_au.mat', 'VIPPDempSchaSynth_sp.mat', 'CASIA2Tw_au.mat', 'CASIA2Tw_tp.mat', 'ColumbiaImageTw_au.mat', 'ColumbiaImageTw_sp.mat', 'ColumbiauUncompTw_au.mat', 'ColumbiauUncompTw_sp.mat', 'UCIDTw_au.mat', 'VIPPDempSchaRealTw_au.mat', 'VIPPDempSchaRealTw_sp.mat', 'VIPPDempSchaSynthTw_au.mat', 'VIPPDempSchaSynthTw_sp.mat', 'CASIA2TwRes_au.mat', 'CASIA2TwRes_tp.mat', 'ColumbiaImageTwRes_au.mat', 'ColumbiaImageTwRes_sp.mat', 'ColumbiauUncompTwRes_au.mat', 'ColumbiauUncompTwRes_sp.mat', 'UCIDTwRes_au.mat', 'VIPPDempSchaRealTwRes_au.mat', 'VIPPDempSchaRealTwRes_sp.mat', 'VIPPDempSchaSynthTwRes_au.mat', 'VIPPDempSchaSynthTwRes_sp.mat'};
Masks= {'/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/Masks/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake/','','','',};%{'', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET', '', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET', '', '', '', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset', '', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_RealisticDATASET\Forgery', '', 'D:\markzampoglou\ImageForensics\Datasets\Masks\VIPP\A Framework for Decision Fusion in Image Forensics based on Dempster-Shafer Theory of Evidence\TIFS_SyntheticDATASET'};

% set parameters
checkDisplacements=0;
smoothFactor=1;

upLimit=inf;

% set parameters
c2 = 6;

for FolderInd=4:length(DataPath)
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
    OutPath=['~/ImageForensicsFeatures/NewGhosts/SyntheticData/' OutPath '/'];
    mkdir(OutPath);
    
    for ii=1:min(length(List),upLimit)
        if mod(ii,15)==0
            disp(ii);
        end
        
        filename=List{ii};
        im=CleanUpImage(filename);
        [Results.OutputX, Results.OutputY, Results.dispImages, Results.imin, Results.Qualities, Results.Mins]=Ghost(im, checkDisplacements, smoothFactor);
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
        save([OutPath num2str(ii)],'Results','Name','BinMask','-v7.3');
    end
end