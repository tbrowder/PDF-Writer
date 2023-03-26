ARGS="-n -d"

TXT1=./treg.asc
TXT2=./tlong.asc
TXT3=./tlines.asc

#./tscript.p6 $ARGS $TXT1
./tscript.p6 $ARGS $TXT3
exit

TXTS="\
./treg.asc \
./tlong.asc \
"
for t in $TXTS
do
    echo "=== Working file $t..."
    ./tscript.p6 $ARGS $t
done
