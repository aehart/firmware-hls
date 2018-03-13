# generate project, run with vivado_hls -f <filename>
# warning, this will wipe out the original project by the same name

#set part "xc7vx690tffg1927-2"
#set part "xcku115-flvb2104-1-i"

set clockperiod 4

# better to delete to remove stale csim output
delete_project GenProj
open_project -reset GenProj
set_top TopLevel

# source files
add_files TopLevel.cc
add_files OneToThree.cc
add_files TwoToOne.cc
add_files -tb -cflags "-I." TestBench.cc

# add data files
#add_files -tb inputs.dat



# solutions
############################################################
# solution 1
open_solution "solution1"

#set_directive_inline "VMRouter"

set_part  $part 
create_clock -period $clockperiod -name default
csim_design -O
csynth_design


#cosim_design
#export_design -format ip_catalog

# exit vivado_hls
quit
