function fusion_framework_DST_SUM_PROD(directory, resultspath)
%This function generates the fusion map of the images in the directory. It
%applies the 3 localization algorithms, the filter, the BBA modules, the global variable step and the
%final fusion step.

addpath(genpath('Framework'));
addpath(genpath('Localization_algorithms'));
addpath(genpath('utils'));
addpath(genpath('guided-filter'));

mkdir( resultspath );

%size of the resolution block of the image
block_size=8;
startx=1;
starty=1;

ajpegdir='AJPEG/';
najpegdir='NAJPEG/';
cfadir='CFA/';
anajpeg = 'A_NA/';

tamp_types = {ajpegdir, najpegdir, cfadir, anajpeg};

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
thresh_area_najpeg=0.125;
thresh_area_ajpeg=0.125;

%load the three data matrices
load tables.mat;
%load the best parameters for the BBA modules
load best_fusion_parameter.mat;
%load the original and tampered variables for the fusion step
load model_fons.mat;

%load all the images in the directory
%img_list=getImageFromPath(directory);

row = 1024/8;
col = 1024/8;


for i = 1:numel(tamp_types)
    
    imgpath = [directory char(tamp_types{i})];
    
    filelist = dir( [imgpath '*_outputs.*'] );
    list = {filelist.name};
    
    for j=1:length(list)
        
        load( [ imgpath '/' char(list(j)) ] );
        
%         [row col]=size(cfa_map);
        %transform the variables into matrices to use the element sum, multiplication and division for the fusion step
        alT=zeros(row,col); alN=alT; alD=alT;
        cfaT=alT; cN=alT; cD=alT;
        naT=alT; naN=alT; naD=alT;
        
%         for y=1:row
%             for z=1:col
%                 try
%                     %extract the information from the 8x8 block of the Y
%                     %image
%                     data=img_gray(startx+(block_size*(y-1)):block_size+(block_size*(y-1)),starty+(block_size*(z-1)):block_size+(block_size*(z-1)));
%                 catch err
%                     data=zeros(8,8);
%                 end
%                 
%                 %If the image is in the JPEG format, then analyse it with the
%                 %NAJPEG BBA, AJPEG BBA and CFA modules
% %                 if(strcmp(image_info.Format,'jpg')==1)
%                     
%                     %create the three feature vectors
%                     [data_vector_cfa data_vector_ajpeg data_vector_najpeg ] = create_vectors( data,q1,q2,cfa_map(y,z),ajpeg_map(y,z),najpeg_map(y,z),0);
%                     data_vector_ajpeg=normalize_matrix(data_vector_ajpeg);
%                     data_vector_najpeg=normalize_matrix(data_vector_najpeg);
%                     data_vector_cfa=normalize_matrix(data_vector_cfa);
%                     
%                     %remove the q1 feature for the AJPEG and NAJPEG
%                     %algorithms
%                     data_vector_ajpeg=data_vector_ajpeg(2:end);
%                     data_vector_najpeg=data_vector_najpeg(2:end);
%                     
%                     %If q_gen is bigger than 90, execute the BBA CFA
%                     %                     if(TAB_qf>0)
%                     [cfaT(y,z) cfaN(y,z) cfaD(y,z)] = BBA_module(cfa_tables(:,1:5),cfa_tables(:,6:6),data_vector_cfa(1:5),bestNN_cfa,best_gamma_cfa,best_alpha_cfa);
%                     %                     else
%                     %                         cT(y,z)=0; cN(y,z)=0; cD(y,z)=1;
%                     %                     end
%                     
%                     %execute the BBA AJPEG
%                     %                     if(err_ajpeg~=1)
%                     [alT(y,z) alN(y,z) alD(y,z)] = BBA_module(ajpeg_tables(:,1:4), ajpeg_tables(:,5:5), data_vector_ajpeg(1:4), bestNN_a,best_gamma_a,best_alpha_a);
%                     %                     else
%                     %                         alT(y,z) = 0; alN(y,z) = 0; alD(y,z) = 1;
%                     %                     end
%                     
%                     %execute the BBA NAJPEG
%                     %                     if(err_najpeg~=1)
%                     [naT(y,z) naN(y,z) naD(y,z)] = BBA_module(najpeg_tables(:,1:4), najpeg_tables(:,5:5), data_vector_najpeg(1:4), bestNN_na,best_gamma_na,best_alpha_na);
%                     %                     else
%                     %                         naT(y,z) = 0; naN(y,z) = 0; naD(y,z) = 1;
%                     %                     end
%                     
%                     
% %                 else
% %                     %If the image is in the TIFF format, then analyse it
% %                     %only with the CFA module
% %                     [data_vector_cfa data_vector_ajpeg data_vector_najpeg ] = create_vectors( data,q1,q2,cfa_map(y,z),0,0,0);
% %                     data_vector_cfa=normalize_matrix(data_vector_cfa);
% %                     [cfaT(y,z) cfaN(y,z) cfaD(y,z)] = BBA_module(cfa_tables(:,1:5),cfa_tables(:,6:6),data_vector_cfa(1:5),bestNN_cfa,best_gamma_cfa,best_alpha_cfa);
% %                 end
%             end
%         end
        
        nt = NT;
        nn = NN;
        nd = ND;
        
        at = AT;
        an = AN;
        ad = AD;
        
        ct = CT;
        cn = CN;
        cd = CD;

        
