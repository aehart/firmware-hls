#ifndef TrackletAlgorithm_TrackBuilder_h
#define TrackletAlgorithm_TrackBuilder_h

#include "TrackletParameterMemory.h"
#include "FullMatchMemory.h"
#include "TrackFitMemory.h"

static const unsigned short kNBitsTBBuffer = 1;
static const unsigned short kMinNMatches = 2;
static const unsigned short kInvalidTrackletID = 0x3FFF;

static const unsigned short kNBitsTCID = FullMatchBase<BARREL>::kFMTCIDSize;
static const unsigned short kNBitsITC = FullMatchBase<BARREL>::kFMITCSize;
static const unsigned short kNBitsTrackletID = kNBitsTCID + kNBits_MemAddr;

typedef ap_uint<kNBitsTCID> TCIDType;
typedef ap_uint<kNBits_MemAddr> IndexType;
typedef ap_uint<kNBitsTrackletID> TrackletIDType;

// Slim data type used to store full match information in the circular buffers.
struct MyStub {
  public:
    MyStub() {}
    MyStub(const IndexType &index, const TrackletIDType &id) {
      setIndex(index);
      setID(id);
    }
    const IndexType index() const { return data_.range(kNBits_MemAddr - 1, 0); }
    const TrackletIDType id() const { return data_.range(kNBits_MemAddr + kNBitsTrackletID - 1, kNBits_MemAddr); }
    void setIndex(const IndexType &index) { data_.range(kNBits_MemAddr - 1, 0) = index; }
    void setID(const TrackletIDType &id) { data_.range(kNBits_MemAddr + kNBitsTrackletID - 1, kNBits_MemAddr) = id; }
  private:
    ap_uint<kNBitsTrackletID + kNBits_MemAddr> data_;
};

// Function to retrieve a full match and store the associated index and
// tracklet ID in one element of a circular buffer.
template<regionType RegionType> void
getFM(const BXType bx, const FullMatchMemory<RegionType> &fullMatches, const unsigned short i, MyStub &fm)
{
  if (i < fullMatches.getEntries(bx)) {
    const auto &full_match = fullMatches.read_mem(bx, i);
    fm.setIndex(i);
    fm.setID(full_match.getTrackletID());
  }
  else {
    // If there are no more full matches, set the index and ID to dummy values.
    fm.setIndex(0);
    fm.setID(kInvalidTrackletID);
  }
}

template<unsigned T>
struct type{};

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addBarrelStub(type<NBarrelStubs - I>, const ap_uint<1> stub_valid, const FullMatch<BARREL>::FMSTUBINDEX stub_index, const FullMatch<BARREL>::FMSTUBR stub_r, const FullMatch<BARREL>::FMPHIRES phi_res, const FullMatch<BARREL>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track)
{
  track.template setBarrelStub<I>(stub_valid, stub_index, stub_r, phi_res, z_res);
}

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addDiskStub(type<NDiskStubs - I>, const ap_uint<1> stub_valid, const FullMatch<DISK>::FMSTUBINDEX stub_index, const FullMatch<DISK>::FMSTUBR stub_r, const FullMatch<DISK>::FMPHIRES phi_res, const FullMatch<DISK>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track)
{
  track.template setDiskStub<NBarrelStubs + I>(stub_valid, stub_index, stub_r, phi_res, z_res);
}

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addBarrelStub(type<0>, const ap_uint<1> stub_valid, const FullMatch<BARREL>::FMSTUBINDEX stub_index, const FullMatch<BARREL>::FMSTUBR stub_r, const FullMatch<BARREL>::FMPHIRES phi_res, const FullMatch<BARREL>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track) {}

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addDiskStub(type<0>, const ap_uint<1> stub_valid, const FullMatch<DISK>::FMSTUBINDEX stub_index, const FullMatch<DISK>::FMSTUBR stub_r, const FullMatch<DISK>::FMPHIRES phi_res, const FullMatch<DISK>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track) {}

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addBarrelStub(type<0>, const ap_uint<1> stub_valid, const FullMatch<DISK>::FMSTUBINDEX stub_index, const FullMatch<DISK>::FMSTUBR stub_r, const FullMatch<DISK>::FMPHIRES phi_res, const FullMatch<DISK>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track) {}

template<unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs> void
addDiskStub(type<0>, const ap_uint<1> stub_valid, const FullMatch<BARREL>::FMSTUBINDEX stub_index, const FullMatch<BARREL>::FMSTUBR stub_r, const FullMatch<BARREL>::FMPHIRES phi_res, const FullMatch<BARREL>::FMZRES z_res, TrackFit<NBarrelStubs, NDiskStubs> &track) {}

