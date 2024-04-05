#!/bin/bash
#q2.b (curl commands):

echo " "
echo "Usages:"
curl 127.0.0.1:5000

echo " "
echo "Filter Query"
curl 127.0.0.1:5000 -X POST -d "Filter Query"

echo " "
echo "Aggregation Query"

curl 127.0.0.1:5000 -X POST -d "Aggregation Query"

echo " "
echo "Count Query"

curl 127.0.0.1:5000 -X POST -d "Count Query"
