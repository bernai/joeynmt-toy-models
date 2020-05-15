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
    checkout ex4

Create a new virtualenv that uses Python 3. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software:

    ./scripts/download_install_packages.sh


Use joeynmt from this repository:

    git clone https://github.com/bernai/joeynmt
    cd joeynmt
    git checkout factors_changed

If you want to train something else than the baseline model, change train.sh in joeynmt-toy-models. Also, check the config files.
By default, CUDA is enabled and embedding size is 512. Then finally train a model:

    ./scripts/train.sh

The training process can be interrupted at any time, and the best checkpoint will always be saved.

Evaluate a trained model with:

    ./scripts/evaluate.sh
    
To evaluate the models with factored translation: 
In evaluate.sh, change the model name and use the command with test.combined.
# Results

| model       | BLEU |
|-------------|------|
| baseline    | 8.8  |
| concatenate | 5.6  |
| add         | 1.2  |

The baseline model still seems to get the best BLEU score. I used the same embedding size for every model (512). 
It is surprising how low the BLEU score for adding is.

# Changes

joeynmt-toy-models: https://github.com/bernai/joeynmt-toy-models/commit/bbace70b9930387536083eefd0d7450510678b5e
joeynmt: https://github.com/bernai/joeynmt/commit/fa3b0494fdc3e98beb5969acbcf3c21e25c40467
