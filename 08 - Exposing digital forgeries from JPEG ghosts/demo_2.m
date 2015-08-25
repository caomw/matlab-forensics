filename='3.Flag.jpg';

dots=strfind(filename,'.');
extension=filename(dots(end):end);

im = imread(filename);

if size(im,4)>1
    im=im(:,:,:,1);
end

if strcmpi(extension,'.gif') && size(im,3)<3
    [im_gif,gif_map] =imread(filename);
    im_gif=im_gif(:,:,:,1);
    im=uint8(ind2rgb(im_gif,gif_map)*255);
end

checkDisplacements=0;
smoothFactor=1;



[OutputX, OutputY, dispImages, imin, Qualities]=Ghost(im, checkDisplacements, smoothFactor);


NumSubIms=length(imin)+2; %+1 for the plot, +1 for orig
rowsSubIms=ceil(sqrt(NumSubIms));
colsSubIms=ceil(NumSubIms/rowsSubIms);


fig_handle=figure;
set(fig_handle, 'Position', [10, 10, 400*rowsSubIms, 400*colsSubIms]);

subplot(rowsSubIms,colsSubIms,1);
image(im);

subplot(rowsSubIms,colsSubIms,2);
plot(OutputX,OutputY)
axis([min(OutputX) max(OutputX) 0 max(OutputY)*1.1]);


for ii=1:length(imin)
    subplot(rowsSubIms,colsSubIms,ii+2);
    image(round(dispImages{imin(ii)}*63));
    title(Qualities(ii));
    %disp('--------------');
    
end

