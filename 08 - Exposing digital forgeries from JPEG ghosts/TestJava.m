ImageIn=imread('/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st Image Forensics Challenge/dataset-dist/phase-01/testing/0035f3252a470f2e34bb26f8c88b323b.png');
tmpIm=ImageIn;%(1:150,1:150,:);
BufIm=im2java(tmpIm);

Recompressor=JavaRecompressor(BufIm);
Recompressed=Recompressor.RecompressImage(java.lang.Double(51));

w=size(tmpIm,2);
h=size(tmpIm,1);
pixelsData = reshape(typecast(Recompressed.getData.getDataStorage, 'uint8'), 4, w, h);

imgData = cat(3, transpose(reshape(pixelsData(4, :, :), w, h)), transpose(reshape(pixelsData(3, :, :), w, h)), transpose(reshape(pixelsData(2, :, :), w, h)));

figure
subplot(1,2,1);
image(tmpIm);
subplot(1,2,2);
image(uint8(imgData));