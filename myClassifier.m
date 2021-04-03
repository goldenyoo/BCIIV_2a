function [check, result] = myClassifier(fp,Mr,Ml,Qr,Ql,k)
    

    check = (0.5*(fp - Mr)'*pinv(Qr)*(fp - Mr) + 0.5*log(det(Qr))) - (0.5*(fp - Ml)'*pinv(Ql)*(fp - Ml) + 0.5*log(det(Ql))); 
 
    if check > 0
      result = -10;
        
    else
        if k ==1
            result = 1;  
        elseif k==2
            result = 2;
        elseif k == 3
            result = 3;
        else
            result = 4;
        end
    end
end
