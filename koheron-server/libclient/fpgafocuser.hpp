/// (c) Koheron

#ifndef __DRIVER_CAMERA_HPP__
#define __DRIVER__CAMERA_HPP__
#include <stdint.h>
#include <stdio.h>
#include <array>


class indi_focuser_interface {
 public:
  indi_focuser_interface(const char* host, int port);
  ~indi_focuser_interface();

  bool Initialize();
  uint32_t BoardVersion();
  bool SetGridPerRevolution(uint32_t val);
  uint32_t GetGridPerRevolution();
  uint32_t GetTimerInterruptFreq();
  bool StopFocuser(bool instant);
  bool SetFocuserPosition(uint32_t value);
  uint32_t GetFocuserPosition();
  std::array<bool, 8> GetFocuserAxisStatus();
  bool FocuserIncrement(uint32_t ncycles, uint32_t period_ticks, bool direction);
  bool FocuserGotoTarget(uint32_t target, uint32_t period_ticks, bool direction);
  bool FocuserSlewTo(uint32_t period_ticks, bool direction);
  uint32_t GetFocuserHomePosition();
  float GetTemp_fpga(uint32_t channel);
  float GetTemp_pi1w();
  bool SetFocuserMotorType(bool is_tmc);
  bool GetFocuserMotorType();

  uint32_t get_maximum_period(); 
  uint32_t get_minimum_period(); 
  bool enable_backlash(bool enable); 
  bool set_backlash_period(uint32_t ticks);
  bool set_backlash_cycles(uint32_t cycles);
  uint32_t get_backlash_period();
  uint32_t get_backlash_cycles();
  void set_debug(bool val);
  bool save_config();
  bool set_steps_per_rotation_params(uint8_t rev, uint8_t usteps, 
          uint8_t mount_gear, uint8_t high_gear, uint32_t low_gear);
  std::array<uint32_t, 5> get_steps_per_rotation_params();

  uint32_t get_motor_mode();
  bool set_motor_mode(uint8_t val);
 private:
};

#endif  // __DRIVER_HPP__