template<unsigned FMTYPE, unsigned I, unsigned NBarrelStubs, unsigned NDiskStubs, unsigned NFMPerLayer, unsigned NFMPerDisk> void
addStubs(const ap_uint<1> valid[], ap_uint<3> &nMatches, const FullMatchMemory<FMTYPE> fullMatches[], const BXType bx, const IndexType index[], TrackFit<NBarrelStubs, NDiskStubs> &track)
{
    if ((FMTYPE == BARREL && I >= NBarrelStubs)
     || (FMTYPE == DISK && I >= NDiskStubs))
      return;

    constexpr unsigned NFM = (FMTYPE == BARREL ? NFMPerLayer : NFMPerDisk);

    ap_uint<1> stub_valid = false;
    stub_valid : for (short k = 0; k < NFM; k++)
      stub_valid = (stub_valid || valid[I * NFM + k]);
    nMatches += (stub_valid ? 1 : 0);

    static_assert(NFM <= 4, "Number of FM memories per layer/disk cannot exceed four.");
    const auto &stub = ((NFM > 3 && valid[I * NFM + 3]) ? fullMatches[I * NFM + 3].read_mem(bx, index[I * NFM + 3]) :
                       ((NFM > 2 && valid[I * NFM + 2]) ? fullMatches[I * NFM + 2].read_mem(bx, index[I * NFM + 2]) :
                       ((NFM > 1 && valid[I * NFM + 1]) ? fullMatches[I * NFM + 1].read_mem(bx, index[I * NFM + 1]) :
                                                          fullMatches[I * NFM].read_mem(bx, index[I * NFM]))));

    const auto &stub_index = (stub_valid ? stub.getStubIndex() : typename FullMatch<FMTYPE>::FMSTUBINDEX(0));
    const auto &stub_r     = (stub_valid ? stub.getStubR()     : typename FullMatch<FMTYPE>::FMSTUBR(0));
    const auto &phi_res    = (stub_valid ? stub.getPhiRes()    : typename FullMatch<FMTYPE>::FMPHIRES(0));
    const auto &z_res      = (stub_valid ? stub.getZRes()      : typename FullMatch<FMTYPE>::FMZRES(0));

    if (FMTYPE == BARREL)
      //track.template setBarrelStub<I>(stub_valid, stub_index, stub_r, phi_res, z_res);
      addBarrelStub<I, NBarrelStubs, NDiskStubs>(type<NBarrelStubs>{}, type<NBarrelStubs - I>{}, stub_valid, stub_index, stub_r, phi_res, z_res, track);
    else
      //track.template setDiskStub<NBarrelStubs + I>(stub_valid, stub_index, stub_r, phi_res, z_res);
      addDiskStub<I, NBarrelStubs, NDiskStubs>(type<NDiskStubs>{}, type<NDiskStubs - I>{}, stub_valid, stub_index, stub_r, phi_res, z_res, track);

    addStubs<FMTYPE, I + 1, NBarrelStubs, NDiskStubs, NFMPerLayer, NFMPerDisk>(valid, nMatches, fullMatches, bx, index, track);
}

