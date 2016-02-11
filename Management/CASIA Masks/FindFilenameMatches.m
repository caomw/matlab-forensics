AuPath='/media/marzampoglou/3TB B/Image Forensics/Datasets/CASIA2/Au/';
SpPath='/media/marzampoglou/3TB B/Image Forensics/Datasets/CASIA2/Tp/';

SpliceList=dir(SpPath);
SpliceList=SpliceList(3:end);

F1=fopen('CASIAMatchList1.txt','w');
F2=fopen('CASIAMatchList2.txt','w');

for ii=1:length(SpliceList)
    C = textscan(SpliceList(ii).name,'%s','delimiter','_');
    C=C{1};
    Source1Str=C{6};
    Source2Str=C{7};
    SourceFileName1=['Au_' Source1Str(1:3) '_' Source1Str(4:8)];
    RealSourceFile1=dir([AuPath SourceFileName1 '.*']);
    RealSourceFileName1=RealSourceFile1.name;
    SourceFileName2=['Au_' Source2Str(1:3) '_' Source2Str(4:8)];
    RealSourceFile2=dir([AuPath SourceFileName2 '.*']);
    RealSourceFileName2=RealSourceFile2.name;
    %Splice=imread([SpPath SpliceList(ii).name]);
    %Source1=imread([AuPath RealSourceFileName1]);
    %Source2=imread([AuPath RealSourceFileName2]);
    String1=[AuPath RealSourceFileName1 ',' SpPath SpliceList(ii).name ' 99\n'];
    String2=[AuPath RealSourceFileName2 ',' SpPath SpliceList(ii).name ' 99\n'];
    fprintf(F1,String1);
    fprintf(F2,String2);
end

fclose(F1);
fclose(F2);