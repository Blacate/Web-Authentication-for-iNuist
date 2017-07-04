time=$(date +%s | cut -b1-13)
if [ "${#time}" = "13" ];then
    timestamp=${time}
else
    timestamp=${time}000
fi
echo $timestamp