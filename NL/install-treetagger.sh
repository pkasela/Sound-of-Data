#!/bin/sh

mkdir TreeTagger
wget -c https://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2.2.tar.gz -P ./TreeTagger
wget -c https://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz -P ./TreeTagger
wget https://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/install-tagger.sh -P ./TreeTagger
wget https://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/italian.par.gz -P ./TreeTagger
cd TreeTagger
sh install-tagger.sh

cd ..
git clone https://github.com/miotto/treetagger-python.git
ln -rs treetagger-python/treetagger.py ./treetagger.py
