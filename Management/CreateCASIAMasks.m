MatchesList='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/CASIA2/ImageMatches.TXT';

FID=fopen(MatchesList,'r');
C = textscan(FID,'%s','delimiter','\n');
fclose(FID);
C=C{1};



S=strel('disk',1);
for ii=1:length(C)
    Names=strsplit(C{ii},',');
    Orig=double(CleanUpImage(Names{1}));
    Spli=double(CleanUpImage(Names{2}));
    if sum(size(Spli)==size(Orig))==3
        diff=sum(abs(Orig-Spli),3);
        BinMask=diff>20;
        MaskName=strrep(Names{2},'ImageForensics/Datasets/','ImageForensics/Datasets/Masks/');
        dots=strfind(MaskName,'.');
        MaskName(dots:end)='.png';
        
        S=strel('disk',1);
        fixedMask=imopen(BinMask,S);
        S=strel('disk',5);
        fixedMask=imclose(fixedMask,S);
        imwrite(fixedMask,MaskName);
        imwrite(BinMask,[MaskName 'un.png']);
        
        %pause
    else
        disp(ii)
    end
end

