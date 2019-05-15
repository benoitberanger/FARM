function out = farm_phase_shift( in, delta_t )
% 'in' is (Nchans X Ntime)
% 'delta_t' is (Nchans X 1)
%
% I don't understand why this implemntation works, and not the one described in
% https://stackoverflow.com/questions/31586803/delay-a-signal-in-time-domain-with-a-phase-change-in-the-frequency-domain-after

Y = fft(in,[],2);

adjustment = zeros(1,size(in,2));
n          = floor(length(adjustment)/2);

adjustment(2:n+1)          =  (1:n);
adjustment(end:-1:end-n+1) = -(1:n);
if ~rem(size(in,2),2)
    adjustment(length(adjustment)/2 + 1) = 0;
end

out = real( ifft( Y .* exp( 1i*2*pi* delta_t .* adjustment ) , [], 2 ) );

end % function
