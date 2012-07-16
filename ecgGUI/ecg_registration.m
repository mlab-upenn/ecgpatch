offset = 35;
x = 1:1000;
sig1 = 10*(sin(2*pi*x*10/1000) + sin(2*pi*x*70/1000) + sin(2*pi*x*170/1000) + sin(2*pi*x*230/1000));
sig1 = sig1 + sin(2*pi*x*30/1000);
%%plot(x,sig1)
sig2 = 10*(sin(2*pi*(x+offset)*10/1001) + sin(2*pi*(x+offset)*70/1001) + sin(2*pi*(x+offset)*170/1001) + sin(2*pi*(x+offset)*230/1001));
%%plot(x,sig1 - sig2)

minVal = 100000;
offset = 0;
maxOffset = 50;

for j=(maxOffset*-1):maxOffset
    diff = sum((sig1(maxOffset+1:maxOffset+21)-sig2(maxOffset+1-j:maxOffset+21-j)).^2);
    if diff < minVal
        minVal = diff;
        offset = j;
    end;
end;
offset
minVal

sig1_interp = interp(sig1,100);
sig2_interp = interp(sig2,100);
x_interp = 1:100000;
%%plot(x,sig1_interp);

registration_window = 1000;
half_rw = registration_window/2;
sig2_index = half_rw + 1 + maxOffset*100 - offset*100;
sig_diff = zeros(1,100000 - registration_window - maxOffset*200);
x_diff = 1:(100000 - registration_window - maxOffset*200);

for i = half_rw+maxOffset*100+1:(100000 - half_rw - maxOffset*100 - 1)
    
    plus1 = sum((sig1_interp((i-half_rw+1):i+half_rw) - sig2_interp((sig2_index-half_rw+2):sig2_index+half_rw+1)).^2);
    zero = sum((sig1_interp((i-half_rw+1):i+half_rw) - sig2_interp((sig2_index-half_rw+1):sig2_index+half_rw)).^2);
    minus1 = sum((sig1_interp((i-half_rw+1):i+half_rw) - sig2_interp((sig2_index-half_rw):sig2_index+half_rw-1)).^2);

    if (plus1 < zero && plus1 < minus1) 
        sig2_index = sig2_index + 1;
    else if (zero <= plus1 && zero <= minus1)
            sig2_index = sig2_index;
        else
            sig2_index = sig2_index - 1;
        end;
    end;
    
    sig_diff(i - half_rw - maxOffset*100) = sig1_interp(i) - sig2_interp(sig2_index);
    
    sig2_index = sig2_index + 1;
    if sig2_index > (100000 - half_rw - maxOffset*100 - 2)
        sig2_index = sig2_index - 2;
    end;
end;

subplot(3,1,1);
plot(x,sig1);
subplot(3,1,2);
plot(x,sig2);
subplot(3,1,3);
plot(x_diff,sig_diff);