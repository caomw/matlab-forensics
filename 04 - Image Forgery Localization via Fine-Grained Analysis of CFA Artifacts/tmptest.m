im=im2;


% dimensione of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;

            toCrop=mod(size(im),2);
            im=im(1:end-toCrop(1),1:end-toCrop(2),:);
            
            [bayer, F1]=GetCFASimple(im);
            Result=cell(2,1);
            
            for j = 1:2
                [map, stat] = CFAloc(im, bayer, Nb(j),Ns);
                Result{j}=map;
            end
