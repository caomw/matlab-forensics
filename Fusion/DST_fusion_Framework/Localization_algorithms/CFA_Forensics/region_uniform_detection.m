% valori della varianza per regioni uniformi

function [data]=region_uniform_detection(mappa_varianza,BPPM,Nb)

BPPM_thresholded=(BPPM>0.5);

missed_block=not(BPPM_thresholded);

func= @(x) max(x(true(Nb)));

max_var=blkproc(mappa_varianza,[Nb,Nb],func);

data=max_var(missed_block);