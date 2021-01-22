/// (c) Koheron

#ifndef __DRIVER_HPP__
#define __DRIVER_HPP__
#include <stdint.h>
#include <stdio.h>
#include <array>


class ASCOM_sky_interface {
 public:
  ASCOM_sky_interface(const char* host, int port);
  ~ASCOM_sky_interface();

  void set_debug(bool val);
  // SetPolarScopeLED          = 'V',
  bool SwpSetPolarScopeLED(uint8_t val, bool fpga = false);
  uint32_t SwpGetFeature(uint8_t axis);
  // SetFeatureCmd             = 'W', // EQ8/AZEQ6/AZEQ5 only
  bool SwpSetFeature(uint8_t axis, uint8_t cmd);
  // GetFeatureCmd             = 'q', // EQ8/AZEQ6/AZEQ5 only
  // InquireAuxEncoder         = 'd', // EQ8/AZEQ6/AZEQ5 only
  uint32_t SwpGetAuxEncoder(uint8_t axis);
  // GetHomePosition           = 'd', // Get Home position encoder count
  // (default at startup)
  // not used in eqmod
  uint32_t SwpGetHomePosition(uint8_t axis);
  // StartMotion               = 'J', // start
  bool SwpCmdStartMotion(uint8_t axis, bool isSlew, bool use_accel, bool isGoto);
  // SetStepPeriod             = 'I', //set slew speed
  bool SwpSetStepPeriod(uint8_t axis, bool isSlew, uint32_t period_usec);
  // SetGotoTarget             = 'S', // does nothing??
  bool SwpSetGotoTarget(uint8_t axis, uint32_t target);
  // SetBreakStep              = 'U', // does nothing??
  bool SwpSetBreakStep(uint8_t axis, uint32_t ncycles);
  // NOT SURE SetBreakPointIncrement    = 'M',
  // does nothing ??
  bool SwpSetBreakPointIncrement(uint8_t axis, uint32_t ncycles);
  // set goto target - SetGotoTargetIncrement    = 'H', // set goto position
  bool SwpSetGotoTargetIncrement(uint8_t axis, uint32_t ncycles);
  // SetMotionMode             = 'G', mode and direction
  bool SwpSetMotionModeDirection(uint8_t axis, bool isForward, bool isSlew,
                                   bool isHighSpeed);
  // GetAxisStatus             = 'f',
  std::array<bool, 8> SwpGetAxisStatus(uint8_t axis);
  // GetAxisPosition           = 'j', // current position
  uint32_t SwpGetAxisPosition(uint8_t axis); 
  // SetAxisPositionCmd        = 'E', set current position
  bool SwpSetAxisPosition(uint8_t axis, uint32_t value);
  // InstantAxisStop (L) + NotInstantAxisStop (K)
  bool SwpCmdStopAxis(uint8_t axis, bool instant);
  // Encoder stuff (g) // speed scalar for high speed skew
  // InquireHighSpeedRatio     = 'g',
  double SwpGetHighSpeedRatio(uint8_t axis);
  // InquireTimerInterruptFreq = 'b', // sidereal rate of axis   steps per
  // worm???
  uint32_t SwpGetTimerInterruptFreq();
  // InquireGridPerRevolution  = 'a', // steps per axis revolution
  uint32_t SwpGetGridPerRevolution(uint8_t axis);
  // InquireMotorBoardVersion  = 'e',
  uint32_t SwpGetBoardVersion();
  // Initialize                = 'F',
  bool SwpCmdInitialize(uint8_t axis);
  bool cmd_enable_backlash(uint8_t axis, bool enable);
  bool cmd_set_backlash_period(uint8_t axis, uint32_t ticks);
  bool cmd_set_backlash_cycles(uint8_t axis, uint32_t ticks);
  //bool set_backlash(uint8_t axis, double period_usec, uint32_t cycles);
  uint32_t get_forty_two();
  uint64_t get_dna();
  void print_status(std::string fname, std::string str);
  void print_error(std::string fname, std::string str);
  uint32_t get_minimum_period(uint8_t axis);
  uint32_t get_maximum_period(uint8_t axis);

  bool SwpGetMotorType(uint8_t axis);
  bool SwpSetMotorType(uint8_t axis, bool enable);
  bool set_minimum_period(uint8_t axis, uint32_t val);
  bool set_maximum_period(uint8_t axis, uint32_t val);
  bool set_mode(uint8_t axis, uint8_t val);
  bool set_steps_per_rotation(uint8_t axis, uint32_t val);
 private:
};

#endif  // __DRIVER_HPP__
