filename='C2_sam.jpg';

imorig=imread(filename);

min=30;
max=100;
step=2;
Output=[];

for ii=min:step:max
    imwrite(imorig,'tmpResave.jpg','JPEG','Quality',ii);
    tmpResave=imread('tmpResave.jpg');
    %figure;
    %imagesc(mean(abs(imorig-tmpResave),3));
    %title(ii);
    Output((ii-min)/step+1)=mean(mean(mean(abs(imorig-tmpResave).^2)));
end
figure;
image(imorig);
figure;
plot(min:step:max,Output)

