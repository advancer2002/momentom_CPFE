function ewret_table = ewret_return(K,return_monthly_l,code,date)

prctile_20=@(input)prctile(input,20);
prctile_40=@(input)prctile(input,40);
prctile_60=@(input)prctile(input,60);
prctile_80=@(input)prctile(input,80);

breaks = table(date(K:K:end));

if (K==1) 
    for j=1:length(code)
        stock = code{j};
        ret_array = return_monthly_l(contains(return_monthly_l.code, stock), :);
        ret_array = ret_array.return_m;
        s = ret_array;
        breaks = addvars(breaks, s);
    end  
else
    for j=1:length(code)
        stock = code{j};
        ret_array = return_monthly_l(contains(return_monthly_l.code, stock), :);
        ret_array = ret_array.return_m;
        s = cumret(ret_array,K);
        breaks = addvars(breaks, s);
    end  
end
    

breaks.Properties.VariableNames(2:end) = code;
breaks.Properties.VariableNames(1) = {'date'};
breaks_new = stack(breaks,code');
breaks_new.Properties.VariableNames(2) = {'code'};
breaks_new.Properties.VariableNames(3) = {'cumret'};

breaks_new.code = cellstr(breaks_new.code);
return_mat = outerjoin(return_monthly_l,breaks_new,'Keys',{'date','code'},'MergeKeys',true,'Type','left');

return_mat = sortrows(return_mat, {'code','date'},{'ascend','ascend'});


s = return_mat.cumret;
s = horzcat(0,s');
s = s(1:end-1);
return_mat.cumret = s';


first_date  = datenum(cellstr(breaks_new.date(1)));
return_mat.numdate = datenum(cellstr(return_mat.date));
return_mat = return_mat(return_mat.numdate > first_date,:);
return_mat.cumret = fillmissing(return_mat.cumret,'previous');

return_mat = sortrows(return_mat, {'date','code'},{'ascend','ascend'});
[G,date]=findgroups(return_mat.date);
breaks=table(date);

breaks.cumret20=splitapply(prctile_20,return_mat.cumret,G);
breaks.cumret40=splitapply(prctile_40,return_mat.cumret,G);
breaks.cumret60=splitapply(prctile_60,return_mat.cumret,G);
breaks.cumret80=splitapply(prctile_80,return_mat.cumret,G);

return_mat = outerjoin(return_mat,breaks,'Keys',{'date'},'MergeKeys',true,'Type','left');
cumretport=rowfun(@cumret_bucket,return_mat(:,{'cumret','cumret20','cumret40',...
'cumret60','cumret80'}),'OutputFormat','cell');

return_mat.cumretport=cell2mat(cumretport);
return_mat(:,{'cumret20','cumret40',...
'cumret60','cumret80'}) = [];

return_mat.ewt = ones(height(return_mat),1);
[G date_n port] = findgroups(return_mat.date,return_mat.cumretport);

ewret = splitapply(@wavg,return_mat(:,{'return_m','ewt'}),G);
port=strcat(port);
ewret_table=table(ewret,date_n,port);

end