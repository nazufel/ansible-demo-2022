#!/bin/bash


while true; do

  echo
  curl localhost:8081
  echo
  echo
  sleep 1

  echo
  curl localhost:8080
  echo
  echo
  sleep 1
done