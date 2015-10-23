    path='dataset_for_svm_training';
    cfa_dir='CFA';
    ajpeg_dir='AJPEG';
    najpeg_dir='NAJPEG';
    a_na_path='A_NA';

tamper_size=[512 512];
test_size=[1024 1024];
crea_tampering_cfa(path,cfa_dir,test_size,tamper_size, 90:5:100);
crea_tampering_ajpeg(path,ajpeg_dir,test_size,tamper_size,60:10:70,80:10:90);
crea_tampering_najpeg(path,najpeg_dir,test_size,tamper_size,60:10:70,80:10:90);
crea_tampering_a_na(path,a_na_path,test_size,tamper_size,60:10:70,80:10:90);