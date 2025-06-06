#ifndef PRBUFFERARRAY_HH
#define PRBUFFERARRAY_HH

#include "ProjectionRouterBuffer.h"
#include "MatchEngineUnit_parameters.h"

template<int kNBitsBuffer, int VMProjType, int AllProjectionType> class ProjectionRouterBufferArray {
public:
  inline ProjectionRouterBuffer<VMProjType,AllProjectionType> read() {
#pragma HLS inline
#pragma HLS ARRAY_PARTITION variable=projbuffer_
    return projbuffer_[readptr_++];
  }

  inline ProjectionRouterBuffer<VMProjType,AllProjectionType> peek() {
#pragma HLS inline
#pragma HLS ARRAY_PARTITION variable=projbuffer_
    return projbuffer_[readptr_];
  }

  inline void advance() {
#pragma HLS inline
#pragma HLS ARRAY_PARTITION variable=projbuffer_
    readptr_++;
  }



  inline void saveProjection(ProjectionRouterBuffer<VMProjType,AllProjectionType> &proj) {
#pragma HLS inline
#pragma HLS array_partition variable=projbuffer_
    projbuffer_[writeptr_] = proj;
  }

  inline void incProjection() {
#pragma HLS inline
    writeptr_++;
  }

  inline bool empty() { 
    static const EmptyUnitClass<kNBitsBuffer> EmptyUnitClass;
    return EmptyUnitClass.lut[(readptr_, writeptr_)];
    //return emptyUnitBool<kNBitsBuffer>(readptr_, writeptr_);
  }

  bool nearFull() {
    return nearFullUnitBool<kNBitsBuffer>(readptr_, writeptr_);
  }

  ap_uint<kNBitsBuffer> getReadPtr() {
    return readptr_;
  }

  ap_uint<kNBitsBuffer> getWritePtr() {
    return writeptr_;
  }

  inline void reset() {
#pragma HLS inline
    readptr_ = 0;
    writeptr_ = 0;
  }

  ProjectionRouterBufferArray() {
    reset();
  }

private:
  ap_uint<kNBitsBuffer> readptr_ = 0;
  ap_uint<kNBitsBuffer> writeptr_ = 0;
  ProjectionRouterBuffer<VMProjType,AllProjectionType> projbuffer_[1<<kNBitsBuffer];
  ap_uint<(1 << (2 * kNBitsBuffer))> nearFullLUT = nearFullUnit<kNBitsBuffer>();

};

#endif