// TrackBuilder top template function
// !!! CURRENTLY ONLY TESTED FOR L1L2 !!!
template<unsigned NFMBarrel, unsigned NFMDisk, unsigned NBarrelStubs, unsigned NDiskStubs>
void TrackBuilder(
    const BXType bx,
    const TrackletParameterMemory trackletParameters[],
    const FullMatchMemory<BARREL> barrelFullMatches[],
    const FullMatchMemory<DISK> diskFullMatches[],
    BXType &bx_o,
    typename TrackFit<NBarrelStubs, NDiskStubs>::TrackWord trackWord[],
    typename TrackFit<NBarrelStubs, NDiskStubs>::BarrelStubWord barrelStubWords[][kMaxProc],
    typename TrackFit<NBarrelStubs, NDiskStubs>::DiskStubWord diskStubWords[][kMaxProc]
)
{

  constexpr unsigned NFMPerLayer = (NBarrelStubs > 0) ? (NFMBarrel / NBarrelStubs) : 0;
  constexpr unsigned NFMPerDisk = (NDiskStubs > 0) ? (NFMDisk / NDiskStubs) : 0;

  // Circular buffers for each of the input full-match memories.
  MyStub barrel_fm[NFMBarrel][1<<kNBitsTBBuffer];
  MyStub disk_fm[NFMDisk][1<<kNBitsTBBuffer];
#pragma HLS array_partition variable=barrel_fm complete dim=0
#pragma HLS array_partition variable=disk_fm complete dim=0

  // Read and write indices for the circular buffers.
  ap_uint<kNBits_MemAddr> barrel_mem_index[NFMBarrel];
  ap_uint<kNBits_MemAddr> disk_mem_index[NFMDisk];
  ap_uint<kNBitsTBBuffer> barrel_read_index[NFMBarrel];
  ap_uint<kNBitsTBBuffer> disk_read_index[NFMDisk];
  ap_uint<kNBitsTBBuffer> barrel_write_index[NFMBarrel];
  ap_uint<kNBitsTBBuffer> disk_write_index[NFMDisk];

  initialize_barrel_indices : for (short i = 0; i < NFMBarrel; i++) {
#pragma HLS unroll
    barrel_mem_index[i] = 0;
    barrel_read_index[i] = 0;
    barrel_write_index[i] = 0;
  }

  initialize_disk_indices : for (short i = 0; i < NFMDisk; i++) {
#pragma HLS unroll
    disk_mem_index[i] = 0;
    disk_read_index[i] = 0;
    disk_write_index[i] = 0;
  }

  IndexType nTracks = 0;

  full_matches : for (unsigned short i = 0; i < kMaxProc; i++) {
#pragma HLS pipeline II=1 rewind

    const ap_uint<1> empty = (i == 0);
    TrackletIDType min_id = kInvalidTrackletID;
    IndexType barrel_index[NFMBarrel];
    IndexType disk_index[NFMDisk];
    ap_uint<1> barrel_valid[NFMBarrel];
    ap_uint<1> disk_valid[NFMDisk];
#pragma HLS array_partition variable=barrel_index complete dim=0
#pragma HLS array_partition variable=disk_index complete dim=0
#pragma HLS array_partition variable=barrel_valid complete dim=0
#pragma HLS array_partition variable=disk_valid complete dim=0

    // First determine the minimum tracklet ID from the current set of full
    // matches.
    barrel_min_id : for (short j = 0; j < NFMBarrel; j++) {

      const auto &barrel_stub_0 = barrel_fm[j][barrel_read_index[j]];
      const auto &barrel_id_0 = barrel_stub_0.id();
      barrel_index[j] = barrel_stub_0.index();
      barrel_valid[j] = (!empty && barrel_id_0 != kInvalidTrackletID);

      // Compare the given barrel and disk IDs against each barrel ID.
      barrel_barrel_id_comp : for (short k = 0; k < NFMBarrel; k++) {
        const auto &barrel_stub_1 = barrel_fm[k][barrel_read_index[k]];
        const auto &barrel_id_1 = barrel_stub_1.id();
        barrel_valid[j] = (barrel_valid[j] && barrel_id_0 <= barrel_id_1);
      }
      // Compare the given barrel and disk IDs against each disk ID.
      barrel_disk_id_comp : for (short k = 0; k < NFMDisk; k++) {
        const auto &disk_stub_1 = disk_fm[k][disk_read_index[k]];
        const auto &disk_id_1 = disk_stub_1.id();
        barrel_valid[j] = (barrel_valid[j] && barrel_id_0 <= disk_id_1);
      }

      min_id = (barrel_valid[j] ? barrel_id_0 : min_id);
    }

    disk_min_id : for (short j = 0; j < NFMDisk; j++) {

      const auto &disk_stub_0 = disk_fm[j][disk_read_index[j]];
      const auto &disk_id_0 = disk_stub_0.id();
      disk_index[j] = disk_stub_0.index();
      disk_valid[j] = (!empty && disk_id_0 != kInvalidTrackletID);

      // Compare the given barrel and disk IDs against each barrel ID.
      disk_barrel_id_comp : for (short k = 0; k < NFMBarrel; k++) {
        const auto &barrel_stub_1 = barrel_fm[k][barrel_read_index[k]];
        const auto &barrel_id_1 = barrel_stub_1.id();
        disk_valid[j] = (disk_valid[j] && disk_id_0 <= barrel_id_1);
      }
      // Compare the given barrel and disk IDs against each disk ID.
      disk_disk_id_comp : for (short k = 0; k < NFMDisk; k++) {
        const auto &disk_stub_1 = disk_fm[k][disk_read_index[k]];
        const auto &disk_id_1 = disk_stub_1.id();
        disk_valid[j] = (disk_valid[j] && disk_id_0 <= disk_id_1);
      }

      min_id = (disk_valid[j] ? disk_id_0 : min_id);
    }

    // Initialize a TrackFit object using the tracklet parameters associated
    // with the minimum tracklet ID.
    const TCIDType &TCID = (min_id != kInvalidTrackletID) ? (min_id >> kNBits_MemAddr) : TrackletIDType(0);
    TrackFit<NBarrelStubs, NDiskStubs> track(nTracks, TCID >> kNBitsITC);
    const IndexType &trackletIndex = (min_id != kInvalidTrackletID) ? (min_id & TrackletIDType(0x7F)) : TrackletIDType(0);
    const auto &tpar = trackletParameters[TCID].read_mem(bx, trackletIndex);
    track.setRinv(tpar.getRinv());
    track.setPhi0(tpar.getPhi0());
    track.setZ0(tpar.getZ0());
    track.setT(tpar.getT());

    // Retrieve the full information for each full match that has the minimum
    // tracklet ID and assign it to the appropriate field of the TrackFit
    // object.
    ap_uint<3> nMatches = 0; // there can be up to eight matches (3 bits)
    if (NBarrelStubs > 0)
      addStubs<BARREL, 0, NBarrelStubs, NDiskStubs, NFMPerLayer, NFMPerDisk>(barrel_valid, nMatches, barrelFullMatches, bx, barrel_index, track);
    if (NDiskStubs > 0)
      addStubs<DISK, 0, NBarrelStubs, NDiskStubs, NFMPerLayer, NFMPerDisk>(disk_valid, nMatches, diskFullMatches, bx, disk_index, track);

    // Only tracks with at least two matches are valid.
    track.setTrackValid(nMatches >= kMinNMatches);

    // Output the track word and eight stub words associated with the TrackFit
    // object that was constructed.
    if (track.getTrackValid()) {
      trackWord[nTracks] = track.getTrackWord();
      barrel_stub_words: for (short j = 0 ; j < NBarrelStubs; j++) {
        switch (j) {
          case 0:
            barrelStubWords[j][nTracks] = track.template getStubValid<0>() ? track.template getBarrelStubWord<0>() : typename TrackFit<NBarrelStubs, NDiskStubs>::BarrelStubWord(0);
            break;
          case 1:
            barrelStubWords[j][nTracks] = track.template getStubValid<1>() ? track.template getBarrelStubWord<1>() : typename TrackFit<NBarrelStubs, NDiskStubs>::BarrelStubWord(0);
            break;
          case 2:
            barrelStubWords[j][nTracks] = track.template getStubValid<2>() ? track.template getBarrelStubWord<2>() : typename TrackFit<NBarrelStubs, NDiskStubs>::BarrelStubWord(0);
            break;
          case 3:
            barrelStubWords[j][nTracks] = track.template getStubValid<3>() ? track.template getBarrelStubWord<3>() : typename TrackFit<NBarrelStubs, NDiskStubs>::BarrelStubWord(0);
            break;
        }
      }
      disk_stub_words: for (short j = 0 ; j < NDiskStubs; j++) {
        switch (j) {
          case 0:
            diskStubWords[j][nTracks] = track.template getStubValid<4>() ? track.template getDiskStubWord<4>() : typename TrackFit<NBarrelStubs, NDiskStubs>::DiskStubWord(0);
            break;
          case 1:
            diskStubWords[j][nTracks] = track.template getStubValid<5>() ? track.template getDiskStubWord<5>() : typename TrackFit<NBarrelStubs, NDiskStubs>::DiskStubWord(0);
            break;
          case 2:
            diskStubWords[j][nTracks] = track.template getStubValid<6>() ? track.template getDiskStubWord<6>() : typename TrackFit<NBarrelStubs, NDiskStubs>::DiskStubWord(0);
            break;
          case 3:
            diskStubWords[j][nTracks] = track.template getStubValid<7>() ? track.template getDiskStubWord<7>() : typename TrackFit<NBarrelStubs, NDiskStubs>::DiskStubWord(0);
            break;
        }
      }
    }
    nTracks += (nMatches >= kMinNMatches ? 1 : 0);

    // Update the circular buffer indices and read a new element from each of
    // the input full-match memories.
    barrel_circular_buffer_update : for (short j = 0; j < NFMBarrel; j++) {
      barrel_read_index[j] += (barrel_valid[j] ? 1 : 0);
      const ap_uint<kNBitsTBBuffer> barrel_next_write_index = barrel_write_index[j] + 1;
      const ap_uint<1> barrel_not_full = (barrel_next_write_index != barrel_read_index[j]);
      getFM<BARREL>(bx, barrelFullMatches[j], barrel_mem_index[j], barrel_fm[j][barrel_write_index[j]]);
      barrel_mem_index[j] += ((empty || barrel_not_full) ? 1 : 0);
      barrel_write_index[j] += ((empty || barrel_not_full) ? 1 : 0);
    }

    disk_circular_buffer_update : for (short j = 0; j < NFMDisk; j++) {
      disk_read_index[j] += (disk_valid[j] ? 1 : 0);
      const ap_uint<kNBitsTBBuffer> disk_next_write_index = disk_write_index[j] + 1;
      const ap_uint<1> disk_not_full = (disk_next_write_index != disk_read_index[j]);
      getFM<DISK>(bx, diskFullMatches[j], disk_mem_index[j], disk_fm[j][disk_write_index[j]]);
      disk_mem_index[j] += ((empty || disk_not_full) ? 1 : 0);
      disk_write_index[j] += ((empty || disk_not_full) ? 1 : 0);
    }
  }

  bx_o = bx;
}

#endif
