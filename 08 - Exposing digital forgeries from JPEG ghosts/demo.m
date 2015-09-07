function demo( im )
    %DEMO Summary of this function goes here
    %   Detailed explanation goes here
    checkDisplacements=0;
    smoothFactor=1;
    [Results.OutputX, Results.OutputY, Results.dispImages, Results.imin, Results.Qualities, Results.Mins]=Ghost(im, checkDisplacements, smoothFactor);
    for ii=1:length(Results.dispImages);
        figure(ii)
        imagesc(Results.dispImages{ii});
        title(ii + (100-length(Results.dispImages)));
    end
end

