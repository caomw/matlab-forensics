load('../Datasets.mat');

% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;
% Pattern of CFA on green channel
bayer = [0, 1;
    1, 0];

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
    
    for j = 1:2
        [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
        
        MapMin=min(min(map));
        MapRange=max(max(map))-min(min(map));
        OutputMap=uint8((map-MapMin)/MapRange*63);
        OutputMap=imresize(OutputMap,[size(im,1) size(im,2)]);
        OutputMap(OutputMap>63)=63;
        
        dots=strfind(filename,'.');
        OutFilename=[filename(1:dots(end)-1) '_04_' num2str(j) '.tiff'];
        OutFilename=strrep(OutFilename, 'D:\markzampoglou\ImageForensics\Datasets\', 'D:\markzampoglou\ImageForensics\Datasets\SyntheticEvaluations\');
        
        imwrite(OutputMap,k,OutFilename);
    end
    
end

