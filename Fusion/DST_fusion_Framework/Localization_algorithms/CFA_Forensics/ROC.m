% Generazione delle curve ROC

function ROC(folder_name,tamp)

% waitbar
h=waitbar(0,'Please wait....');

directory = dir([char(folder_name), '\BPPM\*.mat']);
files = {directory.name};

passo2x2=0.001;     % passo per statistica 2x2
passo4x4=0.00005;   % passo per statistica 4x4
passo8x8=0.00001;   % passo per statistica 8x8 

% soglie per le curve ROC
th2x2=0:passo2x2:1;
th4x4=0:passo4x4:1;
th8x8=0:passo8x8:1;


dim=512;

% Numero di blocchi 2x2 da accumulare
Ns=[1,2,4];

% Dimensioni del filtraggio
Nm=5;


mask2x2=tampering_mask(dim/2,tamp/2);
mask4x4=tampering_mask(dim/4,tamp/4);
mask8x8=tampering_mask(dim/8,tamp/8);

vettore_logico2x2=logical(kron(ones(100,1),mask2x2(true(length(mask2x2)))));
vettore_logico4x4=logical(kron(ones(100,1),mask4x4(true(length(mask4x4)))));
vettore_logico8x8=logical(kron(ones(100,1),mask8x8(true(length(mask8x8)))));

data2x2=[];
data4x4=[];
data8x8=[];
data2x2_median=[];
data4x4_median=[];
data8x8_median=[];
data2x2_mean=[];
data4x4_mean=[];
data8x8_mean=[];

