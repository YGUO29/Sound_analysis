Below is the link to the matlab data structure and code you need to extract the call timing and call type information.
https://www.dropbox.com/sh/ib836sqh2fyuu5e/AAB8mpFaQPMQ9u8gOOv1Wtaba?dl=0

"Call Information" contains all the .mat files with call time/call types.

You will need the "social" package (in the "social" folder) to correctly load the data into Matlab (see demo).

"demo_live" is a Matlab live script that gives you a guide of how to read the data. You can run each section to see the result. (It's my first time to use live script, so I appreciate your feedback on whether it helps for clarity.)


The raw data are in these folders on the server:
/Recording_Colony_Vocalization/CageMerge/M91C_M92C_M64A_M29A
/Recording_Colony_Neural/M93A
/Recording_Colony_Neural/M9606

For the M93A and M9606, you only need to take the .wav file with names like "voc_9606_c_S100.wav". Other files (e.g., **S100n.wav) are for neural recordings, etc.
"S100" means session 100. The corresponding .mat file is "Session_voc_9606_c_S100.mat".

For the four monkey recording, not all files are labeled. You can check the .mat files I send you to see which sessions are labeled and only collect those files (those .wav files with corresponding .mat files). These mat file only contains calls with relatively good quality (some calls that are identified from an individual with decent confidence but are overlapping with noise or are too weak in intensity are excluded). Also, use the .wav files with "balanced gain" in the file names. The gain of preamp is different across channels during recording and they are adjusted to be the same in these files so the sound level is comparable. But if you just want to cut some calls out as sound stimuli, this does not matter.

Let me know if you have any questions.

Lingyun