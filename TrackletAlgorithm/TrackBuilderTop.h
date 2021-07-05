#ifndef TrackletAlgorithm_TrackBuilderTop_h
#define TrackletAlgorithm_TrackBuilderTop_h

#include "TrackBuilder.h"

// L1L2 TrackBuilder top function
void TrackBuilder_L1L2(
    const BXType bx,
    const TrackletParameterMemory trackletParameters[],
    const FullMatchMemory<BARREL> barrelFullMatches[],
    const FullMatchMemory<DISK> diskFullMatches[],
    BXType &bx_o,
    TrackFit<4, 4>::TrackWord trackWord[],
    TrackFit<4, 4>::BarrelStubWord barrelStubWords[][kMaxProc],
    TrackFit<4, 4>::DiskStubWord diskStubWords[][kMaxProc]
);

#endif
