function demo(im)
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    
    [OutlierPrmsMap, OutlierPrmsMap_filtered, OutlierErrMap, OutlierErrMap_filtered, OutputStatistics]=findAberrations_compact(im);
    imagesc(OutlierPrmsMap_filtered)
end

