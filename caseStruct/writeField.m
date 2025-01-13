function  writeField( fid, field)

    [n2,n1] = size(field);
    k = 0;
    for j = 1:n2
        for i = 1:n1
            k = k+1;
            if k == 5
                fprintf(fid, '%16.7E\n', field(j,i));
                k = 0;
            else
                if (i == n1)&&(j == n2)
                    fprintf(fid, '%16.7E\n', field(j,i));
                else
                    fprintf(fid, '%16.7E', field(j,i));
                end
            end
        end
    end
    
end