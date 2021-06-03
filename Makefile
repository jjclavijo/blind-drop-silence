SHELL=zsh

INPUT_VIDEO = <please please please say which video to process>

#DRAFT = -d
DRAFT = 
# useful for better performance when not working
# with colours or not caring about colours.

FFMPEG_ARGS = -c:v libx264 -preset veryslow -crf 0 -pix_fmt yuv444p
#             ↑~~~~~~~~~~~ ↑~~~~~~~~~~~~~~~ ↑~~~~~~~~~~~~~~~~~~~~~~
#             │            │                │
#             │            │                └──── lossless
#             │            │
#             │            └──── high compression
#             │
#             └──── h.264, a lossless-capable codec

all: nuevosSilencios.txt
	${MAKE} times/Makefile
	${MAKE} times/splitsh
	cd times;\
		${MAKE} INPUT_VIDEO=../$(INPUT_VIDEO) all

audio.mp3: $(INPUT_VIDEO)
	ffmpeg $^ $@

silencios.txt: audio.mp3
	./coso.sh $^ $@

nuevosSilencios.txt: silencios.txt
	./joinsilencios.py $^ $@

.PHONY: times/splits

times/splits: nuevosSilencios.txt
	-mkdir times
	-split -d -a1 -l100 --additional-suffix=.txt "$^" "times/splits-"

times/Makefile: times/splits
	@cp Makefile.1 $@
	while read i a b;\
	do if [ $$a = \'end\' ];\
	  then echo '	                     >('$$(echo $${i%%.*}| sed "s/times/./")'.sh)'" 'end' " >>$@ ;\
	  elif [[ $$a -eq 0 ]];\
	  then echo 'Skip 0' ;\
	  else echo '	                     >('$$(echo $${i%%.*}| sed "s/times/./")'.sh)'" $$(python -c 'print(round('$$a' * 24))') "\\ >>$@ ;\
		fi;\
	done <<( {head -q -n1 times/splits-*.txt; echo \'end\'} | paste <(echo 'DELETE';fd 'splits.*txt' times) - );


times/splits-%.sh: times/splits-%.txt
	@cp split.sh.1 $@
	i=0;\
	read tini _ <<( head -n 1 $^ || echo 0 0) ;\
	while read a b;\
	do if [ $$i -eq 0 ];\
	then i=1;\
			 echo '	                     /dev/null'" $$(python -c 'print(round(('$$b' - '$$tini') * 24))') "\\ >>$@ ;\
	else echo -n $$((i++))...;\
	echo '	                     >(blind-to-video $(DRAFT) $${framerate} $(FFMPEG_ARGS) '"$*-$$((i-1))"'.mkv)'" $$(python -c 'print(round(('$$a' - '$$tini') * 24))') "\\ >>$@ ;\
	echo '	                     /dev/null'" $$(python -c 'print(round(('$$b' - '$$tini') * 24))') "\\ >>$@ ;\
	fi;\
	done <$^;\
	echo -n $$((i++))...;\
	echo '	                     >(blind-to-video $(DRAFT) $${framerate} $(FFMPEG_ARGS) '"$*-$$((i-1))"'.mkv)'" 'end' " >>$@ ;

times/splitsh: 
	for i in times/splits*.txt;\
		do ${MAKE} $${i%%.*}.sh;\
	done
	chmod +x times/splits*.sh
