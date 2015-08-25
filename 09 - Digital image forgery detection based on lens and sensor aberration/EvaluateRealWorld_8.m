load('../../../Datasets.mat');

% set parameters

List=[getAllFiles(MarkRealWorldSplices_First,'*.jpg',true); getAllFiles(MarkRealWorldSplices_First,'*.jpeg',true); getAllFiles(MarkRealWorldSplices_First,'*.tif',true); getAllFiles(MarkRealWorldSplices_First,'*.png',true); getAllFiles(MarkRealWorldSplices_First,'*.gif',true); getAllFiles(MarkRealWorldSplices_First,'*.tif',true); getAllFiles(MarkRealWorldSplices_First,'*.bmp',true)];

for ii=1:length(List)
    if ~isempty(strfind(List{ii},'pakistan+hd+wallpapers'))
        k=ii
        break
    end
end

for ii=1:length(List)
    
    if mod(ii,15)==0
        disp(ii)
    end
    disp(ii);
    filename=List{ii}
    im = CleanUpImage(filename);
    
    if size(im,4)>1
        im=im(:,:,:,1);
    end
    
    dots=strfind(filename,'.');
    extension=filename(dots(end):end);
    
    if strcmpi(extension,'.gif')
        [im_gif,gif_map] =imread(filename);
        im_gif=im_gif(:,:,:,1);
        im=uint8(ind2rgb(im_gif,gif_map)*255);
    end
    
    if size(im,3)<3
        im(:,:,2)=im(:,:,1);
        im(:,:,3)=im(:,:,1);
    end
    
    findAberrations_Mark(filename,im)
    close all
end