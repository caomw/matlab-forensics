function ToolboxExtract(FolderName)
close all

imList=[getAllFiles(FolderName,'*.jpg','true'); getAllFiles(FolderName,'*.jpeg','true')];

mkdir('../ToolboxResults/');

c2 = 6;

for ii=1:length(imList)
    filename=imList{ii}; %= 'C1.jpg'; % 'garden-tampered.jpg'; %'Ct.jpg'
    im = jpeg_read(filename);
    slashes=strfind(filename,'/');
    pureFileName=filename(slashes(end)+1:end);    

    
    [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2);
    %LLRmap=(LLRmap+173.1076)/(173.1076+50.6924);
    %map_final_A = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    %map_final_A=imresize(map_final_A,[im.image_height im.image_width]);
    %map_final_A(map_final_A>1)=1;
    %map_final_A(map_final_A<0)=0;
    LLRmap=sum(LLRmap,3);
    map_final_A=LLRmap-min(min(LLRmap));
    map_final_A=imresize(map_final_A,[im.image_height im.image_width]);
    map_final_A=map_final_A/max(max(map_final_A));
    
    imwrite(map_final_A*64,jet,['../ToolboxResults/',pureFileName,'_05a.tiff'],'TIFF');    
    


    [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2);
    LLRmap=sum(LLRmap,3);
    %LLRmap=(LLRmap+96.6285)/(96.6285+7.2715);
    %map_final = smooth_unshift(sum(LLRmap,3),k1e,k2e);
    %map_final=imresize(map_final,[im.image_height im.image_width]);
    %map_final(map_final>1)=1;
    %map_final(map_final<0)=0;
    map_final=LLRmap-min(min(LLRmap));
    map_final=imresize(map_final,[im.image_height im.image_width]);
    map_final=map_final/max(max(map_final));
    
    imwrite(map_final*64,jet,['../ToolboxResults/',pureFileName,'_05b.tiff'],'TIFF');    
end