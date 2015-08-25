load('../Datasets.mat');
% set parameters
ncomp = 1;
c1 = 1;
c2 = 15;

List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true)];
%temp
List=[getAllFiles('D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Extended and Refined Search\SyriaSmoke','*.jpg',true); getAllFiles('D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Extended and Refined Search\SyriaSmoke','*.jpeg',true)];

k=colormap;
for ii=1:length(List)
    if mod(ii,15)==0
        disp(ii);
    end
    filename=List{ii};
    im = jpeg_read(filename);
    map = getJmap(im,ncomp,c1,c2);
    OutputMap=uint8(map*63);
    OutputMap=imresize(OutputMap,[im.image_height im.image_width]);
    OutputMap(OutputMap>63)=63;
    
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_02.tiff'];
    
    imwrite(OutputMap,k,OutFilename);
end

