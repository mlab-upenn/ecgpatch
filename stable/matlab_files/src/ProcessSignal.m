function BPM = ProcessSignal(lead1,lead2,lead3,n1,n2,n3)
%%
% % Data = xlsread('Scope Data.xls',4);
%%
length(lead1);
V1 = abs(lead1(1:500));              %% Voltage mV
% % V2 = abs(lead2(1:500));
% % V3 = abs(lead3(1:500));

dummy = 500;
if length(n1) < 500
    n1 = zeros(1,500);
    V1 = zeros(1,500);
end

if length(n2) < 500
    n2 = zeros(1,500);
    V2 = zeros(1,500);
end

if length(n3) < 500
    n3 = zeros(1,500);
    V3 = zeros(1,500);
end

t = zeros(3,dummy);
V = zeros(3,dummy);
t =[n1(1:500); n2(1:500); n3(1:500)];    %% Time in 1s/100

V1;
V2;
V3;

V = [V1;V2;V3];

regular_beats = 0;
j = 1;
discrete_locs=[];
%%
peak1 = max(V(1,:));                  %% Volage Peaks
peak2 = max(V(2,:));
peak3 = max(V(3,:));

[peak k] = max([peak1 peak2 peak3]);



min_peak = 0.8*max(V(k,:));          %% compensates for variance

max_locs = find(V(k,:) >= min_peak);  %% Array of locations of Voltage spikes

for i = 1:(length(max_locs)-1)
    diff = abs(max_locs(i)-max_locs(i+1));
    if diff > 4
        discrete_locs = [discrete_locs max_locs(i)];
    end
end

% concatenate the last spike into the location
discrete_locs = [discrete_locs max_locs(end)];

spikes_t = t(k,discrete_locs);         %% Time of spikes                                                                                                                                                            
%%
sml = length(discrete_locs);
time = t(k,end)-t(k,1);                 %% Time in 1s/100
BPS = sml*100/time;
BPM = round(BPS*60);
%%
%%
% % for i=1:(length(spikes_t)-1)
% %     interval(i) = spikes_t(i+1) - spikes_t(i);
% %     
% %     if size(interval >= 2)
% %         diff = abs(interval(1)-interval(i));
% %         if diff <= 0.03*interval(1)
% %             regular_beats = regular_beats +1;
% %         elseif diff > 0.03*interval(1)
% %             irregular_beats = irregular_beats + 1;
% %         end
% %     end
% % end
