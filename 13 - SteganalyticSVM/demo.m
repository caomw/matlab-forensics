disp('Open questions:');
disp('How to convert to grayscale?');
disp('Is the proposed filter optimal?');

close all;
clear all;

im=imread('/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/Datasets/ForDNN/1stChallengeTrain/128_16/fake/0908dafde12041540b70d688315df6e9/Sp/31.png');

Trunc=ExtractDescriptor(im);
%imagesc(Trunc);