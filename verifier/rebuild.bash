rm source/grammarcheck.d
dub build
./cornerstone-d > source/grammarcheck.d
python3 switch_to_verification.py
dub
python3 switch_to_generation.py
