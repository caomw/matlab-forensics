load('../Datasets.mat');

% set parameters
c2 = 6;

List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true)];

%temp
List=[getAllFiles('D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Additional\IranMissile','*.jpg',true); getAllFiles('D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Additional\IranMissile','*.jpeg',true)];



k=colormap;
for ii=1:length(List)
    if mod(ii,15)==0
        disp(ii)
    end

    filename=List{ii}
    im = jpeg_read(filename);
    
    [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
    map_final = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    MapMin=min(min(map_final));
    MapRange=max(max(map_final))-min(min(map_final));
    OutputMap=uint8((map_final-MapMin)/MapRange*63);
    OutputMap=imresize(OutputMap,[im.image_height, im.image_width]);
    OutputMap(OutputMap>63)=63;
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_05_A.tiff'];
    imwrite(OutputMap,k,OutFilename);
    
    [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
    map_final = smooth_unshift(sum(LLRmap,3),k1e,k2e);
    MapMin=min(min(map_final));
    MapRange=max(max(map_final))-min(min(map_final));
    OutputMap=uint8((map_final-MapMin)/MapRange*63);
    OutputMap=imresize(OutputMap,[im.image_height, im.image_width]);
    OutputMap(OutputMap>63)=63;
    dots=strfind(filename,'.');
    OutFilename=[filename(1:dots(end)-1) '_05_NA.tiff'];
    imwrite(OutputMap,k,OutFilename);
end