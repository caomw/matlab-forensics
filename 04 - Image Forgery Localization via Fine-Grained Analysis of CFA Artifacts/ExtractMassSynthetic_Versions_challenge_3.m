JPEG_Qualities=75;

load('../Datasets_Linux.mat');
DataPath={FirstChallengeTrain.Sp, FirstChallengeTrain.Au, FirstChallengeTest.Sp, FirstChallengeTest2.Sp};
OutNames={'FirstChallengeTrain_sp.mat','FirstChallengeTrain_au.mat', 'FirstChallengeTest_sp.mat'  'FirstChallengeTest2_sp.mat'};
Masks= {'/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/Masks/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake/','','',''};

% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;
% Pattern of CFA on green channel
%bayer = [0, 1;  1, 0];

upLimit=inf;
for Quality=JPEG_Qualities
    for FolderInd=1:length(DataPath)
        %DataPath{FolderInd}=strrep(DataPath{FolderInd},'\','/');
        
            DataPath{FolderInd}=strrep(DataPath{FolderInd},'/media/marzampoglou/New Volume','D:');    
            DataPath{FolderInd}=strrep(DataPath{FolderInd},'/','\');
            Masks{FolderInd}=strrep(Masks{FolderInd},'/media/marzampoglou/New Volume','D:');    
            Masks{FolderInd}=strrep( Masks{FolderInd},'/','\');     
            
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
            
            dots=strfind(filename,'.');
            extension=filename(dots(end):end);
            
            toCrop=mod(size(im),2);
            im=im(1:end-toCrop(1),1:end-toCrop(2),:);
            
            [bayer, F1]=GetCFASimple(im);
            
            Result=cell(2,1);
            
            for j = 1:2
                [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
                
                Result{j}=map;
            end
            Name=List{ii};
            
            if ~isempty(MaskList)
                if length(List)==length(MaskList)
                    fileslashes=strfind(filename,'\');
                    filedots=strfind(filename,'.');
                    PureFileName=filename(fileslashes(end)+1:filedots(end)-1);
                    if strcmp(PureFileName(end-2:end),'_Tw')
                        PureFileName=PureFileName(1:end-3);
                    end
                    match=0;
                    MaskInd=1;
                    while (~match) && MaskInd<=length(MaskList)
                        maskname=MaskList{MaskInd};
                        maskslashes=strfind(maskname,'\');
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