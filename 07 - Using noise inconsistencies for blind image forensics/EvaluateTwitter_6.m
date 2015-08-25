load('../Datasets.mat');
% set parameters
BlockSize=8;

List=[getAllFiles(MarkRealWorldSplices_First,'*.jpg',true); getAllFiles(MarkRealWorldSplices_First,'*.jpeg',true); getAllFiles(MarkRealWorldSplices_First,'*.tif',true); getAllFiles(MarkRealWorldSplices_First,'*.png',true); getAllFiles(MarkRealWorldSplices_First,'*.gif',true); getAllFiles(MarkRealWorldSplices_First,'*.tif',true); getAllFiles(MarkRealWorldSplices_First,'*.bmp',true)];
List=[];
for DataPath={TwJPEG,TwResJPEG}
    List=[List;getAllFiles(DataPath{1},'*.jpg',true); getAllFiles(DataPath{1},'*.jpeg',true); getAllFiles(DataPath{1},'*.tif',true); getAllFiles(DataPath{1},'*.png',true); getAllFiles(DataPath{1},'*.gif',true); getAllFiles(DataPath{1},'*.tif',true); getAllFiles(DataPath{1},'*.bmp',true)];
end

k=colormap;

for ii=1:length(List)
    if mod(ii,15)==0
        disp(ii)
    end
    
    filename=List{ii};
    im =imread(filename);
    
    dots=strfind(filename,'.');
    extension=filename(dots(end):end);
    
    if strcmpi(extension,'.gif') && size(im,3)<3
        [im_gif,gif_map] =imread(filename);
        im_gif=im_gif(:,:,:,1);
        im=uint8(ind2rgb(im_gif,gif_map)*255);
    end
    
    if size(im,3)<3
        im(:,:,2)=im(:,:,1);
        im(:,:,3)=im(:,:,1);
    end
    
    map = GetNoiseMap(im, BlockSize);
    
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_07.tiff'];
    
    OutputMap=uint8((map)/50*63); %50 is an experimental maximum for real-world images
    OutputMap=imresize(OutputMap,[size(im,1) size(im,2)]);
    OutputMap(OutputMap>63)=63;
    OutFilename=strrep(OutFilename, 'D:\markzampoglou\ImageForensics\Datasets\', 'D:\markzampoglou\ImageForensics\Datasets\SyntheticEvaluations\');
    imwrite(OutputMap,k,OutFilename);
end