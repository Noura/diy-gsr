from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

b = signal.firwin(33, 0.5, window='hamming')
w, h = signal.freqz(b)

fig = plt.figure()
plt.title('frequency response')
ax1 = fig.add_subplot(111)

plt.plot(w, 20 * np.log10(abs(h)), 'b')
plt.ylabel('Amplitude [dB]', color='b')
plt.xlabel('Frequency [rad/sample]')

ax2 = ax1.twinx()
angles = np.unwrap(np.angle(h))
plt.plot(w, angles, 'g')
plt.ylabel('Angle (radians)', color='g')
plt.grid()
plt.axis('tight')
plt.show()
