cornerstone-d.exe:
	dub

.PHONY: c
c:
	cd checker && dub
	
checker/checker.exe:
	cd checker && dub

clean:
	checker/checker.exe