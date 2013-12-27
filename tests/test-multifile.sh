#!/bin/sh 
# test the multifile 

case x"$srcdir" in 
  x)
    echo No srcdir specified. Assuming $0 is run locally
    DMPDIR=.
    TCPFLOW=../src/tcpflow
    ;;
  x.)
    echo srcdir is .  Assuming $0 is run locally from make check
    DMPDIR=.
    TCPFLOW=../src/tcpflow
    ;;
  *)
    echo srcdir is $srcdir Assuming $0 is run from make distcheck
    DMPDIR=../../tests/
    TCPFLOW=../../_build/src/tcpflow
    ;;
esac

echo DMPDIR=$DMPDIR
echo TCPFLOW=$TCPFLOW

# check the results
checkmd5()
{
  if [ ! -r $1 ] ; 
  then 
     echo file $1 was not created
     ls -l
     exit 1
  fi

  md5val=`openssl md5 $1 | awk '{print $2;}'`
  if [ x$2 != x$md5val ];
  then 
     echo failure:         $1
     echo expected md5:    $2 "(got '$md5val')"
     echo expected length: $3
     ls -l $1
     exit 1
  fi
}

testmd5()
{
  md5val=`openssl md5 $1 | awk '{print $2;}'`
  len=`stat -r $1  | awk '{print $8;}'`
  echo checkmd5 \"$1\" \"$md5val\" \"$len\"
}

cmd()
{
    echo $1
    if ! $1 ; then echo failed; exit 1; fi
}

# this test requires MULTIFILE
MULTIFILE=/corp/nps/packets/2013-httpxfer/multifile_25_21.pcap

if [ ! -r $MULTIFILE ]; then
  echo missing $MULTIFILE
  exit 0
fi


testlist="1 2 3 4 10 100"
deldir=yes

if test x$1 != x ; then
  echo Just testing $1
  testlist=$1
  deldir=no
fi
  
