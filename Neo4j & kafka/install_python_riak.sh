#!/bin/sh

git clone https://github.com/basho/riak-python-client.git 
cd riak-python-client
git submodule update --init
python setup.py install
ln -rs riak ../riak
