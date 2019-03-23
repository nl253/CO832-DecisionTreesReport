#!/usr/bin/env bash

DIR=$(command dirname $(command readlink -f $0))
DATA="$DIR/data.arff"

weka() {
  command java -cp /usr/share/weka-3-8-3/weka.jar weka.Run .J48 $@
}

help() {
  weka $@
}

train() {
  weka -t "$DATA" -do-not-output-per-class-statistics -o -v $@
}

info() {
  weka -info $@
}

cv() {
  train $@
}

split() {
  train -split-percentage 90 $@
  # train -split-percentage 10 -no-cv $@
}

graph() {
  $1 -g ${@:2} | dot -Tpng | feh -
}

acc() {
  $1 ${@:2} | command grep -Eo 'Correctly Classified Instances.*' | command grep -Eo '([0-9.]+)\s*%' | command grep -Eo '[0-9.]+' | command sed -E 's/([0-9]+)[.]?([0-9]*)/0.\1\2/'
}


$1 ${@:2}
