function ToolboxExtract(FolderName)
close all

imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true');getAllFiles(FolderName,'*.tif','true'); getAllFiles(FolderName,'*.png','true');getAllFiles(FolderName,'*.gif','true'); getAllFiles(FolderName,'*.bmp','true')];
mkdir('../ToolboxResults/');
for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
    im = CleanUpImage(filename);
    toCrop=mod(size(im),2);
    im=im(1:end-toCrop(1),1:end-toCrop(2),:);
    [bayer, F1]=GetCFASimple(im);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);    
    
    [map, stat, loglikelihood_map] = CFAloc(im, bayer, 2,1);
    
    
    
    %values from ValueDistribution.mat. There's a problem with these
    %map=(map+1.7384)/(1.7613+1.7384);
    %map=imresize(map,[size(im,1) size(im,2)]);
    %map(map>1)=1;
    %map(map<0)=0;
    map=map-min(min(map));
    map=map/max(max(map));
    imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_04a.tiff'],'TIFF');
    
    [map, stat, loglikelihood_map] = CFAloc(im, bayer, 8,1);
    %values from ValueDistribution.mat
    %map=(map+11.1387)/(2.2616+11.1387);
    %map=imresize(map,[size(im,1) size(im,2)]);
    %map(map>1)=1;
    %map(map<0)=0;
    map=map-min(min(map));
    map=map/max(max(map));
    imwrite(map*64,jet,['../ToolboxResults/',pureFileName,'_04b.tiff'],'TIFF');

    
end