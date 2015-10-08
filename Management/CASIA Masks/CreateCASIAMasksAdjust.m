load('Skipped_FirstRun');

MatchesList='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/CASIA2/ImageMatches.TXT';

FID=fopen(MatchesList,'r');
C = textscan(FID,'%s','delimiter','\n');
fclose(FID);
C=C{1};



doubles=0;

S=strel('disk',1);
for ind=1:length(Skipped)
    ii=Skipped(ind);
    Names=strsplit(C{ii},',');
    Orig=double(CleanUpImage(Names{1}));
    Spli=double(CleanUpImage(Names{2}));
    
    Spli_Crop=Spli;
    Orig_Crop=Orig;
    SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
    SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
    
    for OffsetY=-30:1:30
        for OffsetX=-30:1:30
            if OffsetY>0 && OffsetX>0
                Spli_Crop=Spli;
                Orig_Crop=Orig(OffsetY:end,OffsetX:end,:);
            elseif OffsetY>0 && OffsetX==0
                Spli_Crop=Spli;
                Orig_Crop=Orig(OffsetY:end,:,:);
            elseif OffsetY>0 && OffsetX<0
                Spli_Crop=Spli(:,-OffsetX:end,:);
                Orig_Crop=Orig(OffsetY:end,:,:);
            elseif OffsetY==0 && OffsetX>0
                Spli_Crop=Spli;
                Orig_Crop=Orig(:,OffsetX:end,:);
            elseif OffsetY==0 && OffsetX==0
                Spli_Crop=Spli;
                Orig_Crop=Orig;
            elseif OffsetY==0 && OffsetX<0
                Spli_Crop=Spli(:,-OffsetX:end,:);
                Orig_Crop=Orig;
            elseif OffsetY<0 && OffsetX>0
                Spli_Crop=Spli(-OffsetY:end,:,:);
                Orig_Crop=Orig(:,OffsetX:end,:);
            elseif OffsetY<0 && OffsetX==0
                Spli_Crop=Spli(-OffsetY:end,:,:);
                Orig_Crop=Orig;
            elseif OffsetY<0 && OffsetX<0
                Spli_Crop=Spli(-OffsetY:end,-OffsetX:end,:);
                Orig_Crop=Orig;
            end
            SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
            SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
            Diff(OffsetY+31,OffsetX+31)=mean(mean(mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)))));
        end
        if mod(OffsetY,15)==0
            disp(OffsetY)
        end
    end
    [a,b]=min(Diff);
    [a2,b2]=min(a);
    OffsetY=b(b2)-31;
    OffsetX=b2-31;
    if OffsetY>0 && OffsetX>0
        Spli_Crop=Spli;
        Orig_Crop=Orig(OffsetY:end,OffsetX:end,:);
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
    elseif OffsetY>0 && OffsetX==0
        Spli_Crop=Spli;
        Orig_Crop=Orig(OffsetY:end,:,:);
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
    elseif OffsetY>0 && OffsetX<0
        Spli_Crop=Spli(:,-OffsetX:end,:);
        Orig_Crop=Orig(OffsetY:end,:,:);
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
        DiffMask=[zeros(size(DiffMask,1),-OffsetX) DiffMask];
    elseif OffsetY==0 && OffsetX>0
        Spli_Crop=Spli;
        Orig_Crop=Orig(:,OffsetX:end,:);
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
    elseif OffsetY==0 && OffsetX==0
        Spli_Crop=Spli;
        Orig_Crop=Orig;
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
    elseif OffsetY==0 && OffsetX<0
        Spli_Crop=Spli(:,-OffsetX:end,:);
        Orig_Crop=Orig;
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
        DiffMask=[zeros(size(DiffMask,1),-OffsetX) DiffMask];
    elseif OffsetY<0 && OffsetX>0
        Spli_Crop=Spli(-OffsetY:end,:,:);
        Orig_Crop=Orig(:,OffsetX:end,:);
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
        DiffMask=[zeros(-OffsetY,size(DiffMask,2)); DiffMask];
    elseif OffsetY<0 && OffsetX==0
        Spli_Crop=Spli(-OffsetY:end,:,:);
        Orig_Crop=Orig;
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
        DiffMask=[zeros(-OffsetY,size(DiffMask,2)); DiffMask];
    elseif OffsetY<0 && OffsetX<0
        Spli_Crop=Spli(-OffsetY:end,-OffsetX:end,:);
        Orig_Crop=Orig;
        SizeX=min(size(Orig_Crop,2),size(Spli_Crop,2));
        SizeY=min(size(Orig_Crop,1),size(Spli_Crop,1));
        DiffMask=mean(abs(Spli_Crop(1:SizeY,1:SizeX,:)-Orig_Crop(1:SizeY,1:SizeX,:)),3);
        DiffMask=[zeros(-OffsetY,size(DiffMask,2)); DiffMask];
        DiffMask=[zeros(size(DiffMask,1),-OffsetX) DiffMask];
    end
    DiffMask=[DiffMask;zeros(size(Spli,1)-size(DiffMask,1),size(DiffMask,2))];
    DiffMask=[DiffMask zeros(size(DiffMask,1),size(Spli,2)-size(DiffMask,2))];
    DiffMask=mean(DiffMask,3);
    
    BinMask=DiffMask>20;
    MaskName=strrep(Names{2},'ImageForensics/Datasets/','ImageForensics/Datasets/Masks/');
    dots=strfind(MaskName,'.');
    MaskName(dots:end)='.png';
    
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
    imwrite(BinMask,[MaskName 'un.png']);
    
end