%%%%%%%%%%%%%% DST WITHOUT GLOBAL VARIABLE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         NT=nt*zeros(row,col); NN=nn*zeros(row,col); ND=ones(row,col);
%         AT=at*zeros(row,col); AN=an*zeros(row,col); AD=ones(row,col);
%         CT=ct*zeros(row,col); CN=cn*zeros(row,col); CD=ones(row,col);
%         
%         
%         %Evaluate the tampered and the original propositions for the fusion.
%         BelT = eval(tampered);
%         BelN = eval(original);
%         
%         %If the format is JPEG, use the BelT map
% %         if(strcmp(image_info.Format,'jpg')==1)
%             belt_map=BelT;
%             beln_map=BelN;
% %         else
% %             %If the format is TIFF, use only the CFA map
% %             belt_map=cfaT;
% %             beln_map=cfaN;
% %         end
%         %         hh=imagesc(belt_map,[0,1]);
%         %         saveas(hh, [char(img_list(j)) '.fig'], 'fig');
%         %         close all;
         [pathstr name ext] = fileparts( char(list(j)) );
%         save([resultspath ...
%             name '_DST_without_global.mat'],'belt_map','beln_map');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% DST WITH GLOBAL VARIABLE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %Trasform the global variables into matrices
        NT=nt*ones(row,col); NN=nn*ones(row,col); ND=zeros(row,col);
        AT=at*ones(row,col); AN=an*ones(row,col); AD=zeros(row,col);
        CT=ct*ones(row,col); CN=cn*ones(row,col); CD=zeros(row,col);
        
%         %Evaluate the tampered and the original propositions for the fusion.
%         BelT = eval(tampered);
%         BelN = eval(original);
%         
%         %If the format is JPEG, use the BelT map
% %         if(strcmp(image_info.Format,'jpg')==1)
%             belt_map=BelT;
%             beln_map=BelN;
% %         else
% %             %If the format is TIFF, use only the CFA map
% %             belt_map=cfaT;
% %             beln_map=cfaN;
% %         end
%         %         hh=imagesc(belt_map,[0,1]);
%         %         saveas(hh, [char(img_list(j)) '.fig'], 'fig');
%         %         close all;
%         save([resultspath ...
%             name '_DST_with_global.mat'],'belt_map','beln_map');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sum_map = (cfa_map + najpeg_map + ajpeg_map)./3;
        prod_map = (cfa_map .* najpeg_map .* ajpeg_map)^(1/3);
        
        sum_map_wg = ((CT.*cfa_map) + (NT.*najpeg_map) + (AT.*ajpeg_map))./(CT+NT+AT);
        prod_map_wg = exp(((log(cfa_map+1).^(CT)) .* (log(najpeg_map+1).^(NT)) .* (log(ajpeg_map+1).^(AT)))-(CT+NT+AT)) - 1;
                save([resultspath ...
            name '_unsupervised.mat'],'sum_map','prod_map','sum_map_wg','prod_map_wg');
        
    end
end



end
