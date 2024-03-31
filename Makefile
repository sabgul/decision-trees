all:
	ghc src/*.hs -o flp-fun -Wall

clean:
	rm ./flp-fun src/*.o src/*.hi