load('../Datasets.mat');

% set parameters
ncomp = 1;
c2 = 6;
k1 = 8;
k2 = 4;
alpha0 = 0.5;
dLmin = 100;
maxIter = 100;


List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true)];
k=colormap;
for ii=1:length(List)
    if mod(ii,15)==0
        disp(ii)
    end
    filename=List{ii};
    im = jpeg_read(filename);
    
    map = getJmapNA_EM_oracle(im,ncomp,c2,k1,k2,true,alpha0,dLmin,maxIter);
    map_final = smooth_unshift(sum(map,3),k1,k2);
    MapMin=min(min(map_final));
    MapRange=max(max(map_final))-min(min(map_final));
    OutputMap=uint8((map_final-MapMin)/MapRange*63);
    OutputMap=imresize(OutputMap,[im.image_height, im.image_width]);
    OutputMap(OutputMap>63)=63;
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_06.tiff'];
    imwrite(OutputMap,k,OutFilename);
    
end