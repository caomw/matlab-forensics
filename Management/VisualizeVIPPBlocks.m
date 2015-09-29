BasePath='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/VIPP/TIFS_RealisticDATASET/Forgery/bboxes/';
bboxList=dir([BasePath '*.bbox']);

for ii=1:length(bboxList);
    BBoxFileName=[BasePath bboxList(ii).name]
    ImageFileName=strrep(BBoxFileName,'bboxes/','');
    ImageFileName=strrep(ImageFileName,'.bbox','')
    MyMaskFileName=strrep(ImageFileName,'/ImageForensics/Datasets/','/ImageForensics/Datasets/Masks/');
    MyMaskFileName=strrep(MyMaskFileName,'jpg','png');
    MyMaskFileName=strrep(MyMaskFileName,'jpeg','png');
    im=CleanUpImage(ImageFileName);
    MyMask=CleanUpImage(MyMaskFileName);

    
    FID=fopen(BBoxFileName,'r');
    C = textscan(FID,'%s','delimiter','\n');
    fclose(FID);
    C=C{1};
    C=C{2};
    C=strrep(C,'Non-aligned ','');
    Coords=str2double(strsplit(C,','))
    BlockMask=zeros(size(im,1),size(im,2));
    left=Coords(1);
    top=Coords(2);
    right=Coords(1)+Coords(3);
    bottom=Coords(2)+Coords(4);
    
    BlockMask=zeros(size(im,1),size(im,2));
    BlockMask(top:bottom,left:right)=1;
    
    imwrite(BlockMask,['BlockMasks/' strrep(MyMaskFileName, '/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Masks/VIPP/TIFS_RealisticDATASET/Forgery/','')]);
end