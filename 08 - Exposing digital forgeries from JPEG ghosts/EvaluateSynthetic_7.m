load('../Datasets.mat');

% set parameters
checkDisplacements=0;
smoothFactor=1;


%MarkRealWorldSplices_Third='D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\CompareOriginals';

List=[];
for DataPath={CASIA2.au, CASIA2.tp, ColumbiaImage.au, ColumbiaImage.sp, ColumbiauUncomp.au, ColumbiauUncomp.sp, UCID.au, VIPPDempSchaReal.sp, VIPPDempSchaReal.au, VIPPDempSchaSynth.au, VIPPDempSchaSynth.sp}
    List=[List;getAllFiles(DataPath{1},'*.jpg',true); getAllFiles(DataPath{1},'*.jpeg',true); getAllFiles(DataPath{1},'*.tif',true); getAllFiles(DataPath{1},'*.png',true); getAllFiles(DataPath{1},'*.gif',true); getAllFiles(DataPath{1},'*.tif',true); getAllFiles(DataPath{1},'*.bmp',true)];
end


k=colormap;

for ii=9930:length(List)
    
    if mod(ii,15)==0
        disp(ii)
    end
    filename=List{ii};
    im = imread(filename);
    
    if size(im,4)>1
        im=im(:,:,:,1);
    end
    
    
    if size(im,3)>3
        im=im(:,:,1:3);
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
    OutFilename=[filename(1:dots(end)-1) '_Ghost'];
    OutFilename=[OutFilename '.tiff'];
    OutFilename=strrep(OutFilename, 'D:\markzampoglou\ImageForensics\Datasets\', 'D:\markzampoglou\ImageForensics\Datasets\SyntheticEvaluations\SynthGhosts\');
    % if exist(OutFilename,'file')==2
    %OutFilename=[OutFilename '_~']
    %end
    
    
    export_fig(OutFilename);
    
    close all
end