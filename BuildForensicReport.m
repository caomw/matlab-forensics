function Report = BuildForensicReport( im, im_jpg )
    %BUILDFORENSICREPORT Summary of this function goes here
    %   Detailed explanation goes here
    cd('./01 - Fast, automatic and fine-grained tampered JPEG image detection via DCT coefficient analysis/');
    [~, Report.F01_Raw] = Extract_Features( im );
    [~, Report.F01_JPEG] = Extract_Features( im_jpg );
    cd('../02 - Improved DCT Coefficient Analysis for Forgery Localization in JPEG Images/');
    Report.F02 = getJmap(im_jpg,1,1,15);
    cd('../04 - Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts/')
    toCrop=mod(size(im),2);
    imC=im(1:end-toCrop(1),1:end-toCrop(2),:);
    [bayer, F1]=GetCFASimple(imC);
    Report.F04_2 = CFAloc(imC, bayer, 2,1);
    Report.F04_8 = CFAloc(imC, bayer, 8,1);
    cd('../05 - Image Forgery Localization via Block-Grained Analysis of JPEG Artifacts/')
    LLRmap = getJmap_EM(im_jpg, 1, 6);
    Report.F05A = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    [LLRmap, ~, ~, k1e, k2e] = getJmapNA_EM(im_jpg, 1, 6);
    Report.F05NA = smooth_unshift(sum(LLRmap,3),k1e,k2e);
    cd('../07 - Using noise inconsistencies for blind image forensics/');
    Report.F07 = GetNoiseMap(im, 8);    
    cd('../08 - Exposing digital forgeries from JPEG ghosts/');
    [~, ~, Report.F08Images, Report.F08MinLocations]=Ghost(im, false, 1);
    cd('../09 - Digital image forgery detection based on lens and sensor aberration/');
    [~, Report.F09]=findAberrations_compact(im);
    cd('../10 - Mine - Detecting digital image forgeries by measuring inconsistencies of blocking artifact/');
    Report.F10=GetBlockArtifact(im);
    cd('../12 - Kurtosis - Exposing Region Splicing Forgeries with Blind Local Noise Estimation/')
    [Report.F12VDCT, Report.F12Haar, Report.F12Rand] = GetKurtNoiseMaps(im);
    cd('../14 - Passive detection of doctored JPEG image via block artifact grid extraction/')
    Report.F14=GetBlockGrid(im);
    cd('../16 - Image tamper detection based on demosaicing artifacts/');
    Result=CFATamperDetection_Both(im);
    Report.F16F1=Result.F1Map;
    Report.F16F2=Result.F2Map;
    cd('..');
end