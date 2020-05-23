  #! /bin/bash
scripts=`dirname "$0"`
base=$scripts/..
data=$base/data
MOSES=$base/tools/moses-scripts/scripts
src=nl
trg=en
size_bpe=2000

# sample parallel data: https://stackoverflow.com/questions/49037494/randomly-sample-n-lines-from-two-text-filesparallel-corpus-consistently
shuf -n 100000 --random-source=$data/train.$src-$trg.$src <(cat -n $data/train.$src-$trg.$src) | sort -n | cut -f2- > $data/sample_source.$src
shuf -n 100000 --random-source=$data/train.$src-$trg.$src <(cat -n $data/train.$src-$trg.$trg) | sort -n | cut -f2- > $data/sample_target.$trg

# tokenize test, sampled data, dev
cat $data/test.$src-$trg.$src | $MOSES/tokenizer/tokenizer.perl -l $src > $data/test.tok.$src
cat $data/test.$src-$trg.$trg | $MOSES/tokenizer/tokenizer.perl -l $trg > $data/test.tok.$trg

cat $data/sample_source.$src | $MOSES/tokenizer/tokenizer.perl -l $src > $data/train.tok.$src
cat $data/sample_target.$trg | $MOSES/tokenizer/tokenizer.perl -l $trg > $data/train.tok.$trg

cat $data/dev.$src-$trg.$src | $MOSES/tokenizer/tokenizer.perl -l $src > $data/dev.tok.$src
cat $data/dev.$src-$trg.$trg | $MOSES/tokenizer/tokenizer.perl -l $trg > $data/dev.tok.$trg

# learn joint bpe
subword-nmt learn-joint-bpe-and-vocab -i $data/train.tok.$src $data/train.tok.$trg --write-vocabulary $data/src.out.$src $data/trg.out.$trg -s $size_bpe --total-symbols -o $data/joint.bpe.$src.$trg

# apply bpe
subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/src.out.$src --vocabulary-threshold 10 < $data/test.tok.$src > data/test.bpe.$src
subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/src.out.$src --vocabulary-threshold 10 < $data/dev.tok.$src > data/dev.bpe.$src
subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/src.out.$src --vocabulary-threshold 10 < $data/train.tok.$src > data/train.bpe.$src

subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/trg.out.$trg --vocabulary-threshold 10 < $data/test.tok.$trg > data/test.bpe.$trg
subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/trg.out.$trg --vocabulary-threshold 10 < $data/dev.tok.$trg > data/dev.bpe.$trg
subword-nmt apply-bpe -c $data/joint.bpe.$src.$trg --vocabulary $data/trg.out.$trg --vocabulary-threshold 10 < $data/train.tok.$trg > data/train.bpe.$trg

# create vocabulary for src and trg
python tools/joeynmt/scripts/build_vocab.py $data/train.bpe.$src $data/train.bpe.$trg --output_path $data/vocab.$src.$trg
