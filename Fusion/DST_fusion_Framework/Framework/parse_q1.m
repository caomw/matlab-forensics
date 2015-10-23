function [q1]=parse_q1(q)
    %This function rounds the value of q to its nearest integer value
    if(q<50)
        q1=50;
    elseif(q>=50 && q<=55)
        q1=50;
    elseif(q>55 && q<=60)
        q1=60;
    elseif(q>=60 && q<=65)
        q1=60;        
    elseif(q>65 && q<=70)
        q1=70;
    elseif(q>=70 && q<=75)
        q1=70;
    elseif(q>75 && q<=80)
        q1=80;
    elseif(q>=80 && q<=85)
        q1=80;        
    elseif(q>85 && q<=90)
        q1=90;
    elseif(q>=90 && q<=95)
        q1=90;                
    else
        q1=100;
    end    
end