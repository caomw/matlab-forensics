function ToolboxExtract(FolderName)
close all
%clc

imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true')];

mkdir('../ToolboxResults/');
for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
   
    im = jpeg_read(filename);
    
    %figure;
    %image(imread(strcat(Path,'\',filename)));
    
    %figure;    
    %[ AllHists, p_h_avg, H_Out, s_0_Out, FFT_Out, p_h_fft, FFT_smoothed, dims, P_tampered] = Extract_Features;
    
    [Feature_Vector,map]=Extract_Features(im,0);
    map=imresize(map,[im.image_height im.image_width]);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);
    imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_01.tiff'],'TIFF');
end