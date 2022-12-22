# install yum install *GTK3* *X11* *Xmu* *builddep*
./configure --prefix=$HOME/.local \
   --with-features=huge --enable-multibyte \
   --with-python3-command=python3.6  \
   --enable-rubyinterp --enable-pythoninterp --enable-luainterp --enable-gui=auto \
   --enable-python3interp=yes  \
   --enable-gui=gtk3
