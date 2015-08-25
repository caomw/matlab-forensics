%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function Name: 
%       medoutlierfilt
%
%   Abstract:
%       Remove outliers from a multivariate data set using the
%       median of each column.
%
%   Code downloaded from:
%       http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=12958&objectType=file
%
%   Inspired by quartile.m by Chris D. Larson
%   See also: BOXPLOT, QUARTILE 
%   Colin Clarke 2006
%   Cranfield Univeristy
%
%   Modified by:
%       Ido Yerushalmy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Parameters - 
%   x - Data set to work on. 
%   outlier_cut - A cut off which defines where to cut the outliers off the input data. 
%                                   It is a multiple of the inter quartile range above Q3 and
%                                   below Q1, default value is the same as  BOXPLOT function (1.5).
%   
%   Plot_state = 1 for on, 0 for off, DEFAULT = ON    
%
% Return Values -
%       filtered_data - the input data (x) without the detected outliers
%       outliers_indices - the indices in the LAST column of (x), of the
%                                                    detected outliers in that column
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [filtered_data outliers_indices] = medoutlierfilt(x,outlier_cut,plot_state)

    
%Set default values if the user did not define them explicitly
if (nargin < 3) || isempty(plot_state)
plot_state = 1; 
end
if (nargin < 2) || isempty(outlier_cut)
outlier_cut = 1.5; 
end
outliers_indices=[];

num_column = (min(size(x)));
num_outliers = zeros(1,1:num_column);

%create the output matrix
filtered_data = x;

% sort the data to be filtered 
[sorted_data, sort_index] = sort(filtered_data);

% remove outliers for each column
stats_data = zeros(5, num_column);
for i = 1:num_column
    
    current_column = sorted_data(:,i);
    current_sort_index = sort_index(:,i);
    
    % calculate the 25th percentile
    stats_data(1, i)  = median(current_column(current_column<median(current_column)));
    %if the median is 0, set the 25th percentile also to 0 
    if ( isnan(stats_data(1, i)) ) 
        stats_data(1, i) = 0; 
    end
    % calculate the 50th percentile
    stats_data(2,i)  = median(current_column);
    % calculate the 75th percentile
    stats_data(3,i)  = median(current_column(current_column>median(current_column)));
    % calculate the interquartile range of each column
    stats_data(4, i) =  stats_data(3, i) - stats_data(1, i);
    % calculate the semi interquartile range
    stats_data(5, i) =  stats_data(4, i)/2;
    
    
    
    % return the index of each outlier above and below Q1 and Q3 
    outliers_below = find(current_column<stats_data(1, i)-outlier_cut*stats_data(4, i));
    outliers_above = find(current_column>stats_data(3, i)+outlier_cut*stats_data(4, i));

    % find outlier values in the current column 
    if ~isempty(outliers_below),
        outliersQ1 = current_column(outliers_below); %#ok<FNDSB>
    else
        outliersQ1 = [];
    end
    
    
    
    
    if ~isempty(outliers_above),
        outliersQ3 = current_column(outliers_above);
    else
        outliersQ3 = [];
    end
    
    % determine the total number of outliers in the c
    num_outliers(:, i) =  (length(outliersQ1)+length(outliersQ3));
    
    
    %save the indices of the outliers in the last column of the UNSORTED input (x)
    outliers_indices = [current_sort_index(outliers_below) ; current_sort_index(outliers_above)];
    
    %Q1
    %find the outlier values and remove from the matrix
    if ~isempty(outliersQ1)
        for j = 1:length(outliersQ1)
            value = outliersQ1(j);
            index = find(filtered_data(:,i) == value);
            filtered_data(index,:) = []; %#ok<FNDSB>
        end
    end
   
    
    %Q3
    %find the outlier values above 75th quartile and remove from the matrix
    if ~isempty(outliersQ3)
        for j = 1:length(outliersQ3)
            value = outliersQ3(j);
            index = find(filtered_data(:,i) == value);
            filtered_data(index,:) = []; %#ok<FNDSB>
        end
    end
end



%display statistics for original data

if plot_state  == 1
    disp(['Column:                              ' num2str(1:num_column     , '%f\t')]);
    disp(['Mean:                                ' num2str(mean(x)          , '%f\t')]);
    disp(['SD:                                  ' num2str(std(x)           , '%f\t')]);
    disp(['Quartile1 (25th):                    ' num2str(stats_data(1,:)  , '%f\t')]);
    disp(['Quartile1 (50th):                    ' num2str(stats_data(2,:)  , '%f\t')]);
    disp(['Quartile1 (75th):                    ' num2str(stats_data(3,:)  , '%f\t')]);
    disp(['Inter quartile range:                ' num2str(stats_data(4,:)  , '%f\t')]);
    disp(['Semi Interquartile Deviation:        ' num2str(stats_data(5,:)  , '%f\t')]);
    disp(['Number of outliers :                 ' num2str((num_outliers)   , '%f\t')]);

    % boxplots to compare orignal and filtered data sets.
    figure;
    subplot(1, 2, 1)
    boxplot(x,'notch','on', 'whisker',outlier_cut)
    title('With outliers')
    subplot(1, 2, 2)
    boxplot(filtered_data,'notch','on', 'whisker',outlier_cut)
    title('Minus outliers')

end


