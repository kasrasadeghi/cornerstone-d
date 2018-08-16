default:
	cd verifier && dub
	cd checker && dub

eqc:
	cd verifier && dub
	cd checker/source && FC grammarcheck_compare.d grammarcheck.d