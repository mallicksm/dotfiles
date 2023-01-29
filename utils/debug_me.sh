#!/bin/bash
PATH=$(echo $PATH|sed 's/:\/tools\/bin:/:/')
cdir=$(dirname $(realpath $0))
lwddir=/proj/acov_yorktown_rev_b/devel/mallick1/emu_ttn_a0_03/fpga/ip/emulation/build.pal_ice.Jan-21.1634pm
offline=offline.pal_ice.Jan-28.1453pm

export LM_LICENSE_FILE=/tools/cds/license.pal
LM_LICENSE_FILE+=:5280@chn-vm-clic01.microchip.com
LM_LICENSE_FILE+=:5280@chn-vm-clic02.microchip.com
LM_LICENSE_FILE+=:/tools/cds/license.mscc_wan
export CDS_LIC_FILE=$LM_LICENSE_FILE
export ARMLMD_LICENSE_FILE=27003@sjdc-cad-clic01.microchip.com

export TOOLS_CDS_ROOT=/proj/acov_yorktown_rev_a/devel/shared/cadence/installs
export INDAGO_ROOT=$TOOLS_CDS_ROOT/INDAGO2203
export XLMHOME=$TOOLS_CDS_ROOT/XCELIUM2109

LD_LIBRARY_PATH+=:$XLMHOME/tools/lib/64bit
PATH=$XLMHOME/tools/bin:$PATH
PATH=/proj/acov_yorktown_rev_a/devel/shared:$PATH

export PATH LD_LIBRARY_PATH
echo "################################################################################"
echo "Note:"
echo "dut hierarchy: emu_top.i_dut_wraper.i_pm8667."
echo "################################################################################"
xpdf $cdir/indago_gui_userguide.pdf &> /dev/null &
indago -lwd $lwddir/xc_work/lwd_work/ -db $cdir/$offline/trace.shm
