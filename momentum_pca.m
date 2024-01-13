% project momentum

% (c)

clear

% Create portfolios and calculate equal-weighted return

load('return_m.mat');

k = 3;
[G,jdate]=findgroups(return_monthly.date);
return_monthly.jdate = G;
T = size(jdate,1);
mom = table();

for i = k:T-1
    % get previous return data
    last_date = [floor(i/k)*k-k+1:floor(i/k)*k];
    now = i+1;
    index_3 = (return_monthly.jdate == last_date);
    index=logical(sum(index_3,2));
    last_return = return_monthly(index,:);
    last_return.return_m = 1+last_return.return_m;
    
    % calculate previous K months return
    [G,code] = findgroups(last_return.code);
    mom_now = splitapply(@(x)prod(x),last_return.return_m,G)-1;
    mom_now = table(code,mom_now);
    
    % record
    index_now = (return_monthly.jdate == now);
    data_now = return_monthly(index_now,:);
    mom_temp = outerjoin(data_now, mom_now,'Keys',{'code'},'MergeKeys',true,'Type','left');
    
    mom = vertcat(mom,mom_temp);
end


% construct 5 portfolios
[G,jdate]=findgroups(mom.jdate);
mom_breaks = table(jdate);
N=5; 
momport = zeros(height(mom),1);
for i=1:N
   underprctile = @(input) prctile(input,100/N*(i-1)); 
   upperprctile = @(input) prctile(input,100/N*i);
   
   mom_breaks.volunder = splitapply(underprctile,mom.mom_now,G);
   mom_breaks.volupper = splitapply(upperprctile,mom.mom_now,G);
   
   merge_data = outerjoin(mom,mom_breaks,'Keys',{'jdate'},'MergeKeys',true,'Type','left');
   
   mom_bucket_i = @(mom,volunder,volupper) bucket(mom,volunder,volupper,i);
   %assigh portfolio
   momport_i = rowfun(mom_bucket_i, merge_data(:,{'mom_now','volunder','volupper'}),...
       'OutputFormat','cell');
   
   momport_i = cell2mat(momport_i);
   momport = momport+momport_i;
   
   merge_data.volunder=[];
   merge_data.volupper=[];
end
merge_data.momport = momport;

% calculate average return
[G,jdate,momport] = findgroups(merge_data.jdate,merge_data.momport);
vwret = splitapply(@(x)mean(x),merge_data(:,{'return_m'}),G);
vwret_table = table(vwret,jdate,momport);
mom_port_table = unstack(vwret_table,'vwret','momport');
mom_port_table.x0 =[];


% pca
returns = table2array(mom_port_table(:,2:end));
[coefMatrix,score,latent,tsquared,explainedVar] = pca(returns);
factors = returns * coefMatrix(:,1:3); 
pca1 = factors(:,1);
pca2 = factors(:,2);


plot(1:5, coefMatrix(:,1:3), '-x');
line([0 125], [0 0], 'Color', 'k'); 
axis([1 5 -0.8 0.8]); 
ylabel('Factor Loading'); 
print('pca3', '-depsc');

