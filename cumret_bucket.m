function value = cumret_bucket(cumret,cumret20,cumret40,cumret60,cumret80)

if isnan(cumret)
    value=blanks(1);
elseif cumret<=cumret20
    value='A';
elseif cumret<=cumret40
    value='B';
elseif cumret<=cumret60
    value='C';
elseif cumret<=cumret80
    value='D';
elseif cumret>cumret80
    value='E';
else
    value=blanks(1);
end