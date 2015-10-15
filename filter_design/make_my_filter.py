# I want a lowpass filter to cut out this weird GSR slow sine wave that I am so suspicious of

from scipy.signal import firwin

sample_rate = 100
nyq_rate = sample_rate / 2.
cutoff_hz = 1.0
coeffs = firwin(32, cutoff_hz / nyq_rate )

print coeffs
