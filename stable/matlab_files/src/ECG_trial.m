function [n,data]=ECG_trial(port,precision)
%% Hz is the frequency
% delete(INSTRFIND);
close all

% insert some nargins

%% Opens the serial port
board = serial(port,'BaudRate',115200);
fopen(board);

%% Begin Asynchronous
board.ReadAsyncMode = 'continuous';
readasync(board);

%% Opens the figure for the plot
figure(1)

plot(0,0)
xlabel('Time [ms]')
ylabel('ADC Output')

n = [];
data = [];
time = 0;

while(1)
% % for i = 1:2000

    
    data = [data fscanf(board,'%d')];   % Incoming data from serial port
    time = time+1;
    
    if isempty(n)                       % If n is empty, initializes the vector
        n = 1;
    else
        n = [n (n(end)+1)];             % Builds n, our index vector
    end
    
    modvalue = mod(n(end),precision);
    
    % low-pass filter
    
    
    
    if modvalue == 0
% %         if n(end) == 5
% %             N = 1:n(end);
% %             k = length(N);
% %         else
% %             N = n(end)-5:n(end);
% %             k = length(N);
% %         end      
% %         seg_data = data(N);             % Segmented data
        
% %         % When data becomes large, we can still plot the large indices
% %         if n(end)>= 1000;
% %             plotN = plotN(end):(plotN(end)+5);
% %             xlim([n(end-999) n(end)])
% %         else
% %             plotN = N;
% %             xlim([n(1) n(1)+1000])
% %         end
% % %         size(plotN)
        
        figure(1)
        hold on
        plot(n,data,'r','LineWidth',3)                % Plot every set of 5 data points
        xlabel('Time [ms]')
        ylabel('ADC Output')
        
        % Attempt at scrolling window
% %         if N(end) <= 1000
        xlim([1 1000])
        ylim([-4*10^4 4*10^4])
        
        
% %         else
% %             xlim([n(end-1000) n(end)])
% %         end

            data = data(end);
            n = n(end);
            
            if n(end) >= 1000
                n = 1;
                clf(figure(1));
            end
    end
    % get rid of old data
% %     if length(n) >=1000
% %         n = n(end-999):n(end);
% %         data = data(n);
% %     end
% %     data_size = length(data)
% %     data(end)
    n;
    data;
    
% %     if n(end) == 1000
% %             n = 1;
% %     end
    
    
end







