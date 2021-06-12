#!/bin/zsh

typeset -i auto
typeset -i i
typeset -i a
typeset -i NVID

typeset -l char
typeset -l whichend

VIDEOS=$(ls videos | grep mkv | sort)
read NVID _ < <(wc -l <(echo $VIDEOS))

echo $NVID

i=$1

echo $i

auto=0

while [ $((++i)) -le ${NVID} ]
do file=videos/$(sed -n "${i}p" <(echo $VIDEOS))
  echo playing $file
  mplayer -volume 40 -vf screenshot -speed 1.25 $file \
           2>&1 | sed -n '/Exiting/ {s/.*(\(.*\))/\1/;p}' | tr ' ' '_' | read whichend #; cat <&0 >/dev/null

  echo $whichend

  if [ $whichend = quit ]
  then auto=0
  fi

  if [ $auto -eq 0 ]
  then
    stty cbreak
    char=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
    stty -cbreak
  else 
    char=s
  fi

  echo $char 

  case $char in
    s)
      echo file \'$file\' | tee -a list.files
      ;;
    d)
      echo DDDD \'$file\' | tee -a list.files
      ;;
    a)
      auto=1
      ;;
    q)
      break
      ;;
    r)
      echo repeating $((i--))
      ;;
    p)
      (( i-- ))
      echo repeating $((i--))
      ;;
    n)
      if [ $lastchar = n ]
      then (( counter++ )) 
      else counter=1
      fi
      (( i++ ))
      echo showing $((i--))
      ;;
    b)
      i=$(( i - counter ))
      echo repeating $((i--))
      ;;
    \<)
      read a
      i=$(( i - a ))
      echo repeating $((i--))
      ;;
    \>)
      read a
      i=$(( i + a ))
      echo showing $((i--))
      ;;
    *)
      echo file \'$file\'
      ;;
  esac

  lastchar=$char

done

