% CPFE Final Project Jiacheng Liu; Xuran He; Shengdi Yao
clear 
close all

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