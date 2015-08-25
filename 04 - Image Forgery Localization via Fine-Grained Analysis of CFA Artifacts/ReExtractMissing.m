load('../Datasets.mat');
DataPath={CASIA2.tp, ColumbiauUncomp.sp};
OutNames={'CASIA2_tp.mat', 'ColumbiauUncomp_sp.mat'};
Masks={'','D:\markzampoglou\ImageForensics\Datasets\Masks\Columbia Uncompressed Image Splicing Detection Evaluation Dataset'};

% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;



for FolderInd=1:length(DataPath)
    List=[getAllFiles(DataPath{FolderInd},'*.jpg',true); getAllFiles(DataPath{FolderInd},'*.jpeg',true); getAllFiles(DataPath{FolderInd},'*.tif',true); getAllFiles(DataPath{FolderInd},'*.png',true); getAllFiles(DataPath{FolderInd},'*.gif',true); getAllFiles(DataPath{FolderInd},'*.bmp',true)];
    
    if ~strcmp(Masks{FolderInd},'')
        MaskList=getAllFiles(Masks{FolderInd},'*.png',true);
    else
        MaskList=cell(0);
    end
    
    OutPath=OutNames{FolderInd} ;
    disp(OutPath);
    dots=strfind(OutPath,'.');
    OutPath=OutPath(1:dots(end)-1);
    OutPath=['SyntheticData\' OutPath '\'];
    mkdir(OutPath);
    
    AlreadyExtracted=dir([OutPath '*.mat']);
    ExtractedList=cell(0);
    for ii=1:length(AlreadyExtracted)
        tmp=load([OutPath AlreadyExtracted(ii).name]);
        ExtractedList{ii}=tmp.Name;
    end
    
    ExtrasInd=length(AlreadyExtracted)+1;
    
    for ii=1:length(List)
        
        filename=List{ii};
        found=0;
        for ExtractedInd=1:length(ExtractedList)
            if strcmp(ExtractedList{ExtractedInd},filename)
                found=1;
                break
            end
        end
        
        
        if ~found
            disp(filename)
            im = CleanUpImage(filename);

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
                        if strcmp(PureFileName,PureMaskName) || strcmp([PureFileName '-Mask'],PureMaskName)
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
            save([OutPath num2str(ExtrasInd)],'Result','Name','BinMask','bayer','F1','-v7.3');
            disp(ExtrasInd);
            ExtrasInd=ExtrasInd+1;
            
        end
    end
end