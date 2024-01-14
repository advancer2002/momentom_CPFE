%%
clear 
close all

%%
%Read the file
return_monthly=readtable('return_monthly.xlsx','ReadVariableNames',true,'PreserveVariableName',true,'Format','auto');
return_monthly_l=stack(return_monthly,3:127,'NewDataVariableName','return_m','IndexVariableName','date');% transfer to long data
return_monthly_l.return_m=return_monthly_l.return_m/100;

% Read the file with previous month market capitalizaiton 
market_cap_lm_hor=readtable('me_lag.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');
market_cap_lm_l=stack(market_cap_lm_hor,3:127,'NewDataVariableName','lme','IndexVariableName','date');% transfer to long data

% merge these two datesets 
return_m=outerjoin(return_monthly_l,market_cap_lm_l,'MergeKeys',true);
return_m.datestr=datestr(char(return_m.date));
return_m.date=datetime(return_m.datestr,'InputFormat','dd-MMM-yyyy','Locale','en_US');
%drop observations with missing lagged market capitalization.
missingElements = ismissing(return_m,{string(missing),NaN,-99});
rowsWithMissingLme = any(missingElements,2);%missingElements(:,5);
return_m(rowsWithMissingLme,:)=[];


%%
[G,code]=findgroups(return_monthly_l.code);
[G,date]=findgroups(return_monthly_l.date);

K = [1,3,6,12,24];
avespread = zeros(1,5);

for i=1:5

ewret_table = ewret_return(K(i),return_monthly_l,code,date);
ewretA = ewret_table(ewret_table.port=='A',:);
ewretE = ewret_table(ewret_table.port=='E',:);
sA = cumret(ewretA.ewret,K(i));
sE = cumret(ewretE.ewret,K(i));
avespread(i) = mean(sE-sA);

end

spread_table = table(K',avespread','VariableNames',{'K_months','average spread'});
disp(spread_table);
plot(K,avespread);
line([1 24], [0 0], 'linestyle','--','Color', 'k'); 
xlabel('K months');
ylabel('Average spread'); 

