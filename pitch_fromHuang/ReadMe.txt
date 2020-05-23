from Nicholas Huang:

The tool I used for calculating rate and scale (temporal and freq modulations) is the NSL Toolbox.  It generates a spectrogram from the audio (wav2aud) and then can convert that to a 4-d cortical representation (aud2cort) with timefreqratescale.  I did some simple operations on the spectrogram to get the brightness, bandwidth, etc.

http://nsl.isr.umd.edu/downloads.html

The pitch and harmonicity code was passed to me from a previous student in the lab.  I'll attach it.   It is based on this reference
J. L. Goldstein, “An optimum processor theory for the central formation of the pitch of complex tones,” Journal of the
Acoustical Society of America, vol. 54, pp. 1496–1516, 1973.

It's not my code, so I think don't go sending it everywhere P But feel free to use.