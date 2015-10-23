function [ mean dev_std ] = dev_std_and_mean( matrix )
%Calculate the std deviation and the mean value of the matrix.
    [row,col]=size(matrix);
    if(row~=col)
        mat=zeros(8,8);
        for i=1:row
            for j=1:col
                mat(i,j)=matrix(i,j);
            end
        end
        matrix=mat;
        [row,col]=size(matrix);
    end
    
    type_of_data=class(matrix);
    if(strcmp(type_of_data,'uint8')==1)
        mean=sum(sum(matrix))/(col*row);
        mean_value_matrix=uint8(mean.*ones(row));
    elseif(strcmp(type_of_data,'uint16')==1)
        mean=sum(sum(matrix))/(col*row);
        mean_value_matrix=uint16(mean.*ones(row));
    elseif(strcmp(type_of_data,'double')==1)
        mean=sum(sum(matrix))/(col*row);
        mean_value_matrix=double(mean.*ones(row));
    end
    dev_std=sqrt(sum(sum((mean_value_matrix-matrix).*((mean_value_matrix-matrix))))/(col*row));    
    dev_std=round(dev_std);
    mean=round(mean);
end



