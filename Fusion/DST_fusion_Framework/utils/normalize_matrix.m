function [ normalize_matrix ] = normalize_matrix( matrix )
%This function normalizes the values of the data in the [0,1] interval.
    
    q2_max_value=100;
    q2_min_value=0;
    q1_max_value=100;
    q1_min_value=0;
    mean_max_value=255;
    mean_min_value=0;
    dev_std_max_value=128;
    dev_std_min_value=0;

    matrix(:,1)=(matrix(:,1)-q1_min_value)./(q1_max_value-q1_min_value);
    matrix(:,2)=(matrix(:,2)-q2_min_value)./(q2_max_value-q2_min_value);
    matrix(:,3)=(matrix(:,3)-mean_min_value)./(mean_max_value-mean_min_value);
    matrix(:,4)=(matrix(:,4)-dev_std_min_value)./(dev_std_max_value-dev_std_min_value);

    
    normalize_matrix=matrix;

end

