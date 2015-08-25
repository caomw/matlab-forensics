JPEG_Qualities=75; %[100 95 85 65];

load('../Datasets_Linux.mat');
DataPath={FirstChallengeTrain.Sp, FirstChallengeTrain.Au, FirstChallengeTest.Sp, FirstChallengeTest2.Sp};
OutNames={'FirstChallengeTrain_sp.mat','FirstChallengeTrain_au.mat', 'FirstChallengeTest_sp.mat'  'FirstChallengeTest2_sp.mat'};
Masks= {'/media/marzampoglou/New Volume/markzampoglou/ImageForensics/Datasets/Masks/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake/','','',''};

% set parameters
c2 = 6;

upLimit=inf;
for Quality=JPEG_Qualities
    for FolderInd=1:length(DataPath)
        %DataPath{FolderInd}=strrep(DataPath{FolderInd},'\','/');
    DataPath{FolderInd}=strrep(DataPath{FolderInd},'/media/marzampoglou/New Volume/','D:\');    
    DataPath{FolderInd}=strrep(DataPath{FolderInd},'/','\');
    Masks{FolderInd}=strrep(Masks{FolderInd},'/media/marzampoglou/New Volume/','D:\');    
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
            im=jpeg_read('tmpjpg.jpg');
            Result=cell(5,2);
            Ks=cell(2,1);
            
            [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
            map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
            Result{1,1}=LLRmap;
            Result{2,1}=LLRmap_s;
            Result{3,1}=q1table;
            Result{4,1}=alphat;
            Result{5,1}=map_final;
            %MapMin=min(min(map_final));
            %MapRange=max(max(map_final))-min(min(map_final));
            %OutputMap=uint8((map_final-MapMin)/MapRange*63);
            %OutputMap=imresize(OutputMap,[im.image_height, im.image_width]);
            %OutputMap(OutputMap>63)=63;
            %dots=strfind(filename,'.');
            %OutFilename=[filename(1:dots(end)-1) '_05_A.tiff'];
            %OutFilename=strrep(OutFilename, 'D:\markzampoglou\ImageForensics\Datasets\', 'D:\markzampoglou\ImageForensics\Datasets\SyntheticEvaluations\');
            %imwrite(OutputMap,k,OutFilename);
            
            [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
            map_final = smooth_unshift(sum(LLRmap,3),k1e,k2e);
            Result{1,2}=LLRmap;
            Result{2,2}=LLRmap_s;
            Result{3,2}=q1table;
            Result{4,2}=alphat;
            Result{5,2}=map_final;
            Ks{1}=k1e;
            Ks{2}=k2e;
            
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
            save([OutPath num2str(ii)],'Result','Ks','Name','BinMask','-v7.3');
        end
    end
end