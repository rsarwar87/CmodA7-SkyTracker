/// (c) Koheron

#ifndef __DRIVER_CAMERA_HPP__
#define __DRIVER_CAMERA_HPP__
#include <stdint.h>
#include <stdio.h>
#include <array>


class indi_cameratrigger_interface {
 public:
  indi_cameratrigger_interface(const char* host, int port);
  ~indi_cameratrigger_interface();

  bool set_cameratrigger_reg(uint8_t val, bool fpga = false);
  uint8_t get_cameratrigger_reg();
  bool open_shutter(bool fpga = false);
  bool close_shutter(bool fpga = false);

 private:
};

#endif  // __DRIVER_HPP__
