load('../Datasets.mat');

% set parameters
checkDisplacements=0;
smoothFactor=1;


MarkRealWorldSplices_Third='D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\CompareOriginals';

List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.png',true); getAllFiles(MarkRealWorldSplices_Third,'*.gif',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.bmp',true)];

%temp
MarkRealWorldSplices_Third='D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Extended and Refined Search\BeirutSmoke';
List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.png',true); getAllFiles(MarkRealWorldSplices_Third,'*.gif',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.bmp',true)];



k=colormap;


for ii=154:length(List)
    
    if mod(ii,15)==0
        disp(ii)
    end
    filename=List{ii}
    im = imread(filename);
    
    if size(im,4)>1
        im=im(:,:,:,1);
    end
    
    dots=strfind(filename,'.');
    extension=filename(dots(end):end);
    
    if strcmpi(extension,'.gif') && size(im,3)<3
        [im_gif,gif_map] =imread(filename);
        im_gif=im_gif(:,:,:,1);
        im=uint8(ind2rgb(im_gif,gif_map)*255);
    end
    
    [OutputX, OutputY, dispImages, imin, Qualities]=Ghost(im, checkDisplacements, smoothFactor );
    
    
    NumSubIms=length(imin)+2; %+1 for the plot, +1 for orig
    rowsSubIms=ceil(sqrt(NumSubIms));
    colsSubIms=ceil(NumSubIms/rowsSubIms);
    
    
    fig_handle=figure;
    set(fig_handle, 'Position', [50, 50, 400*rowsSubIms, 400*colsSubIms]);
    
    subplot(rowsSubIms,colsSubIms,1);
    image(im);
    
    subplot(rowsSubIms,colsSubIms,2);
    plot(OutputX,OutputY)
    axis([min(OutputX) max(OutputX) 0 max(OutputY)*1.1]);
    
    for ii=1:length(imin)
        subplot(rowsSubIms,colsSubIms,ii+2);
        imagesc(dispImages{imin(ii)});
        title(Qualities(ii));
    end
    
    dots=strfind(filename,'.');
    slashes=strfind(filename,'\');
    OutFilename=['RealWorldOutput\' filename(slashes(end)+1:dots(end)-1) '_Ghost'];
    if exist(OutFilename,'file')==2
        OutFilename=[OutFilename '_~'];
    end
    OutFilename=[OutFilename '.tiff'];
    
    export_fig(OutFilename);
    
    close all
end