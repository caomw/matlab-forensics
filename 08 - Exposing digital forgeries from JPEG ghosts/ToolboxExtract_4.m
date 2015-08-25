function ToolboxExtract(FolderName)
close all
BlockSize=8;
imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true');getAllFiles(FolderName,'*.tif','true'); getAllFiles(FolderName,'*.png','true');getAllFiles(FolderName,'*.gif','true'); getAllFiles(FolderName,'*.bmp','true')];
checkDisplacements=0;
smoothFactor=1;


mkdir('../ToolboxResults/');

for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
    im = CleanUpImage(filename);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);    

    [OutputX, OutputY, dispImages, imin, Qualities]=Ghost(im, checkDisplacements, smoothFactor );
    
    NumSubIms=length(imin)+2; %+1 for the plot, +1 for orig
    rowsSubIms=ceil(sqrt(NumSubIms));
    colsSubIms=ceil(NumSubIms/rowsSubIms);
    
    fig_handle=figure(1);
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

    
    %pause;
    
    print(['../ToolboxResults/',[pureFileName '_08'],'-png']);
    
    %imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_08.tiff'],'TIFF');    
    
end