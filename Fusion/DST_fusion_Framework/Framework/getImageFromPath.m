function [outlist] =getImageFromPath(directory)
   %This function creates a list of images in the directory. The supported
   %formats are TIFF and JPEG.
    outlist={};    
    
    img_list=dir(fullfile(directory,'*.jpeg')); 
    img_list1=dir(fullfile(directory,'*.jpg'));  
    img_list2=dir(fullfile(directory,'*.tif')); 
    files1 = {img_list1.name};
    files2 = {img_list2.name};
    files3 = {img_list.name};
    for j=1:length(files3)
        outlist = cat(1,outlist, fullfile(directory, char(files3(j))));            
    end
    for j=1:length(files2)
        outlist = cat(1,outlist, fullfile(directory, char(files2(j))));            
    end
    for j=1:length(files1)
        outlist = cat(1,outlist, fullfile(directory, char(files1(j))));            
    end
  
           
end