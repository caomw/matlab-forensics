load('../Datasets.mat');
% set parameters
ncomp = 1;
c1 = 1;
c2 = 15;

List=[];
for DataPath=
for DataPath={TwJPEG,TwResJPEG}
    List=[List;getAllFiles(DataPath{1},'*.jpg',true); getAllFiles(DataPath{1},'*.jpeg',true)];
end

k=colormap;
for ii=1:length(List)
    filename=List{ii};
    im = jpeg_read(filename);
    map = getJmap(im,ncomp,c1,c2);
    
    OutputMap=uint8(map*64);
    OutputMap=imresize(OutputMap,[im.image_height im.image_width]);
    
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_03.tiff'];
    OutFilename=strrep(OutFilename, 'D:\markzampoglou\ImageForensics\Datasets\', 'D:\markzampoglou\ImageForensics\Datasets\SyntheticEvaluations\');
    imwrite(OutputMap,k,OutFilename);
end

