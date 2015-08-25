load('../Datasets.mat');
% set parameters
ncomp = 1;
c1 = 1;
c2 = 15;

List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true)];
k=colormap;
for ii=1:length(List)
    filename=List{ii};
    im = jpeg_read(filename);
    map = getJmap(im,ncomp,c1,c2);

    OutputMap=uint8(map*64);
    OutputMap=imresize(OutputMap,[im.image_height im.image_width]);

dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_03.tiff'];

imwrite(OutputMap,k,OutFilename);
end

