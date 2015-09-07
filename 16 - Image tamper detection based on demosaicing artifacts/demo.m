function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    Result=CFATamperDetection_Both(im);
    figure;
    imagesc(Result.F1Map);
    figure;
    imagesc(Result.F2Map);
end

