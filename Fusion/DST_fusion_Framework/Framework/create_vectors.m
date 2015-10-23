function [ data_vector_cfa data_vector_ajpeg data_vector_najpeg ] = create_vectors( data,q1,q2,cfa_map,ajpeg_map,najpeg_map,label )
%This function creates the 3 vectors (q1,q2,mean,std dev,map value) from the
%8x8 block of pixel and from the map. These vectors are necessary for the BBA
%modules.
    
    [ mean dev_std ] = dev_std_and_mean( data ); 
    
    data_vector_cfa=zeros(1,6);
    data_vector_najpeg=zeros(1,6);
    data_vector_ajpeg=zeros(1,6);
    
    data_vector_cfa(1)=q1;
    data_vector_cfa(2)=q2;
    data_vector_cfa(3)=mean;
    data_vector_cfa(4)=dev_std;

    data_vector_najpeg(1)=q1;
    data_vector_najpeg(2)=q2;
    data_vector_najpeg(3)=mean;
    data_vector_najpeg(4)=dev_std;

    data_vector_ajpeg(1)=q1;
    data_vector_ajpeg(2)=q2;
    data_vector_ajpeg(3)=mean;
    data_vector_ajpeg(4)=dev_std;

    data_vector_cfa(5)=cfa_map; 
    data_vector_najpeg(5)=najpeg_map; 
    data_vector_ajpeg(5)=ajpeg_map; 

    data_vector_cfa(6)=(label==0);
    data_vector_najpeg(6)=(label==0); 
    data_vector_ajpeg(6)=(label==0);
   
       
end

