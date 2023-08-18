# install yum install *GTK3* *X11* *Xmu* *builddep*
./configure --prefix=$HOME/.local \
   --with-features=huge \
   --enable-multibyte \
   --with-python3-command=python3.6  \
   --enable-rubyinterp \
   --enable-pythoninterp \
   --enable-luainterp \
   --enable-gui=gtk2 \
   --enable-python3interp=yes  \
   --enable-cscope
#make 
mkdir -p $HOME/.local
#make install
