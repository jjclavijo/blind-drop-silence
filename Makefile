SHELL=zsh

INPUT_VIDEO = <please please please say which video to process>

#DRAFT = -d
DRAFT = 
# useful for better performance when not working
# with colours or not caring about colours.

FFMPEG_ARGS = -c:v libx264 -crf 20 -pix_fmt yuv444p
#FFMPEG_ARGS = -c:v libx264 -preset veryslow -crf 0 -pix_fmt yuv444p
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
	${MAKE} aout/audios
	${MAKE} videos/videos

prepare: nuevosSilencios.txt
	${MAKE} times/Makefile
	${MAKE} times/splitsh

audio.mp3: $(INPUT_VIDEO)
	ffmpeg -i $^ $@

silencios.txt: audio.mp3
	./getSilencios.sh $^ $@

nuevosSilencios.txt: silencios.txt
	./joinsilencios.py $^ $@

.PHONY: times/splits

times/splits: nuevosSilencios.txt
	-mkdir times
	-split -d -a4 -l10 --additional-suffix=.txt "$^" "times/splits-"

times/splittimes: 
	while read a b;\
	do echo $$a;\
	  if [[ $$a -eq 0 ]];\
	  then echo 'Skip 0' ;\
	  else echo $$(python -c 'print(round('$$a' * 24))') >>$@ ;\
		fi;\
	done <<( head -q -n1 times/splits-*.txt );\
	echo 'end' >> $@

times/Makefile: times/splits
	@cp Makefile.1 $@
	while read i a b;\
	do echo $$a;\
		if [ $$a = 'end' ];\
	  then echo '	                     >('$$(echo $${i%%.*}| sed "s/times/./")'.sh)'" 'end' " >>$@ ;\
	  elif [[ $$a -eq 0 ]];\
	  then echo 'Skip 0' ;\
	  else echo '	                     >('$$(echo $${i%%.*}| sed "s/times/./")'.sh)'" $$(python -c 'print(round('$$a' * 24))') "\\ >>$@ ;\
		fi;\
	done <<( {head -q -n1 times/splits-*.txt; echo 'end'} | paste <(echo 'DELETE';fd --no-ignore-vcs 'splits.*txt' times) - );


times/splits-%.sh: times/splits-%.txt times/splittimes
	@cp split.sh.1 $@
	splitend=$$( sed -n "$$(($* + 1))p" times/splittimes );\
	psplitend=$$( sed -n "$$(($*))p" times/splittimes || echo 0 );\
	i=0;\
	read tini _ <<( head -n 1 $< || echo 0 0) ;\
	while read a b;\
	do if [ $$i -eq 0 ];\
	then i=1;\
			 echo '	                     /dev/null'" $$(python -c 'print(round(('$$b' - '$$tini') * 24))') "\\ >>$@ ;\
	else echo -n $$((i++))...;\
	echo '	                     >(waitstdin; blind-to-video $(DRAFT) $${framerate} $(FFMPEG_ARGS) '"$*-$$( printf "%02d" $$((i-1)))"'.mkv)'" $$(python -c 'print(round(('$$a' - '$$tini') * 24))') "\\ >>$@ ;\
	echo '	                     /dev/null'" $$(python -c 'print(round(('$$b' - '$$tini') * 24))') "\\ >>$@ ;\
	fi;\
	done < $<;\
	echo -n $$((i++))...;\
	endtime=$$(($${splitend}-$${psplitend}));\
	if [[ $${endtime} > 0 ]];\
	then echo '	                     >(waitstdin; blind-to-video $(DRAFT) $${framerate} $(FFMPEG_ARGS) '"$*-$$( printf "%02d" $$((i-1)))"'.mkv)'" $${endtime} " >>$@ ;\
	else echo '	                     >(waitstdin; blind-to-video $(DRAFT) $${framerate} $(FFMPEG_ARGS) '"$*-$$( printf "%02d" $$((i-1)))"'.mkv)'" 'end' " >>$@ ;\
	fi
	echo 'cat <&0 > /dev/null ' >>$@ ;

times/splitsh: 
	for i in times/splits*.txt;\
		do ${MAKE} $${i%%.*}.sh;\
	done
	chmod +x times/splits*.sh

aout/audios:
	mkdir -p aout;
	mark=0;\
	i=0;\
	while read end b;\
	do sox audio.mp3 aout/salida-$$(printf '%04d' $$i).mp3 trim $$mark \=$$end;\
	mark=$$b;\
	echo -n $$((i++))..;\
	done < nuevosSilencios.txt;\
	sox audio.mp3 aout/salida-$$(printf '%04d' $$i).mp3 trim $$mark
	-rm aout/salida-0000.mp3

ffmpeg.sh: | aout times
	while read aud vid;\
	do echo ffmpeg -i "$$vid" -i "$$aud" -c copy -map 0:v:0 -map 1:a:0 "$$(echo $$vid | sed 's/times/videos/')";\
		done < <( paste <(fd --no-ignore-vcs '.*.mp3' aout | sort) <(fd --no-ignore-vcs '.*.mkv' times | sort)) > $@
	
videos/videos: ffmpeg.sh
	mkdir -p videos;
	cat ffmpeg.sh | parallel

# Se recomienda abrir en VLC todos los mkv, y eliminar los que se quiera de la plailist.
#
# A Partir de la playlist resultante contruir una lst.ffmpeg del tipo
#
# file video/00....mkv
# file video/00....mkv
# ...

lst.ffmpeg: videos
	fd '.*.mkv' videos | sed 's/^/file \"/;s/$$/\"/' > $@

Definitivo.mp4: lst.ffmpeg
	ffmpeg -f concat -i lst.ffmpeg -c copy Definitivo.mp4
