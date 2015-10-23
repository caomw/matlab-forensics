function [area complement_area doubt]=global_variable_module(map,threshold_map,threshold_area)
    %this function calculates the values of the global variables NJ or AJ. It
    %has two thresholds, one for the area and one for the map. It gives
    %back the value of the variable, its complement and the doubt.
    maps=1-map;
    maps=maps>threshold_map;
    area=sum(maps(:))/length(maps(:));
    complement_area=1-area;
    if(area>=threshold_area)
        area=1;
        complement_area=0;
    end
    doubt=0;
end