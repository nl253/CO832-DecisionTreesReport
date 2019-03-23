#!/usr/bin/env bash

DIR=$(command dirname $(command readlink -f $0))
DATA="$DIR/data.arff"

weka() { command java -cp /usr/share/weka-3-8-3/weka.jar weka.Run .J48 $@; }

help() { weka $@; }

train() { weka -t "$DATA" -do-not-output-per-class-statistics -o -v $@; }

info() { weka -info $@; }

cv() { train $@; }

split() { train -split-percentage 90 $@; }

graph() { $1 -g ${@:2} | dot -Tpng | feh -; }

acc() {
  $1 ${@:2} | command grep -Eo 'Correctly Classified Instances.*' | command grep -Eo '([0-9.]+)\s*%' | command grep -Eo '[0-9.]+' | command sed -E 's/([0-9]+)[.]?([0-9]*)/0.\1\2/'
}

acc_min_child_items() {
  echo 'Min Child Items,Accuracy (CV),Accuracy (Split),Leaf Count,Node Count'
  for i in $(command seq 0 1 300); do 
    builtin echo "$i,$(acc cv -M $i),$(acc split -M $i),$(split -M $i -g | command grep -E --count 'tested_'),$(split -M $i -g | command grep -E --count '\[\s*label="[^"]*"\s*\]')"
  done 
}

acc_conf() {
  echo 'Confidence,Accuracy (CV),Accuracy (Split),Leaf Count,Node Count'
  for i in $(command seq 0.05 0.05 0.6); do 
    builtin echo "$i,$(acc cv -C $i),$(acc split -C $i),$(split -C $i -g | command grep --count 'tested_'),$(split -C $i -g | command grep --count '\[\s*label="[^"]*"\s*\]')"
  done 
}

acc_reduced_err_prunning_folds() {
  echo 'Fold Count,Accuracy (CV),Accuracy (Split),Leaf Count,Node Count'
  for i in $(seq 2 1 20); do 
    echo "$i,$(acc cv -R -N $i),$(acc split -R -N $i),$(split -R -N $i -g | command grep -E --count 'tested_'),$(split -R -N $i -g | command grep -E --count '\[\s*label="[^"]*"\s*\]')"
  done 
}

acc_batch_size() {
  echo 'Batch Size,Accuracy (CV),Accuracy (Split),Leaf Count,Node Count'
  for i in $(seq 8 8 256); do 
    echo "$i,$(acc cv -batch-size $i),$(acc split -batch-size $i),$(split -batch-size $i -g | command grep -E --count 'tested_'),$(split -batch-size $i -g | command grep -E --count '\[\s*label="[^"]*"\s*\]')"
  done
}

acc_boolean_params() {
  echo 'Parameter,Accuracy (CV),Accuracy (Split),Leaf Count,Node Count'
  for i in A J U S B O doNotMakeSplitPointActualValue; do 
    echo "-$i,$(acc cv -$i),$(acc split -$i),$(split -$i -g | command grep -E --count 'tested_'),$(split -$i -g | command grep -E --count '\[\s*label="[^"]*"\s*\]')"
  done 
}


$1 ${@:2} 2>/dev/null
# $1 ${@:2}
