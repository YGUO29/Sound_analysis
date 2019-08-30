Run "TransMatrix_4monkey" to show call rate and modulation index (ratio_resp).

You will need to change a few paths before the code can run, including
1. work_path in the beginning
2. rec_path in line 14, which contains the .wav files
3. log_table_file in line 15.
4. filepath in line 54, which should contain the selection table .txt files.

The "win" and "spon_win" is the time window to calculate call rate modulation
Response window is from 0 to "win", baseline window is defined in "spon_win".
Condition should be "7" to match with the condition to be analyzed.


=== Result ===

[ratio_resp]
each column is an initiator, each row is a responder

(see paper "Patterns of call communication between group-housed zebra finches change during the breeding cycle")

[Figure]
cross-correlation between initiator call and responder call