OUT=/tmp/out$$
for maxfds in $testlist
do
  /bin/rm -rf $OUT
  if test -x $OUT ; then 
    echo out directory not deleted.
    ls -l $OUT
    exit 1
  fi
  cmd="$TCPFLOW -f $maxfds -o $OUT -X $OUT/report.xml -r $MULTIFILE -a"
  $TCPFLOW -V
  echo $cmd
  if ! $cmd; then echo tcpdump failed; exit 1 ; fi
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04634" "e0971231a9473c40c2de398b73dc0d80" "3183"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04634-HTTPBODY-001.png" "9e7819dcf5f9ebff79a9d2b09caac6fc" "2947"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04637" "e24c1889394a9b693e4211c294476e5d" "6497"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04637-HTTPBODY-001.png" "b1ba2f6d2bf1adaa9ffc2208eb383844" "2943"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04637-HTTPBODY-002.png" "e55dcbaf4c9b3437b1af2764721dfcf7" "3082"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04648" "5870e48e497c50487def6714540ab7d3" "3346"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04648-HTTPBODY-001.png" "b5e24b33589a29a73709661ff7f51243" "3110"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04649" "6564a6583bb31f5fc0b97d233450a98e" "3436"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04649-HTTPBODY-001.png" "e27d7c5537b03f08cd8f80b179b9c321" "3200"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04654" "45f8461dab7b145667093aab500600bc" "896"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04654-HTTPBODY-001" "fa5c9a9bf04219147f73e4fd9f72193d" "1473"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04655" "53d401972e8b0600e6e41500dc6da31b" "668"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04655-HTTPBODY-001" "230d6a43654bc5cf8891601df7218f19" "32"
  checkmd5 "$OUT/038.122.002.045.00080-192.168.123.101.04655-HTTPBODY-002" "230d6a43654bc5cf8891601df7218f19" "32"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04646" "7f8700b151e6eb5623993eb7ca80bf7d" "26160818"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04646-HTTPBODY-001" "538ae956097d9ee5813441561ec4ad33" "26160468"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04651" "6a980b667ac975f9ce031b11d7349559" "22751630"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04651-HTTPBODY-001" "bc5222e0c58a7be607dc9ce4bf121490" "1290"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04651-HTTPBODY-002" "64576f998dde977627d8131b5aa33ee8" "4000"
  checkmd5 "$OUT/046.137.228.251.00080-192.168.123.101.04651-HTTPBODY-003" "b94ff046f678a5e89d06007ea24c57ec" "22749412"
  checkmd5 "$OUT/063.217.232.082.00443-192.168.123.101.04607" "524b5d5853191e976128502cf33f5576" "53"
  checkmd5 "$OUT/074.125.128.094.00443-192.168.123.101.04587" "6092dbf3a2098fa0fa135db550043c63" "102"
  checkmd5 "$OUT/074.125.128.125.05222-192.168.123.101.02503" "f7fef5760e6fbc27faccea641f581299" "15165"
  checkmd5 "$OUT/074.125.128.125.05222-192.168.123.101.04000" "3f0ee6e9d4c523ba8d2362e569e31035" "602"
  checkmd5 "$OUT/074.125.128.136.00443-192.168.123.101.04657" "8fbfee96d692fdd6c2e18206bc26ef83" "3217"
  checkmd5 "$OUT/074.125.128.138.00443-192.168.123.101.04586" "001a6a55b70316c68b0dbf7a2ecafe9f" "11210"
  checkmd5 "$OUT/110.045.186.224.01120-192.168.123.101.04660" "7522c09ef4414d352984f89625da3ef4" "199"
  checkmd5 "$OUT/110.045.186.224.01120-192.168.123.101.04660-HTTPBODY-001.html" "43c55722039e66f40fd12cf03d68f1e0" "23"
  checkmd5 "$OUT/110.045.186.224.01120-192.168.123.101.04661" "3b2e761992ea2aaeacf7f783fd7a354f" "178"
  checkmd5 "$OUT/110.045.186.224.01120-192.168.123.101.04661-HTTPBODY-001.html" "ecaa88f7fa0bf610a5a26cf545dcd3aa" "3"
  checkmd5 "$OUT/110.045.186.225.01120-192.168.123.101.04658" "d8a9d91e4514d98771bbcccbfa0f8309" "2148"
  checkmd5 "$OUT/110.045.186.225.01120-192.168.123.101.04658-HTTPBODY-001.html" "b4ec4bc12cf6f200acfeb0a68d373c35" "1970"
  checkmd5 "$OUT/173.194.038.190.00443-192.168.123.101.04606" "2c99627350d11352ae267b7111b36167" "102"
  checkmd5 "$OUT/182.162.057.224.00443-192.168.123.101.04595" "3403a3dcb06aeba43d503e3ea5b082f7" "53"
  checkmd5 "$OUT/182.162.057.224.00443-192.168.123.101.04598" "a8a48f227b7147ae7b47af04ceaa0878" "53"
  checkmd5 "$OUT/192.168.123.101.02503-074.125.128.125.05222" "ffcf862c8632cd11235ea8d7100fc106" "8445"
  checkmd5 "$OUT/192.168.123.101.04000-074.125.128.125.05222" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04586-074.125.128.138.00443" "7231901ed6805790ef9ae1ea8b2b16ea" "5576"
  checkmd5 "$OUT/192.168.123.101.04587-074.125.128.094.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04591-202.043.063.139.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04595-182.162.057.224.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04598-182.162.057.224.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04606-173.194.038.190.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04607-063.217.232.082.00443" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04615-074.125.128.100.00080" "93b885adfe0da089cdf634904fd59f71" "1"
  checkmd5 "$OUT/192.168.123.101.04634-038.122.002.045.00080" "a86fc704a0a8e49043a43211c56ac6f4" "749"
  checkmd5 "$OUT/192.168.123.101.04637-038.122.002.045.00080" "b0e06f173af7d6bed3a1b93358116b1e" "1493"
  checkmd5 "$OUT/192.168.123.101.04646-046.137.228.251.00080" "a0a547efbcb42b4ac1b2a74334e1be41" "893"
  checkmd5 "$OUT/192.168.123.101.04648-038.122.002.045.00080" "5c22ffaef694fd09f829563aa8cc9e3b" "752"
  checkmd5 "$OUT/192.168.123.101.04649-038.122.002.045.00080" "210ee9c362c938ef68630ebab12c4a17" "750"
  checkmd5 "$OUT/192.168.123.101.04651-046.137.228.251.00080" "49cc6cc8758ec5b605a7d6f62af291af" "2791"
  checkmd5 "$OUT/192.168.123.101.04654-038.122.002.045.00080" "bde02e78dbdc16949d2580f7c1d91099" "941"
  checkmd5 "$OUT/192.168.123.101.04655-038.122.002.045.00080" "3b4417ab638ca9120c7fb49bfeb73d4c" "2046"
  checkmd5 "$OUT/192.168.123.101.04657-074.125.128.136.00443" "fe8a9a4d79ac47ba78464ac835e32d3b" "2095"
  checkmd5 "$OUT/192.168.123.101.04658-110.045.186.225.01120" "e6493e52f04325f9a06e22dc7f977a04" "297"
  checkmd5 "$OUT/192.168.123.101.04660-110.045.186.224.01120" "dcd18bf7b6572443215154539a37d75c" "363"
  checkmd5 "$OUT/192.168.123.101.04661-110.045.186.224.01120" "d202ebd7c286d1ea4734bdbef69431c6" "323"
  checkmd5 "$OUT/202.043.063.139.00443-192.168.123.101.04591" "722c54c6443119b6c411359b9b7a47c2" "53"
  if test $deldir == "yes" ; then
    /bin/rm -rf $OUT
  fi
done
exit 0
  

