% Generazione della maschera di tampering per riconoscere quali regioni
% siano modificate e quali no

function [mask]=tampering_mask(dim,tamper_size)

mask=false(dim,dim);

p1 = floor(([dim dim] - tamper_size)/2) + 1;
p2 = p1 + tamper_size - 1;

for k=p1(1):p2(1)
    for j=p1(2):p2(2)
        mask(k,j)=true;
    end
end