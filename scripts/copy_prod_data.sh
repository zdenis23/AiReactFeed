scp -rp pi@192.168.1.201:/mnt/ssd/rss_ai ./data
mv ./data/rss_ai/* ./data/
rm -r ./data/rss_ai
