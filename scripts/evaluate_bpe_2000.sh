#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

src=nl
trg=en

MOSES=$base/tools/moses-scripts/scripts

num_threads=4
device=0

model_name=bpe_2000
# measure time

SECONDS=0
echo "###############################################################################"
echo "model_name $model_name"


CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/test.bpe.$src > $translations/test.bpe.$model_name.$trg

# undo BPE

cat $translations/test.bpe.$model_name.$trg | sed 's/\@\@ //g' > $translations/test.tok.$model_name.$trg


# undo tokenization

cat $translations/test.tok.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations/test.$model_name.$trg

# compute case-sensitive BLEU on detokenized data

cat $translations/test.$model_name.$trg | sacrebleu $data/test.$src-$trg.$trg

echo "time taken:"
echo "$SECONDS seconds"
