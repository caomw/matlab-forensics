 
function calcolo_MSE(folder_name,Bayer_R, Bayer_G, Bayer_B);

h=waitbar(0,'Please wait...');

dim = 512;

cost = 1/(512*512);

directory = dir([folder_name,'/*.tif*']);

files = {directory.name};

MSE_bilin = zeros(3,length(files));
MSE_median = zeros(3,length(files));
MSE_gradientbased = zeros(3,length(files));


for i = 1:length(files)
    
    current_file = char(files(i));
    
    file_name = [folder_name,'/',current_file];
    
    Itest = imread(file_name);
    
    im_bilineare = uint8( filtro_bilineare ( Itest, Bayer_R, Bayer_G, Bayer_B ) );
    
    im_median = uint8( filtro_mediana ( Itest, Bayer_R, Bayer_G, Bayer_B ) );
    
    im_gradientbased = uint8( filtro_gradientbased ( Itest, Bayer_R, Bayer_G, Bayer_B ) );
    
    MSE_bilin(1,i) = (4/3)*cost*(sum(sum(( Itest(:,:,1)-im_bilineare(:,:,1) ).^2)));
    MSE_median(1,i) = (4/3)*cost*(sum(sum(( Itest(:,:,1)-im_median(:,:,1) ).^2)));
    MSE_gradientbased(1,i) = (4/3)*cost*(sum(sum(( Itest(:,:,1)-im_gradientbased(:,:,1) ).^2)));

    MSE_bilin(2,i) = 2*cost*(sum(sum(( Itest(:,:,2)-im_bilineare(:,:,2) ).^2)));
    MSE_median(2,i) = 2*cost*(sum(sum(( Itest(:,:,2)-im_median(:,:,2) ).^2)));
    MSE_gradientbased(2,i) = 2*cost*(sum(sum(( Itest(:,:,2)-im_gradientbased(:,:,2) ).^2)));

    MSE_bilin(3,i) = (4/3)*cost*(sum(sum(( Itest(:,:,3)-im_bilineare(:,:,3) ).^2)));
    MSE_median(3,i) = (4/3)*cost*(sum(sum(( Itest(:,:,3)-im_median(:,:,3) ).^2)));
    MSE_gradientbased(3,i) = (4/3)*cost*(sum(sum(( Itest(:,:,3)-im_gradientbased(:,:,3) ).^2)));

    waitbar(i/length(files));

end

MSE_bilin_mean = mean( MSE_bilin,2 );
MSE_median = mean( MSE_median,2 );
MSE_gradientbased = mean( MSE_gradientbased,2 );

save([folder_name,'/','MSEs.mat'], 'MSE_bilin_mean', 'MSE_median', 'MSE_gradientbased');


    
    


