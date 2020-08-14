/// Led Blinker driver
///
/// (c) Koheron

#ifndef __CAMERA_INTERFACE_HPP__
#define __CAMERA_INTERFACE_HPP__

#include <context.hpp>
#include <rpigpio_trigger.hpp>

using namespace std::chrono_literals;
class CameraInterface {
 public:
  CameraInterface(Context& ctx_)
      : ctx(ctx_),
      spi(ctx.spi.get("spidev0.0"))
  {
    pi = make_unique<PiCameraTrigger>("RPI@21");
  }

  bool set_cameratrigger_reg(uint8_t val, bool fpga){
    if (!fpga) {
      if (val > 1) open_shutter(fpga);
      else close_shutter(fpga);
    }
    else
    {
      uint32_t value = val;
      spi.write_at<reg::camera_trigger/4, mem::control_addr, 1> (&value); 
    }
    ctx.log<INFO>("CameraInterface: %s=0x%08x\n", __func__, val);
    return true;
  }
  uint8_t get_cameratrigger_reg(){
    uint32_t ret = 0;
    spi.read_at<reg::camera_trigger/4, mem::control_addr, 1> (&ret);
    ctx.log<INFO>("CameraInterface: %s=0x%08x\n", __func__, ret);
    return ret; 
  }
  bool open_shutter(bool fpga){
    if (fpga)
    {
      uint32_t value = 0x1;
      spi.write_at<reg::camera_trigger/4, mem::control_addr, 1> (&value); 
      value = 0x3;
      spi.write_at<reg::camera_trigger/4, mem::control_addr, 1> (&value); 
      spi.read_at<reg::camera_trigger/4, mem::control_addr, 1> (&value);
      ctx.log<INFO>("CameraInterface: %s=0x%08x\n", __func__, value);
    }
    else
    {
    }
    return true;
  }
  bool close_shutter(bool fpga){
    if (fpga)
    {
      uint32_t value = 0x1;
      spi.write_at<reg::camera_trigger/4, mem::control_addr, 1> (&value); 
      value = 0x0;
      spi.write_at<reg::camera_trigger/4, mem::control_addr, 1> (&value); 
      spi.read_at<reg::camera_trigger/4, mem::control_addr, 1> (&value);
      ctx.log<INFO>("CameraInterface: %s=0x%08x\n", __func__, value);
    }
    else
    {
    }
    return true;
  }


 private:
  Context& ctx;
  SpiDev& spi;
  std::unique_ptr<PiCameraTrigger> pi;
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
