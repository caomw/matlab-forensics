function ToolboxExtract(FolderName)
close all
BlockSize=8;
imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true');getAllFiles(FolderName,'*.tif','true'); getAllFiles(FolderName,'*.png','true');getAllFiles(FolderName,'*.gif','true'); getAllFiles(FolderName,'*.bmp','true')];

mkdir('../ToolboxResults/');

for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
    im = CleanUpImage(filename);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);    

    map = GetNoiseMap(im, BlockSize);
    
    map=map-min(min(map));
    map=imresize(map,[size(map,1) size(map,2)]);
    map=map/max(max(map));
    
    imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_07.tiff'],'TIFF');    
    
end