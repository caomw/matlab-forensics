function [Qout] = trovaQ(image)
%image= 'lena50.jpg'
%%% STEP 1:  estraggo matrice Q

jobj = jpeg_read(image);
A=jobj.coef_arrays{1,1};
Q_ORI = jobj.quant_tables{jobj.comp_info(1).quant_tbl_no};

Q_50= [   
    16    11    10    16    24    40    51    61
    12    12    14    19    26    58    60    55
    14    13    16    24    40    57    69    56
    14    17    22    29    51    87    80    62
    18    22    37    56    68   109   103    77
    24    35    55    64    81   104   113    92
    49    64    78    87   103   121   120   101
    72    92    95    98   112   100   103    99
    ];

J=1;
QQ= (10:5:100);
Q2=zeros(8,8,length(QQ));
Diff=zeros(1,length(QQ));
for i = 10:5:100
    if i >= 50
        q = 2-0.02*i;
    else
        q = 50/i;
    end
    Q2(:,:,J)= round(q*Q_50);
    Diff(J)=sum(sum(abs(Q2(:,:,J)-Q_ORI)));
    J=J+1;
end
     [Y,I] = min(Diff);
     
     Qout= QQ(I);
     
