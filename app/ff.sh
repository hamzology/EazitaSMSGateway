#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/nudewow/log.out 2>&1

startstream='yes'
eval $(ffprobe -v quiet -show_format -of flat=s=_ -show_entries stream=height,width,nb_frames,duration,codec_name rtmp://localhost:1935/$1/$2);
codecn=${streams_stream_0_codec_name};
nbstreams=${format_nb_streams};

OUTPUT="$(ffprobe -v quiet -print_format json -show_format -show_streams rtmp://localhost:1935/$1/$2)"
resp=$(curl --header "Content-type: application/json" --request POST --data "$OUTPUT" http://api.eazita.com/ezsms/parameterssaver.php?encodedata=yes&streamkey=$2);


if [ "$resp" == "" ]; then
    curl -i http://api.eazita.com/ezsms/parameterssaver.php?respo=blank
else
    curl -i http://api.eazita.com/ezsms/parameterssaver.php?respo=notblank
fi
exit 1
