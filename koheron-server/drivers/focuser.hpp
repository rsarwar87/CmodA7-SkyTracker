/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_FOCUSER_INTERFACE_HPP__
#define __DRIVERS_FOCUSER_INTERFACE_HPP__

#include <context.hpp>
#include <sky-tracker.hpp>

using namespace std::chrono_literals;
class FocuserInterface {
 public:
  FocuserInterface(Context& ctx_)
      : ctx(ctx_)
      , sti(ctx.get<SkyTrackerInterface>())
      , spi(ctx.spi.get("spidev0.0"))
  {
  }

  bool Initialize() {
    bool ret = true;
    {
      ret &= sti.disable_raw_tracking(prm::focuser_id, false);
      ret &= sti.disable_raw_backlash(prm::focuser_id);
      ret &= sti.cancel_raw_command(prm::focuser_id, false);
      ret &= sti.set_current_position(prm::focuser_id, sti.get_steps_per_rotation(prm::focuser_id)/2);
    }
    if (ret)
      ctx.log<INFO>("FocuserInteface: %s Successful\n", __func__);
    else
      ctx.log<ERROR>("FocuserInteface: %s Failed\n", __func__);
    sti.set_init(prm::focuser_id, ret);
    return ret;
  }

  uint32_t BoardVersion() {
    ctx.log<INFO>("FocuserInteface: %s\n", __func__);
    return sti.get_version();
  }

  uint32_t GetGridPerRevolution() {
    return sti.get_steps_per_rotation(prm::focuser_id);
  }

  uint32_t GetTimerInterruptFreq() {
    return prm::fclk0;
  }

  bool StopFocuser(bool instant) {
    ctx.log<INFO>("FocuserInteface: %s(%u)- isInstant: %u\n", __func__, prm::focuser_id, instant);
    uint32_t status = sti.get_raw_status(prm::focuser_id);
    bool ret = true;
    if ((status & 0x1) == 1) ret = sti.disable_raw_tracking(prm::focuser_id, instant);
    if (status > 1) ret = sti.cancel_raw_command(prm::focuser_id, instant);
    return ret;
  }

  bool SetFocuserPosition(uint32_t value) {
    return sti.set_current_position(prm::focuser_id, value);
  }

  uint32_t GetFocuserPosition() {
    return sti.get_raw_stepcount(prm::focuser_id);
  }

  std::array<bool, 8> GetFocuserAxisStatus() {
    // Initialized, running, direction, speedmode, isGoto, isSlew
    uint32_t status = sti.get_raw_status(prm::focuser_id);
    bool isGoto = (status >> 1) & 0x1;
    bool isSlew = status & 0x1;
    bool fault = (status >> 3) & 0x1;
    bool backlash = (status >> 4) & 0x1;
    bool direction = sti.get_motor_direction(prm::focuser_id, !isGoto);
    bool running = isGoto || isSlew;
    bool speedmode = sti.get_motor_highspeedmode(prm::focuser_id, isSlew);
    std::array<bool, 8> ret = { sti.get_init(prm::focuser_id),  running,
      direction, speedmode, isGoto, isSlew, backlash, fault
    };
    return ret;
  }

  bool FocuserIncrement(uint32_t ncycles, uint32_t period_ticks, bool direction) {
    uint32_t isSlew = false;
    bool use_acceleration = true;
    bool is_goto = false;
    if (!sti.set_goto_increment(prm::focuser_id, ncycles)) return false;
    if (!sti.set_motor_period_ticks(prm::focuser_id, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(prm::focuser_id, isSlew, direction)) return false;
    return sti.send_command(prm::focuser_id, use_acceleration, is_goto);
  }

  bool FocuserGotoTarget(uint32_t target, uint32_t period_ticks, bool direction) {
    uint32_t isSlew = false;
    bool use_acceleration = true;
    bool is_goto = true;
    if (!sti.set_goto_target(prm::focuser_id, target)) return false;
    if (!sti.set_motor_period_ticks(prm::focuser_id, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(prm::focuser_id, isSlew, direction)) return false;
    return sti.send_command(prm::focuser_id, use_acceleration, is_goto);
  }

  bool FocuserSlewTo(uint32_t period_ticks, bool direction) {
    uint32_t isSlew = true;
    if (!sti.set_motor_period_ticks(prm::focuser_id, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(prm::focuser_id, isSlew, direction)) return false;
    return sti.start_tracking(prm::focuser_id);
  }

  uint32_t GetFocuserHomePosition() {
    return sti.get_steps_per_rotation(prm::focuser_id)/2;
  }

  uint32_t GetTemp(uint32_t channel)
  {
    spi.write_at<reg::temp_channel/4, mem::control_addr, 1> (&channel);
    uint32_t ret;
    spi.read_at<reg::temp_sensor/4, mem::status_addr, 1> (&ret);
    ctx.log<INFO>("FocuserInteface: %s: %u\n", __func__, ret);
    return ret;
  }

  bool set_min_period(double val_usec) {
    return sti.set_min_period(prm::focuser_id, val_usec);
  }
  bool set_max_period(double val_usec) {
    return sti.set_max_period(prm::focuser_id, val_usec);
  }
  uint32_t get_min_period_ticks() {
    return sti.get_min_period_ticks(prm::focuser_id);
  }
  uint32_t get_max_period_ticks() {
    return sti.get_max_period_ticks(prm::focuser_id);
  }
 private:
  Context& ctx;
  SkyTrackerInterface& sti;
  SpiDev& spi;





    
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
