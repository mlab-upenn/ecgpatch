function ECG_optimized(port,limit)
%% Hz is the frequency
% delete(INSTRFIND);
close all

%%
% insert some nargins

%% Opens the serial port
board = serial(port,'BaudRate',115200);
fopen(board);

%% Begin Asynchronous
board.ReadAsyncMode = 'continuous';
readasync(board);

%% Opens the figure for the plot
figure(1)
hold on
plot(0,0)
xlabel('Time [ms]')
ylabel('ADC Output')

n = [];
data = [];

while(1)
% for i = 1:2000
    
    data = [data fscanf(board,'%d')];   % Incoming data from serial port
    
    if isempty(n)                       % If n is empty, initializes the vector
        n = 1;
    else
        n = [n (n(end)+1)];             % Builds n
    end
    
    
    
    modvalue = mod(n(end),5);
    
    % low-pass filter
    
    if modvalue == 0    
        if n(end) == 5
            N = n(end-4):n(end);
        else
            N = n(end-5):n(end);
        end
        
        figure(1)
        seg_data = data(N);             % Segmented data
        plot(N,seg_data,'r')                % Plot every set of 5 data points
        
        % Attempt at scrolling window
        if N(end) <= 1000
            xlim([n(1) n(1)+1000])
        else
            xlim([n(end-1000) n(end)])
        end
    end
end

%%

    
% % A = [A fscanf(board,'%d')]
% % n = (n+1)
% % figure(1)
% % subplot(2,1,1)
% % hold on
% % plot(n,A)
% % 
% % subplot(2,1,2)
% % hold on
% % line(n,A)


end



