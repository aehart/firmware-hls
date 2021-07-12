#include "TrackBuilderTop.h"

// L1L2 TrackBuilder top function
void TrackBuilder_L1L2(
    const BXType bx,
    const TrackletParameterMemory trackletParameters[1],
    const FullMatchMemory<BARREL> barrelFullMatches[4],
    const FullMatchMemory<DISK> diskFullMatches[0],
    BXType &bx_o,
    TrackFit<4, 0>::TrackWord trackWord[kMaxProc],
    TrackFit<4, 0>::BarrelStubWord barrelStubWords[4][kMaxProc],
    TrackFit<4, 0>::DiskStubWord diskStubWords[0][kMaxProc]
)
{
#pragma HLS inline recursive
#pragma HLS array_partition variable=trackletParameters complete dim=1
#pragma HLS array_partition variable=barrelFullMatches complete dim=1
#pragma HLS array_partition variable=diskFullMatches complete dim=1
#pragma HLS resource variable=trackletParameters.get_mem() latency=2
#pragma HLS resource variable=barrelFullMatches.get_mem() latency=2
#pragma HLS resource variable=diskFullMatches.get_mem() latency=2
#pragma HLS interface register port=bx_o
#pragma HLS array_partition variable=barrelStubWords complete dim=1
#pragma HLS array_partition variable=diskStubWords complete dim=1
#pragma HLS stream variable=trackWord depth=1 dim=1
#pragma HLS stream variable=barrelStubWords depth=1 dim=2
#pragma HLS stream variable=diskStubWords depth=1 dim=2

  TrackBuilder<4, 0, 4, 0>(
      bx,
      trackletParameters,
      barrelFullMatches,
      diskFullMatches,
      bx_o,
      trackWord,
      barrelStubWords,
      diskStubWords
  );
}
