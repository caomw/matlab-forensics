function ToolboxExtract(FolderName)
close all
%clc

imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true')];

mkdir('../ToolboxResults/');
for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
   
    image = jpeg_read(filename);
    
    %figure;
    %image(imread(strcat(Path,'\',filename)));
    
    %figure;    
    %[ AllHists, p_h_avg, H_Out, s_0_Out, FFT_Out, p_h_fft, FFT_smoothed, dims, P_tampered] = Extract_Features;
    
    ncomp = 1;
    c1 = 1;
    c2 = 15;

    [maskTampered, q1table, alphatable] = getJmap(image,ncomp,c1,c2);
    
    map=imresize(maskTampered,[image.image_height image.image_width]);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);
    imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_02.tiff'],'TIFF');
end