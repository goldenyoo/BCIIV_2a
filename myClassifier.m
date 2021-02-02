function [check, result] = myClassifier(fp,M_1,M_2,M_3,M_4,Q_1,Q_2,Q_3,Q_4);
    
    check_1 = ML(fp,M_1,Q_1);
    check_2 = ML(fp,M_2,Q_2);
    check_3 = ML(fp,M_3,Q_3);
    check_4 = ML(fp,M_4,Q_4);
   
    tmp = [check_1 check_2 check_3 check_4];
    [me, index] = min(tmp);
    
    check = me;
    result = index;
    
    function prob = ML(fp,M,Q)
        prob = (0.5*(fp - M)'*pinv(Q)*(fp - M) + 0.5*log(det(Q)));
    end
end
