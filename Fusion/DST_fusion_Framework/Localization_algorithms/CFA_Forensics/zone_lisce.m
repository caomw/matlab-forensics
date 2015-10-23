function [ Matrix_chiara,Matrix_scura ] = zone_lisce( zona_liscia,matrixnormalizzata )
% Analizza la zona R3 (zona liscia) per dividerla in zona chiara e scura

% Ti soglia che distingue pixel chiari da scuri
Ti=median(median(matrixnormalizzata));

Rchiara=matrixnormalizzata<Ti; %creazione maschera zona chiara
Rscura=matrixnormalizzata>=Ti; %creazione maschera zona scura

Matrix_chiara = zona_liscia.*Rchiara; %crezione zona chiara
Matrix_scura = zona_liscia.*Rscura; %crezione zona scura