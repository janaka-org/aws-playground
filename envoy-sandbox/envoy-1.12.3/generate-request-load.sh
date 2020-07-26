#!/bin/sh
for i in 1 2 3 4 5
do
  curl -v localhost:8000/trace/1
done