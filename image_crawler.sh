#!/bin/bash
# $1: Number of images to scrape
# $2: Downloader to use (0 for wget and 1 for curl)
# $3: Width of final resized image
# $4: Height of final resized image

###################### Config ####################################

num=$1;
CRAWLER=
OUTPUT_FLAG=-O     # For curl it changes to use '-o' in DetectEnv().
RETRY_FLAG=-t      # Default retrying flag (for wget). For curl using '--retry <num>'.
RETRY_NUM=3        # Crawler retries <num> times if here's a connection issue.
QUITE_FLAG=-q      # Turning off crawler's logging output. For curl using '-s'.
FOLLOW_REDIRECT=   # Following the redirection, in case 301 moved was returned. For curl using '-L'.
ROBOTS_CMD="-e robots=off"  # wget only, do not honor robots.txt rules.
USERAGENT_FLAG=-U  # For curl, using '-A'
USERAGENT_STRING="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36"
RESIZE_WIDTH=$4
RESIZE_HEIGHT=$3
CRAWLER_OPT=$2

##########################################################

function selectCrawler() {
  which wget > /dev/null 2>&1
  if [ $CRAWLER_OPT -eq 0 ] && [ $? -eq 0  ];then
    CRAWLER=wget
    echo -e "Using wget as crawler...\n"
  else
    which curl > /dev/null 2>&1
    if [ $CRAWLER_OPT -eq 1 ] && [ $? -eq 0 ];then
      CRAWLER=curl
      OUTPUT_FLAG=-o
      RETRY_FLAG=--retry
      QUITE_FLAG=-s
      FOLLOW_REDIRECT=-L
      ROBOTS_CMD=
      USERAGENT_FLAG=-A
      echo -e "Using curl as crawler...\n"
    else
      echo -e "Neither wget nor curl was found, please check your system environment, aborting..."
      exit 1
    fi
  fi
}

function downloadImages() {
  from_filename=$1
  save_dir=$2
  mkdir -p $save_dir
  curr=1
  while read url
  do
    suffix=$(basename ${url})
    $CRAWLER $QUITE_FLAG $RETRY_FLAG $RETRY_NUM $USERAGENT_FLAG "$USERAGENT_STRING" $url $OUTPUT_FLAG $save_dir/${curr}.png && convert $save_dir/$curr.png -resize $RESIZE_WIDTH\x$RESIZE_HEIGHT! $save_dir/$curr.png &
    curr=$(($curr+1))
  done < $from_filename
}

function parsePage() {
  if [ -e results ];then
    rm -rf results;
  fi
  mkdir results;

  local k=1;
  
  round=$(($num));
  remain=$(($num - ${round}*20));
  while read query
  do
    echo "-> Scraping $query"
    touch results/${k}_objURL-list_${query};
    for((i=1; i<=$round; i++))
    do
      (
        $CRAWLER $QUITE_FLAG $RETRY_FLAG $RETRY_NUM $ROBOTS_CMD $FOLLOW_REDIRECT $USERAGENT_FLAG "$USERAGENT_STRING" "http://images.google.com/images?q=${query}&start=$((($i-1)*20))&sout=1" $OUTPUT_FLAG results/${k}_${query}_${i};
# Non-greedy mode, to match only image url src part.
        cat results/${k}_${query}_${i}| egrep 'src="http.*?"' -o | awk -F'"' '{print $2}' >> results/${k}_objURL-list_${query};
      ) &
    done

    if [ $remain -ne 0 ];then
      (
        $CRAWLER $QUITE_FLAG $RETRY_FLAG $RETRY_NUM $ROBOTS_CMD $FOLLOW_REDIRECT $USERAGENT_FLAG "$USERAGENT_STRING" "http://images.google.com/images?q=${query}&start=$((($i-1)*20))&sout=1&num=${remain}" $OUTPUT_FLAG results/${k}_${query}_${i};
        # Non-greedy mode, to match only image url src part.
        cat results/${k}_${query}_${i}| egrep 'src="http.*?"' -o | awk -F'"' '{print $2}' >> results/${k}_objURL-list_${query}
      ) &
    fi
    # Waiting for background jobs to finish before removing temporary files and downloading images
    wait
    (
      rm -rf results/${k}_${query}*
      downloadImages results/${k}_objURL-list_${query} results/$query
    ) &

    k=$(($k+1));
  done < query_list.txt

}

### main() ###
selectCrawler
parsePage $num
wait