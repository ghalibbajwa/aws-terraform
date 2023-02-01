ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
out=$(/home/ubuntu/slogr -c 3.21.56.208 8009 20 50 2000 0 "echo ${ip}" 50 test1  ./ | tail -30 | head -27)
#echo $out
