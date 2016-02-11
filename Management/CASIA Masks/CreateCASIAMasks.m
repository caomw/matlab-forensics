MatchesList='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/CASIA2/ImageMatches.TXT';

FID=fopen('CASIAMatchList1.txt','r');
C1 = textscan(FID,'%s','delimiter','\n');
fclose(FID);
C1=C1{1};

FID=fopen('CASIAMatchList2.txt','r');
C2 = textscan(FID,'%s','delimiter','\n');
fclose(FID);
C2=C2{1};




doubles=0;
Skipped_2_1=[];
Skipped_2_2=[];

for ii=1:length(C1)
    Names=strsplit(C1{ii},',');
    Names{2}=Names{2}(1:end-3);
    Orig=double(CleanUpImage(Names{1}));
    Spli=double(CleanUpImage(Names{2}));
    if sum(size(Spli)==size(Orig))==3
        diff=sum(abs(Orig-Spli),3);
        BinMask=diff>20;
        if mean(mean(BinMask))>0.5
            BinMask=~BinMask;
        end
        MaskName=strrep(Names{2},'Image Forensics/Datasets/','Image Forensics/Datasets/Masks/1');
        dots=strfind(MaskName,'.');
        strrep(MaskName,MaskName(dots:end),'.png');
        
        S=strel('disk',1);
        fixedMask=imopen(BinMask,S);
        S=strel('disk',5);
        fixedMask=imclose(fixedMask,S);
        
        if exist(MaskName,'file')
            doubles=doubles+1;
        end
        while exist(MaskName,'file')
            MaskName=[MaskName '_b.png'];
        end
        imwrite(fixedMask,MaskName);
        imwrite(BinMask,[strrep(MaskName,'/Tp/','/Tp/Un/')]);
    else
        Skipped_2_2=[Skipped_2_2;ii];
        disp(ii)
    end
    
    
    Names=strsplit(C2{ii},',');
    Orig=double(CleanUpImage(Names{1}));
    Names{2}=Names{2}(1:end-3);
    Spli=double(CleanUpImage(Names{2}));
    if sum(size(Spli)==size(Orig))==3
        diff=sum(abs(Orig-Spli),3);
        BinMask=diff>20;
        if mean(mean(BinMask))>0.5
            BinMask=~BinMask;
        end
        MaskName=strrep(Names{2},'Image Forensics/Datasets/','Image Forensics/Datasets/Masks/2');
        dots=strfind(MaskName,'.');
        strrep(MaskName,MaskName(dots:end),'.png');
        
        S=strel('disk',1);
        fixedMask=imopen(BinMask,S);
        S=strel('disk',5);
        fixedMask=imclose(fixedMask,S);
        
        if exist(MaskName,'file')
            doubles=doubles+1;
        end
        while exist(MaskName,'file')
            MaskName=[MaskName '_b.png'];
        end
        imwrite(fixedMask,MaskName);
        imwrite(BinMask,[strrep(MaskName,'/Tp/','/Tp/Un/')]);
    else
        Skipped_2_2=[Skipped_2_2;ii];
        disp(ii)
    end
end

disp(['Doubles found:' num2str(doubles)]);

