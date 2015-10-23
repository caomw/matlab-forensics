function guided_filter_module(directory, r, eps)


addpath(genpath('guided-filter'));

imges = dir( [directory '*.tif*.mat*']);
img_list = {imges.name};

destpath = 'Images Guided Filtered/';


for i=1:numel(img_list)
   clear( 'belt_map','ajpeg_map','najpeg_map','cfa_map' );
%      fprintf('loading %s \n', char(img_list(i)));
    [pathstr nameimg ext] = fileparts(char(img_list(i)));
    img=imread([directory nameimg]);
    img = double(rgb2gray(img(:,:,1:3)));

    matfile = [directory char(img_list(i))];
%     fprintf('loading %s \n', matfile);    
    load(matfile);
    
    exp_map = expand_map( belt_map );
    [h w] = size(exp_map);
    img = img(1:h, 1:w); 
    
filteredT = guidedfilter( img, exp_map, r, eps);

mkdir([destpath num2str(r) '/' num2str(eps) '/tamper_images/']);

save([destpath num2str(r) '/' num2str(eps) '/tamper_images/' nameimg '.mat'], 'filteredT');

end

end
