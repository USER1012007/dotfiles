#!/bin/bash
  wire="$(ip a | grep 'eth0\|enp' | grep inet | wc -l)"
  wifi="$(ip a | grep wlo1 | grep inet | wc -l)"

  if [ $wire != 0 ]; then 
    echo " "
  elif [ $wifi = 1 ]; then
    echo " "
  else 
    echo " "
  fi

