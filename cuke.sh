#!/usr/bin/env bash

for i in "$@"
do
case $i in
    -P=*|--pipelines=*)
    export PIPELINES="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--pipeline=*)
    export PIPELINE="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--build=*)
    export BUILD="${i#*=}"
    shift # past argument=value
    ;;
    *)
            # unknown option
    ;;
esac
done

if [ -z $PIPELINE ]
then
  echo "Group required; pass -p=x"
  exit 1
fi

if [ -z $PIPELINES ]
then
  echo "Number of processes required; pass -P=x"
  exit 1
fi

if [ -z $BUILD ]
then
  export BUILD=false
  echo "Defaulting build to false"
  echo "Set BUILD=true or pass -b=true to change"
fi

if [ ! -f ./runtime.log ] || [ $BUILD = 'true' ]
then
  bundle exec parallel_cucumber --test-options \
    '--format pretty --format ParallelTests::Gherkin::RuntimeLogger --out ./runtime.tmp' \
    --only-group $PIPELINE -n $PIPELINES \
    --group-by filesize \
    .
  cat ./runtime.tmp >> ./runtime.log
else
  bundle exec parallel_cucumber --test-options \
    '--format pretty --format ParallelTests::Gherkin::RuntimeLogger --out ./runtime.tmp' \
    --only-group $PIPELINE -n $PIPELINES \
    --group-by runtime \
    --runtime-log ./runtime.log \
    .
  cat ./runtime.tmp >> ./runtime.log
fi

