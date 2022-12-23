function wget4me() {
    urltype=$1
    url=$2

    if [[ $urltype == "tar" ]]; then
       tarfile=$(basename $url)
       if [[ ! -e $tarfile ]]; then
          echo "Info: wgetting $url"
          wget $url --no-check-certificate > $tarfile.wget.log 2>&1
          echo "Info: expanding $tarfile"
          tar -xvf $tarfile > $tarfile.tar.log 2>&1
       fi
    fi
}
