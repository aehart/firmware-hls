#this XDC contains physical constraints for the second FPGA project

#Payload false paths - should this be moved?

set_false_path -through [get_nets payload/sp2_mem_writer_1/HLS_reset]

#normal delete_pblocks
delete_pblocks -quiet pblock_payload_MPL1A pblock_payload_MPL1B pblock_payload_MPL1C pblock_payload_MPL1D pblock_payload_MPL1E pblock_payload_MPL1F pblock_payload_MPL1G pblock_payload_MPL1H pblock_payload_MPL2A pblock_payload_MPL2B pblock_payload_MPL2C pblock_payload_MPL2D pblock_payload_MPL3A pblock_payload_MPL3B pblock_payload_MPL3C pblock_payload_MPL3D pblock_payload_MPL4A pblock_payload_MPL4B pblock_payload_MPL4C pblock_payload_MPL4D pblock_payload_MPL5A pblock_payload_MPL5B pblock_payload_MPL5C pblock_payload_MPL5D pblock_payload_MPL6A pblock_payload_MPL6B pblock_payload_MPL6C pblock_payload_MPL6D pblock_payload_MPD1A pblock_payload_MPD1B pblock_payload_MPD1C pblock_payload_MPD1D pblock_payload_MPD2A pblock_payload_MPD2B pblock_payload_MPD2C pblock_payload_MPD2D pblock_payload_MPD3A pblock_payload_MPD3B pblock_payload_MPD3C pblock_payload_MPD3D pblock_payload_MPD4A pblock_payload_MPD4B pblock_payload_MPD4C pblock_payload_MPD4D pblock_payload_MPD5A pblock_payload_MPD5B pblock_payload_MPD5C pblock_payload_MPD5D pblock_payload_ASin
delete_pblocks -quiet pblock_payload_FTAAAA pblock_payload_FTBBBB pblock_payload_KF pblock_payload_KFout
delete_pblocks -quiet pblock_payload_PCVMSMERDs pblock_payload_PCVMSMERLs pblock_payload_sp2_mem_writer

# -----------------------------------------------------------------------------
# add_rects_to_pblock --
#
# Adds a set of rectangular ranges of sites to a pblock.
# The ranges are passed in a dictionary. Only the ranges matching the user-defined patterns are added
# This is modified from the EMP central version to include URAMs
#
# Arguments:
#   aPBlock The pblock
#   aRects Dictionary of rectangular areas
# Results:
#   The result is that of the command being redone. Also repla
proc add_rects_to_pblock_mod {aPBlock aRects} {

    set lSitePatterns [list SLICE DSP* URAM* RAM* GT*CHANNEL*]

    set lToAdd [list]
    foreach lType $lSitePatterns {
        dict for {lId lRange} [dict filter $aRects key $lType] {
            lappend lToAdd $lRange
        }
    }

    puts "Adding to $aPBlock rectangles $lToAdd"
    resize_pblock $aPBlock -add $lToAdd
}

proc add_uram_rects_to_pblock {aPBlock aRects} {

    set lSitePatterns [list URAM*]

    set lToAdd [list]
    foreach lType $lSitePatterns {
        dict for {lId lRange} [dict filter $aRects key $lType] {
            lappend lToAdd $lRange
        }
    }

    puts "Adding to $aPBlock URAM rectangles $lToAdd"
    resize_pblock $aPBlock -add $lToAdd
}

proc add_bram_rects_to_pblock {aPBlock aRects} {

    set lSitePatterns [list RAM*]

    set lToAdd [list]
    foreach lType $lSitePatterns {
        dict for {lId lRange} [dict filter $aRects key $lType] {
            lappend lToAdd $lRange
        }
    }

    puts "Adding to $aPBlock URAM rectangles $lToAdd"
    resize_pblock $aPBlock -add $lToAdd
}

proc add_nonram_rects_to_pblock {aPBlock aRects} {

    set lSitePatterns [list SLICE DSP*]

    set lToAdd [list]
    foreach lType $lSitePatterns {
        dict for {lId lRange} [dict filter $aRects key $lType] {
            lappend lToAdd $lRange
        }
    }

    puts "Adding to $aPBlock rectangles $lToAdd"
    resize_pblock $aPBlock -add $lToAdd
}

#these are from region_constraints_toolbox (called in ex. area_constraints.tcl)
#maybe one day actually make some method that emulates the logic in 
#create_quad_pblocks that automates the calculation in case something changes, 
#but certainly don't want to re-call create_quad_pblocks
set lLeftBoundary 851
set lRightBoundary 4278

# SectorProcessor pblock

set lpblock_payload_SP [create_pblock SectorProcessor]
add_cells_to_pblock [get_pblocks SectorProcessor] [get_cells -quiet payload/tf2_wrapper_1/SectorProcessor_1]

# KF pblock

set lpblock_payload_KF [create_pblock pblock_payload_KF]
add_cells_to_pblock [get_pblocks pblock_payload_KF] [get_cells -quiet [list \
          payload/kf_wrapper_1/kf_top_1 \
          payload/kf_wrapper_1/kfin_top_1 \
          payload/kf_wrapper_1/kf_input_merger_1 \
          ]]

#set constraints

resize_pblock $lpblock_payload_SP -add {SLR0:SLR1}
resize_pblock $lpblock_payload_KF -add {SLR2}

#change only payload pblocks to be hard constraints
set_property IS_SOFT FALSE [get_pblocks pblock_payload_*]
