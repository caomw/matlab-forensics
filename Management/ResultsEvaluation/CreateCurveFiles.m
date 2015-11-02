clear all;
DatasetNames={'VIPP2';'CARV';'COLUMB';'CHAL';'FON_REAL';'FON_SYN'}

for Dataset=2:6
    CurveFiles=dir('CompactReport*.mat');
    if Dataset~=5 && Dataset~=6
        JPEGIndex=[8 1 5 7 10];
    else
        JPEGIndex=[8 1 2 4 5 7 10];
    end
    
    NoiIndex=[3 11 12 6 9];
    
    
    AlgName=1;
    for ii=JPEGIndex
        load(CurveFiles(ii).name);
        Curve=Report.CompactCurves{1,Dataset}.KSPositives{1,1};
        Curves.JPEG.(['a' num2str(AlgName)]).Au=Curve(2,:);
        Curves.JPEG.(['a' num2str(AlgName)]).Sp=Curve(3,:);
        AlgName=AlgName+1;
    end
    
    AlgName=1;
    for ii=NoiIndex
        load(CurveFiles(ii).name);
        Curve=Report.CompactCurves{1,Dataset}.KSPositives{1,1};
        Curves.NOI.(['a' num2str(AlgName)]).Au=Curve(2,:);
        Curves.NOI.(['a' num2str(AlgName)]).Sp=Curve(3,:);
        AlgName=AlgName+1;
    end
    
    save([DatasetNames{Dataset} 'MATCurves.mat'],'Curves');
    clear Curves;
end