for i=1:length(files)
    current_file = char(files(i));
    filename = [folder_name, '\BPPM\', current_file];
    load(filename);
    
    BPPM2x2_median=mappe_cumulate_median(BPPM2x2,Ns(1),Nm);
    BPPM2x2_mean=mappe_cumulate_mean(BPPM2x2,Ns(1),Nm);
    
    BPPM4x4=mappe_cumulate(BPPM2x2,Ns(2));
    BPPM4x4_median=mappe_cumulate_median(BPPM2x2,Ns(2),Nm);
    BPPM4x4_mean=mappe_cumulate_mean(BPPM2x2,Ns(2),Nm);

    BPPM8x8=mappe_cumulate(BPPM2x2,Ns(3));
    BPPM8x8_median=mappe_cumulate_median(BPPM2x2,Ns(3),Nm);
    BPPM8x8_mean=mappe_cumulate_mean(BPPM2x2,Ns(3),Nm);
    
    
    data2x2=[data2x2,BPPM2x2(true(length(BPPM2x2)))];
    data4x4=[data4x4,BPPM4x4(true(length(BPPM4x4)))];
    data8x8=[data8x8,BPPM8x8(true(length(BPPM8x8)))];
    
    data2x2_median=[data2x2_median,BPPM2x2_median(true(length(BPPM2x2_median)))];
    data4x4_median=[data4x4_median,BPPM4x4_median(true(length(BPPM4x4_median)))];
    data8x8_median=[data8x8_median,BPPM8x8_median(true(length(BPPM8x8_median)))];
    
    data2x2_mean=[data2x2_mean,BPPM2x2_mean(true(length(BPPM2x2_mean)))];
    data4x4_mean=[data4x4_mean,BPPM4x4_mean(true(length(BPPM4x4_mean)))];
    data8x8_mean=[data8x8_mean,BPPM8x8_mean(true(length(BPPM8x8_mean)))];
     % waiting bar update
      waitbar(i/(length(files)));
end

regione_tamp2x2=data2x2(vettore_logico2x2);
regione_tamp4x4=data4x4(vettore_logico4x4);
regione_tamp8x8=data8x8(vettore_logico8x8);

regione_tamp2x2_median=data2x2_median(vettore_logico2x2);
regione_tamp4x4_median=data4x4_median(vettore_logico4x4);
regione_tamp8x8_median=data8x8_median(vettore_logico8x8);

regione_tamp2x2_mean=data2x2_mean(vettore_logico2x2);
regione_tamp4x4_mean=data4x4_mean(vettore_logico4x4);
regione_tamp8x8_mean=data8x8_mean(vettore_logico8x8);


regione_not_tamp2x2=data2x2(not(vettore_logico2x2));
regione_not_tamp4x4=data4x4(not(vettore_logico4x4));
regione_not_tamp8x8=data8x8(not(vettore_logico8x8));

regione_not_tamp2x2_median=data2x2_median(not(vettore_logico2x2));
regione_not_tamp4x4_median=data4x4_median(not(vettore_logico4x4));
regione_not_tamp8x8_median=data8x8_median(not(vettore_logico8x8));

regione_not_tamp2x2_mean=data2x2_mean(not(vettore_logico2x2));
regione_not_tamp4x4_mean=data4x4_mean(not(vettore_logico4x4));
regione_not_tamp8x8_mean=data8x8_mean(not(vettore_logico8x8));


h=waitbar(0,'Please wait....');

for i=1:length(th2x2)
             countPD2x2=double(regione_tamp2x2<=th2x2(i));
             PD2x2(i)=sum(countPD2x2)/length(countPD2x2);
             countPFA2x2=double(regione_not_tamp2x2<=th2x2(i));
             PFA2x2(i)=sum(countPFA2x2)/length(countPFA2x2);
             
             countPD2x2_median=double(regione_tamp2x2_median<=th2x2(i));
             PD2x2_median(i)=sum(countPD2x2_median)/length(countPD2x2_median);
             countPFA2x2_median=double(regione_not_tamp2x2_median<=th2x2(i));
             PFA2x2_median(i)=sum(countPFA2x2_median)/length(countPFA2x2_median);
               
             
             countPD2x2_mean=double(regione_tamp2x2_mean<=th2x2(i));
             PD2x2_mean(i)=sum(countPD2x2_mean)/length(countPD2x2_mean);
             countPFA2x2_mean=double(regione_not_tamp2x2_mean<=th2x2(i));
             PFA2x2_mean(i)=sum(countPFA2x2_mean)/length(countPFA2x2_mean);
                         
              % waiting bar update
               waitbar(i/(length(th2x2)));
end

h=waitbar(0,'Please wait....');

for i=1:length(th4x4)
             countPD4x4=double(regione_tamp4x4<=th4x4(i));
             PD4x4(i)=sum(countPD4x4)/length(countPD4x4);
             countPFA4x4=double(regione_not_tamp4x4<=th4x4(i));
             PFA4x4(i)=sum(countPFA4x4)/length(countPFA4x4);
             
             countPD4x4_median=double(regione_tamp4x4_median<=th4x4(i));
             PD4x4_median(i)=sum(countPD4x4_median)/length(countPD4x4_median);
             countPFA4x4_median=double(regione_not_tamp4x4_median<=th4x4(i));
             PFA4x4_median(i)=sum(countPFA4x4_median)/length(countPFA4x4_median);
             
             countPD4x4_mean=double(regione_tamp4x4_mean<=th4x4(i));
             PD4x4_mean(i)=sum(countPD4x4_mean)/length(countPD4x4_mean);
             countPFA4x4_mean=double(regione_not_tamp4x4_mean<=th4x4(i));
             PFA4x4_mean(i)=sum(countPFA4x4_mean)/length(countPFA4x4_mean);
              % waiting bar update
               waitbar(i/(length(th4x4)));
end

h=waitbar(0,'Please wait....');

for i=1:length(th8x8)
             countPD8x8=double(regione_tamp8x8<=th8x8(i));
             PD8x8(i)=sum(countPD8x8)/length(countPD8x8);
             countPFA8x8=double(regione_not_tamp8x8<=th8x8(i));
             PFA8x8(i)=sum(countPFA8x8)/length(countPFA8x8);
             
             countPD8x8_median=double(regione_tamp8x8_median<=th8x8(i));
             PD8x8_median(i)=sum(countPD8x8_median)/length(countPD8x8_median);
             countPFA8x8_median=double(regione_not_tamp8x8_median<=th8x8(i));
             PFA8x8_median(i)=sum(countPFA8x8_median)/length(countPFA8x8_median);  
             
             countPD8x8_mean=double(regione_tamp8x8_mean<=th8x8(i));
             PD8x8_mean(i)=sum(countPD8x8_mean)/length(countPD8x8_mean);
             countPFA8x8_mean=double(regione_not_tamp8x8_mean<=th8x8(i));
             PFA8x8_mean(i)=sum(countPFA8x8_mean)/length(countPFA8x8_mean); 
              % waiting bar update
               waitbar(i/(length(th8x8)));
end

save ([folder_name,'\ROC\ROC'],'PD2x2','PFA2x2','PD4x4','PFA4x4','PD8x8','PFA8x8','PD2x2_median','PFA2x2_median','PD4x4_median','PFA4x4_median','PD8x8_median','PFA8x8_median','PD2x2_mean','PFA2x2_mean','PD4x4_mean','PFA4x4_mean','PD8x8_mean','PFA8x8_mean');

    