on_die ()
{
    # kill all children
    pkill -KILL -P $$
}
trap 'on_die' TERM

eval $(ffprobe -v quiet -show_format -of flat=s=_ -show_entries stream=height,width,nb_frames,duration,codec_name rtmp://localhost:1935/$1/$2);
codecn=${streams_stream_0_codec_name};


curl -i http://api.eazita.com/ezsms/parameterssaver.php?width=$codecn


ffmpeg -i rtmp://localhost:1935/$1/$2 \
-c:a aac -strict -2 -b:a 32k  -c:v libx264 -b:v 128K -f flv rtmp://localhost:1935/hls/$2_low \
-c:a aac -strict -2 -b:a 64k  -c:v libx264 -b:v 256k -f flv rtmp://localhost:1935/hls/$2_mid \
-c:a aac -strict -2 -b:a 128k -c:v libx264 -b:v 512K -f flv rtmp://localhost:1935/hls/$2_hi 2> /home/nudewow/ff.txt
wait
