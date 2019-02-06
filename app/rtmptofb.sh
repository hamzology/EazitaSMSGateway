

rtmp {
    server {
        listen 1935;
        chunk_size 4000;
        ping 15s;
        ping_timeout 10s;
        
        application srcx {
            live on;
            drop_idle_publisher 15s;
            exec_push ffmpeg -i rtmp://localhost:1935/srcx/$name -c:a copy -c:v libx264 -preset fast -x264-params keyint=96:min-keyint=96:scenecut=0 -r 30 -framerate 30 -g 96 -minrate 500k -maxrate 2000k -bufsize 500k -vf "scale='if(gt(a,4/3),854,-1)':'if(gt(a,4/3),-1,480)'" -threads 3 -f flv "rtmp://live-api-s.facebook.com:80/rtmp/2489465861127833?s_sw=0&s_vt=api-s&a=AbxnEVmKj99Vb1Fk"
        }
    }
}
