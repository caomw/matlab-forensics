load('../Datasets.mat');

List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true)];
for ii=1:length(List)
    filename=List{ii};
    try
        % im = jpeg_read(filename);
    catch err
        disp(err.message)
        disp(filename)
    end
end


List=[getAllFiles(MarkRealWorldSplices_Third,'*.jpg',true); getAllFiles(MarkRealWorldSplices_Third,'*.jpeg',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.png',true); getAllFiles(MarkRealWorldSplices_Third,'*.gif',true); getAllFiles(MarkRealWorldSplices_Third,'*.tif',true); getAllFiles(MarkRealWorldSplices_Third,'*.bmp',true)];
for ii=1:length(List)
    try
        filename=List{ii};
        %im = imread(filename);
        dots=strfind(filename,'.');
        OutFilename=[filename(1:dots(end)-1) '_test.tiff'];
        %imwrite(im,OutFilename);
    catch err
        disp(err.message)
        disp(filename)
    end
end

List=[getAllFiles(MarkRealWorldSplices_Third,'*.gif',true);];
for ii=1:length(List)
    try
        filename=List{ii};
        im = imread(filename);
        [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
    catch err
        disp(err.message)
        disp(filename)
    end
end

