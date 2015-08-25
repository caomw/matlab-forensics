%  QualityFactor = 100;
clear, clc;
disp('QF = 100');
QFactor = 100;
mpnc = 0.022;
numT = 5;
oriDir = 'D:\paperUSA\doubleJPEG\pic\UCID_Jpg100\';         %standard single JPEG compressed image using imwrite function of  Matlab
doubleDir = 'D:\paperUSA\doubleJPEG\pic\UCID_reCompress_100\'; %standard double JPEG compressed image using imread and then imwrite function of  Matlab
tripleDir = 'D:\paperUSA\doubleJPEG\pic\UCID_reCompress_100100\'; %standard triple JPEG compressed image using imread and then imwrite function of  Matlab

JpgFilelist=dir([oriDir, '*.jpg']);
ListLen = length(JpgFilelist);

results = zeros(ListLen,4);

tic
for i=1:ListLen
    img = [oriDir JpgFilelist(i).name];
    a = jpeg_read(img);
    img = [doubleDir JpgFilelist(i).name];    
    b = jpeg_read(img);
    img = [tripleDir JpgFilelist(i).name]; 
    c = jpeg_read(img);
    
    d = a.coef_arrays{1} - b.coef_arrays{1};  
    results(i,1) = sum(sum(d~=0));
    d = b.coef_arrays{1} - c.coef_arrays{1};  
    results(i,3) = sum(sum(d~=0));
end
toc

tic
results(:,2) = ReEmbed(QFactor,mpnc,doubleDir,JpgFilelist,ListLen,numT);
results(:,4) = ReEmbed(QFactor,mpnc,tripleDir,JpgFilelist,ListLen,numT);
toc
    
TN = sum((results(:,1)-results(:,2))>0)/ListLen
TP = sum((results(:,3)-results(:,4))<=0)/ListLen
AR = (TN+TP)/2



