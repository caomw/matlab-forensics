function fusion_framework(directory, result_path)
%This function generates the fusion map of the images in the directory. It
%applies the 3 localization algorithms, the filter, the BBA modules, the global variable step and the
%final fusion step.

    addpath(genpath('Framework'));
    addpath(genpath('Localization_algorithms'));
    addpath(genpath('utils'));    

    %size of the resolution block of the image    
    block_size=8;
    startx=1;
    starty=1;

    %variable necessary for the correct execution of the 3 algorithms
    Nb = 8;          
    Ns = 1;          
    Nm = 5;          

    Bayer_G = [0, 1;
               1, 0];

    c2Y = [1 3 6 10 15];
    filter_size=[3 3];
    number_of_dct_coeff=64;
    number_of_error=0;
    
    %value of the thresholds of the global variables
thresh_map_ajpeg=0.7;
thresh_map_najpeg=0.7;
thresh_map_cfa=0.7;
thresh_area_najpeg=0.125;
thresh_area_ajpeg=0.125;
thresh_area_cfa=0.125;

    %load the three data matrices
    load tables_fons.mat;
    %load the best parameters for the BBA modules
    load best_fusion_parameter.mat;
    %load the original and tampered variables for the fusion step
    load model.mat;

    load('SVM_fusion_struct.mat');

    if ismac
        addpath('/Users/marco/Documents/Librerie/libsvm-3.17/matlab');
    else
        addpath('/DATA/fontani/inst_libs/libsvm-314/matlab');
    end    
    
    %load all the images in the directory
    img_list=getImageFromPath(directory);
    
    for j=1:length(img_list)
        fprintf('Analyzing image %s %d/%d\n',char(img_list(j)),j,length(img_list));     
        image_info=imfinfo(char(img_list(j)));            
        img=imread(char(img_list(j)));
        %convert the image from RGB to YCbCr space
        img_gray=uint8(round(0.299*img(:,:,1) +  0.587*img(:,:,2) + 0.114*img(:,:,3)));

        %Apply the 3 localization algorithms
        if(strcmp(image_info.Format,'jpg')==1)
            %If the image is in the JPEG format, then analyse it with the
            %NAJPEG and AJPEG algorithms
            err_najpeg=0;
            err_ajpeg=0;
            imflow=jpeg_read(char(img_list(j)));            

            disp('Apply NAJPEG algorithm');                        
            try
                [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(imflow, 1, number_of_dct_coeff);
                najpeg_map = smooth_unshift(sum(LLRmap_s(:,:,1:length(c2Y)),3),k1e,k2e);
                najpeg_map=1./(1+exp(najpeg_map));
                %filtering of the map
                najpeg_map=medfilt2(najpeg_map,filter_size);
                %compute the global variable NJ (ATTENTION the variables (NT,NN,ND) refer to the tampered, 
                %original and doubt values of the global variable NJ)
                [NT NN ND]=global_variable_module(najpeg_map,thresh_map_najpeg,thresh_area_najpeg);
            catch err
                disp('err najpeg');
                err_najpeg=1;
                number_of_error=number_of_error+1;
                NT=0; NN=1; ND=0;
            end

            disp('Apply AJPEG algorithm');
            try
                [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(imflow, 1, number_of_dct_coeff);
                ajpeg_map = imfilter(sum(LLRmap_s(:,:,1:length(c2Y)),3), ones(3), 'symmetric', 'same');
                ajpeg_map=1./(1+exp(ajpeg_map));
                %filtering of the map
                ajpeg_map=medfilt2(ajpeg_map,filter_size);
                %compute the global variable AJ (ATTENTION the variables (AT,AN,AD) refer to the tampered, 
                %original and doubt values of the global variable AJ)
                [AT AN AD]=global_variable_module(ajpeg_map,thresh_map_ajpeg,thresh_area_ajpeg);
            catch err
                disp('err ajpeg');
                err_ajpeg=1;
                number_of_error=number_of_error+1;
                AT=0; AN=1; AD=0;
            end
            
            %find the value of the second compression
            q2=trovaQ(char(img_list(j)));

            %find the value of the first compression
            if(err_ajpeg~=1 || err_najpeg~=1)
                q1=find_Q_from_table(q1table);  
                q1=parse_q1(q1);
                q_gen=min([q1 q2]);
            else
                q_gen=q2;
            end
            
            %If q_gen is smaller than 90, do not use the map created from
            %the CFA algorithm.
            TAB_qf=(q_gen-90)/(100-90);
            if(TAB_qf<0)                
                TAB_qf=0;
            end
            TAB_not_qf=1-TAB_qf;

        else
            %If the image is in the TIFF format, fix the global variables
            %NJ and AJ at 0 and do not use the AJPEG and NAJPEG algorithms
            q1=0;
            q2=0;        
            TAB_qf=1;        
            TAB_not_qf=1-TAB_qf;
            NT=0; NN=1; ND=0;
            AT=0; AN=1; AD=0;
        end        

        disp('Apply CFA algorithm');
        try
            [h, w, dummy] = size(img);
            dim = [h, w];
            err_pred = predizione(img);
            mappa_varianza = variance_map_generation(err_pred(:,:,2), Bayer_G, dim);
            statistica = statistics_generation(mappa_varianza, Bayer_G, Nb);
            [mu, sigma, mix_perc] = MoG_parameters_estimation_ZM(statistica);
            likelihood_map = verosimiglianza_ZM(statistica, mu, sigma);
            BPPMfilt_median = mappe_cumulate_median(likelihood_map, Ns, Nm);                                                            
            cfa_map = BPPMfilt_median;
            %filtering of the map
            cfa_map=medfilt2(cfa_map,filter_size);
            cfa_map = 1./(1+cfa_map);
        catch err
            cfa_map=ones(size(ajpeg_map,1),size(ajpeg_map,2))*0.5;
        end

        [fp, fn, ext] = fileparts(img_list{j});
        save(fullfile(result_path,[fn '_algs_outputs.mat']),'najpeg_map','NT','NN','ND','ajpeg_map','AT','AN','AD','cfa_map','q1','q2');
        
        [row col]=size(cfa_map);
        %transform the variables into matrices to use the element sum, multiplication and division for the fusion step 
        alT=zeros(row,col); alN=alT; alD=alT;
        cT=alT; cN=alT; cD=alT;
        naT=alT; naN=alT; naD=alT;
        dvi = 1;
        for y=1:row        
            for z=1:col
                try
                    %extract the information from the 8x8 block of the Y
                    %image
                    data=img_gray(startx+(block_size*(y-1)):block_size+(block_size*(y-1)),starty+(block_size*(z-1)):block_size+(block_size*(z-1)));
                catch err
                    data=zeros(8,8);
                end

                %If the image is in the JPEG format, then analyse it with the
                %NAJPEG BBA, AJPEG BBA and CFA modules
                if(strcmp(image_info.Format,'jpg')==1)
                    
                    %create the three feature vectors
                    [data_vector_cfa data_vector_ajpeg data_vector_najpeg ] = create_vectors( data,q1,q2,cfa_map(y,z),ajpeg_map(y,z),najpeg_map(y,z),0);
                    data_vector_ajpeg=normalize_matrix(data_vector_ajpeg);
                    data_vector_najpeg=normalize_matrix(data_vector_najpeg);
                    data_vector_cfa=normalize_matrix(data_vector_cfa);                
                    
                    %remove the q1 feature for the AJPEG and NAJPEG
                    %algorithms
                    data_vector_ajpeg=data_vector_ajpeg(2:end);
                    data_vector_najpeg=data_vector_najpeg(2:end);                
                    
                    %If q_gen is bigger than 90, execute the BBA CFA
                    if(TAB_qf>0)
                        [cT(y,z) cN(y,z) cD(y,z)] = BBA_module(cfa_tables(:,1:5),cfa_tables(:,6:6),data_vector_cfa(1:5),bestNN_cfa,best_gamma_cfa,best_alpha_cfa);
                    else
                        cT(y,z)=0; cN(y,z)=1; cD(y,z)=0;
                    end
                    
                    %execute the BBA AJPEG
                    if(err_ajpeg~=1)
                        [alT(y,z) alN(y,z) alD(y,z)] = BBA_module(ajpeg_tables(:,1:4), ajpeg_tables(:,5:5), data_vector_ajpeg(1:4), bestNN_a,best_gamma_a,best_alpha_a);                      
                    else
                        alT(y,z) = 0; alN(y,z) = 0; alD(y,z) = 1;
                    end

                    %execute the BBA NAJPEG
                    if(err_najpeg~=1)
                        [naT(y,z) naN(y,z) naD(y,z)] = BBA_module(najpeg_tables(:,1:4), najpeg_tables(:,5:5), data_vector_najpeg(1:4), bestNN_na,best_gamma_na,best_alpha_na);                      
                    else
                        naT(y,z) = 0; naN(y,z) = 0; naD(y,z) = 1;
                    end

                    % SVM-PART
                    data_vector_svm{dvi} = create_vectors_svm( data,q1,q2,cfa_map(y,z),ajpeg_map(y,z),najpeg_map(y,z),0);
                    dvi=dvi+1;
                else
                    %If the image is in the TIFF format, then analyse it
                    %only with the CFA module
                    [data_vector_cfa data_vector_ajpeg data_vector_najpeg ] = create_vectors( data,q1,q2,cfa_map(y,z),0,0,0);
                    data_vector_cfa=normalize_matrix(data_vector_cfa);   
                    [cN(y,z) cT(y,z) cD(y,z)] = BBA_module(cfa_tables(:,1:5),cfa_tables(:,6:6),data_vector_cfa(1:5),bestNN_cfa,best_gamma_cfa,best_alpha_cfa);
                end
            end
        end
        
        %Trasform the global variables into matrices
        NT=NT*ones(row,col); NN=NN*ones(row,col); ND=zeros(row,col);
        AT=AT*ones(row,col); AN=AN*ones(row,col); AD=zeros(row,col);

        %Evaluate the tampered and the original propositions for the fusion.
        BelT = eval(tampered);
        BelN = eval(original);
        
        %If the format is JPEG, use the BelT map
        if(strcmp(image_info.Format,'jpg')==1)
            belt_map=BelT;
            beln_map=BelN;
        else
            %If the format is TIFF, use only the CFA map
            belt_map=cT;
            beln_map=cN;
        end
%        hh=imagesc(belt_map,[0,1]);
%        saveas(hh, [char(img_list(j)) '.fig'], 'fig'); 
%        close all;
%        save([char(img_list(j)) '.mat'],'belt_map','ajpeg_map','najpeg_map','cfa_map');
        [fp, fn, ext] = fileparts(img_list{j});
        dst_fused_map = belt_map; 
        save(fullfile(result_path,[fn '_DST_fused_map.mat']),'dst_fused_map');

        % SVM-PART
%         img_data_features=cell2mat(data_vector_svm');
%         img_data_features=img_data_features(:,1:end-1); %do not put the ground truth for classification.
%         [predicted_label, dummy, prob_estimates] = svmpredict(zeros(size(img_data_features,1),1), img_data_features, trainedSVM, '-b 1');
%         svm_fused_map = reshape(prob_estimates(:,1),row,col);        
%         save(fullfile(result_path,[fn '_SVM_fused_map.mat']),'svm_fused_map');        
        
        
    end    



end
