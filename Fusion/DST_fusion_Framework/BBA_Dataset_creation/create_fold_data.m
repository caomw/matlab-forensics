function create_fold_data(type,q2,path_to_data,path_to_photo,string_qualities,nfold,test_size,tamp_size,number_of_blocks,skip_samples)
%This function creates the nfold data matrices and saves them in the DATA
%directory of each algorithm. The data are divided according to the quality factor
%q2.

    % define the mask for tampering (tamp_size)
    mask = false([test_size 3]);
    pt1 = floor((test_size - tamp_size)) + 1;
    pt2 = pt1 + tamp_size - 1;
    mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
    mask = ~mask;
    mask_block = filter2(ones(8), mask(:,:,1), 'valid');
    mask_block  = mask_block(1:8:end, 1:8:end) > 32;

    block_size=8;
    startx=1;
    starty=1;

    load([path_to_data,char(string_qualities),'fold1.mat']);    
    [dummy tmp number_of_elements_per_fold]=size(fold_matrix);
    
    %Definition of the data structure
    %column 1 Q1, column 2 Q2, column 3 mean value, column 4 std deviation, column 5 localization map value, column
    %6 label (1-tamper 0-no tamper)
    data_array=zeros(number_of_elements_per_fold*(number_of_blocks/skip_samples)*(number_of_blocks/skip_samples),6);

    index=1;
    index2=1;

    filename=fopen([path_to_data,char(string_qualities),'namefold',num2str(nfold),'.txt'],'r');
    load([path_to_data,char(string_qualities),'fold',num2str(nfold),'.mat']);    
    fold=fold_matrix;
    for k=1:number_of_elements_per_fold
        name=fscanf(filename,'%s',1);
        fprintf('Analyze the image %d / %d in fold %d\n',index2,number_of_elements_per_fold,nfold);
        img=imread([path_to_photo,char(string_qualities),name]);        
        parts = regexp(name,'_','split');
        cmp=0;
        while(isempty(str2num(char(parts(3+cmp)))))
            cmp=cmp+1;
        end        
        q1=str2num(char(parts(3+cmp)));                
        
        %Conversion from RGB to YCbCR
        img_gray=uint8(round(0.299*img(:,:,1) +  0.587*img(:,:,2) + 0.114*img(:,:,3)));
        for y=1:skip_samples:number_of_blocks
            for z=1:skip_samples:number_of_blocks
                data=img_gray(startx+(block_size*(z-1)):block_size+(block_size*(z-1)),starty+(block_size*(y-1)):block_size+(block_size*(y-1)));
                [ mean dev_std ] = dev_std_and_mean( data );    
                data_array(index,1)=q1;
                data_array(index,2)=q2;    
                data_array(index,3)=mean;
                data_array(index,4)=dev_std;
                data_array(index,5)=fold(y,z,k); 
                if(mask_block(1+(y-1),1+(z-1))==0)
                    data_array(index,6)=1;              
                else
                    data_array(index,6)=0;              
                end    
                index=index+1;
            end
        end
        index2=index2+1;
    end
    fclose(filename);

    save([path_to_data 'data_array_' type '_' num2str(q2) '_nfold_' num2str(nfold) '.mat'],'data_array');
    clear data_array;
end