# joeynmt-toy-models

This repo is just a collection of scripts showing how to install [JoeyNMT](https://github.com/joeynmt/joeynmt), preprocess
data, train and evaluate models.

# Requirements

- This only works on a Unix-like system, with bash.
- Python 3 must be installed on your system, i.e. the command `python3` must be available
- Make sure virtualenv is installed on your system. To install, e.g.

    `pip install virtualenv`

# Steps

Clone this repository in the desired place and check out the correct branch:

    git clone https://github.com/bernai/joeynmt-toy-models
    cd joeynmt-toy-models
    checkout ex5

Create a new virtualenv that uses Python 3. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software:

    ./scripts/download_install_packages.sh

Download data:

    ./scripts/download_data.sh

Preprocess data (sample data, tokenize, apply bpe, create vocabulary). 
You can change the vocabulary size for the BPE-level model in this script as well if you need to train bpe 1500:

    ./scripts/preprocess.sh

Then finally train a model (word or bpe):

    ./scripts/train_word.sh
    ./scripts/train_bpe_2000.sh
    ./scripts/train_bpe_1500.sh

The training process can be interrupted at any time, and the best checkpoint will always be saved.

After training a model, evaluate it with:

    ./scripts/evaluate_bpe_2000.sh
    ./scripts/evaluate_bpe_1500.sh
    ./scripts/evaluate_word.sh


# Experiments with Byte Pair Encoding

I chose nl to en and trained everything on GPU, with beam size 5. 
The BPE model with a vocabulary size of 1500 got the best BLEU score.

| use BPE | vocabulary size | BLEU  |
|---------|-----------------|-------|
| no      | 2000            | 13.2 |
| yes     | 2000            | 20.9 |
| yes     | 1500            | 22.6 |

The word-level model contains a lot of <unk>, as the vocabulary is limited. A lot of information is lost when we have a lot of unknown tokens:

    Reference: The marshmallow has to be on top.
    Word: The <unk> has to <unk>.
    BPE 1500: The markmallow has to be able to get on.
    BPE 2000: The marshmallow has to go on.

Usually if we look at the examples, the word-level model translates some words correctly, but tags a lot of words as <unk> and it isn't clear what the sentence means.
We can also see quite a difference between bpe 1500 and 2000. Somehow, the bpe 1500 model decided to translate 'marshmallow' as 'markmallow'. 

    Reference: And it's pretty amazing.
    Word: That's <unk>.
    BPE 1500: That's inpressive.
    BPE 2000: That's amazing.

Again, the bpe 1500 model, which has a higher score than the other ones, decided to use 'inpressive' instead 'impressive'. 
The lower vocabulary size seems to result in strange words being formed.

    Reference:  If we want to solve problems like hunger, poverty, climate change, global conflict, obesity, 
                I believe that we need to aspire to play games online for at least 21 billion hours a week, by the end of the next decade.  No. I'm serious. I am.
    Word:       If we want to <unk> problems like <unk>, poverty, climate change, <unk> conflict, <unk>, 
                I believe that we need to try to <unk> <unk> <unk> billion hours of <unk> <unk> <unk> <unk>. No, I <unk> it. <unk>.
    BPE 1500:   And if we want to solve problems as hunger, poverty, climate change, global conflict, the global conflict, 
                I believe that we need to try to try to try to try to speak more minutes 21 billion hours of online games against the end of the next decade. No, I love it.
    BPE 2000:   If we want to solve problems like hunger, poverty, climate change, global conflict, equally, 
                I believe that we need to try to play at least, 21 billion hours to the end of the population decade.

Longer sentences seem to be difficult for all models. Bpe 1500 repeats 'to try' a lot, but has a lot of overlapping words with the reference, thus the higher score I suppose.

    Reference: They created a 27,000-acre fish farm -- bass, mullet, shrimp, eel -- and in the process, Miguel and this company completely reversed the ecological destruction.
    Word: She <unk> a <unk> <unk> <unk> <unk> -- <unk>, <unk>, <unk>, <unk>, <unk> -- and the <unk> <unk> and his <unk> <unk> <unk> <unk> <unk>.
    BPE 1500: And they created a 1100 hector big fish -- bands, heavy, heart, garnal, paling -- and teaching, and teaching, and teaching, and teachers have Miguel and his business the ecological amazing.
    BPE 2000: They created a 1100 hoctare big fish -- bill, heart, garnals, paling -- and the same time, Miguel and his company, the ecological amazing.
    
This sentence caught my attention because the word model translation contained so many <unk>. The BPE models did better, but their sentences still do not really make sense. They also produce funny words for 'hectares' (the reference says acres but in nl it was hectare).
All in all, I feel like the sentences of BPE 2000 were more pleasant to read, even though it has a lower BLEU. Maybe, if we would train the models more, the results would change. The word-level model is not really of much use compared to the other two models.

# Impact of beam size on translation quality

For this exercise I will be using the BPE model with vocabulary size 1500. 
We can run ./scripts/evaluate_bpe_1500.sh on the changed config to get the values we need for the graph.

| beam size | BLEU | seconds |
|-----------|------|---------|
| 2         | 22.3 | 21      |
| 5         | 22.6 | 36      |
| 7         | 22.6 | 45      |
| 10        | 22.8 | 61      |
| 15        | 22.6 | 85      |
| 20        | 22.5 | 110     |
| 30        | 22.6 | 161     |
| 40        | 22.6 | 212     |
| 80        | 22.4 | 420     |
| 100       | 22.3 | 522     |

We can see that we got the highest score with beam size 10.
I didn't think that the values would be so close to each other. The translations produced are a bit different (unfortunately markmallow and inpressive still are the top choice), 
but in total the score stays approximately the same. We can take a look at our examples from above:

       beam size 5:    - The markmallow has to be able to get on.
                       - That's inpressive.
                       - And if we want to solve problems as hunger, poverty, climate change, global conflict, the global conflict, 
                         I believe that we need to try to try to try to try to speak more minutes 21 billion hours of online games against the end of the next decade. No, I love it.
       beam size 10:   - The markmallow has to be able.
                       - That's inpressive.
                       - And if we want to solve problems as hunger, poverty, climate change, global conflict, the global conflict, 
                         I believe that we need to try to try to try to try to speak more minutes 21 billion hours of online games against the end of the next decade. No, I'm mone.
       
In the future I would choose either beam size 5, as it is fast and gives a good score, or 10, because it seems to be getting the best score (would need to see how it works with the data I get).  
It would be interesting to see what results we get regarding beam sizes with different data.

![Graph Beam Size]
(https://github.com/bernai/joeynmt-toy-models/blob/ex5/graph/graph.png)
