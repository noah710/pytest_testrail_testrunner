#!/bin/bash

for file in `find . -iname "*pyc"` ; do
   git rm $file
done
