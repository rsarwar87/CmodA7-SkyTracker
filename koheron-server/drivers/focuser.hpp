/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_FOCUSER_INTERFACE_HPP__
#define __DRIVERS_FOCUSER_INTERFACE_HPP__

#include <context.hpp>
#include <sky-tracker.hpp>

using namespace std::chrono_literals;
constexpr size_t axis = 2;
class FocuserInterface {
 public:
  FocuserInterface(Context& ctx_)
      : ctx(ctx_),
        sti(ctx.get<SkyTrackerInterface>()) {

  }

  bool Initialize() {
    bool ret = true;
    {
      ret &= sti.disable_raw_tracking(axis, false);
      ret &= sti.disable_raw_backlash(axis);
      ret &= sti.cancel_raw_command(axis, false);
      ret &= sti.set_current_position(axis, sti.get_steps_per_rotation(axis)/2);
    }
    if (ret)
      ctx.log<INFO>("FocuserInteface: %s Successful\n", __func__);
    else
      ctx.log<ERROR>("FocuserInteface: %s Failed\n", __func__);
    sti.set_init(axis, ret);
    return ret;
  }

  uint32_t BoardVersion() {
    ctx.log<INFO>("FocuserInteface: %s\n", __func__);
    return sti.get_version();
  }

  uint32_t GetGridPerRevolution() {
    return sti.get_steps_per_rotation(axis);
  }

  uint32_t GetTimerInterruptFreq() {
    return prm::fclk0;
  }

  bool StopFocuser(bool instant) {
    ctx.log<INFO>("FocuserInteface: %s(%u)- isInstant: %u\n", __func__, axis, instant);
    uint32_t status = sti.get_raw_status(axis);
    bool ret = true;
    if ((status & 0x1) == 1) ret = sti.disable_raw_tracking(axis, instant);
    if (status > 1) ret = sti.cancel_raw_command(axis, instant);
    return ret;
  }

  bool SetFocuserPosition(uint32_t value) {
    return sti.set_current_position(axis, value);
  }

  uint32_t GetFocuserPosition() {
    return sti.get_raw_stepcount(axis);
  }

  std::array<bool, 8> GetFocuserAxisStatus() {
    // Initialized, running, direction, speedmode, isGoto, isSlew
    uint32_t status = sti.get_raw_status(axis);
    bool isGoto = (status >> 1) & 0x1;
    bool isSlew = status & 0x1;
    bool fault = (status >> 3) & 0x1;
    bool backlash = (status >> 4) & 0x1;
    bool direction = sti.get_motor_direction(axis, !isGoto);
    bool running = isGoto || isSlew;
    bool speedmode = sti.get_motor_highspeedmode(axis, isSlew);
    std::array<bool, 8> ret = { sti.get_init(axis),  running,
      direction, speedmode, isGoto, isSlew, backlash, fault
    };
    return ret;
  }

  bool FocuserIncrement(uint32_t ncycles, uint32_t period_ticks, bool direction) {
    uint32_t isSlew = false;
    bool use_acceleration = true;
    bool is_goto = false;
    if (!sti.set_goto_increment(axis, ncycles)) return false;
    if (!sti.set_motor_period_ticks(axis, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(axis, isSlew, direction)) return false;
    return sti.send_command(axis, use_acceleration, is_goto);
  }

  bool FocuserGotoTarget(uint32_t target, uint32_t period_ticks, bool direction) {
    uint32_t isSlew = false;
    bool use_acceleration = true;
    bool is_goto = true;
    if (!sti.set_goto_target(axis, target)) return false;
    if (!sti.set_motor_period_ticks(axis, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(axis, isSlew, direction)) return false;
    return sti.send_command(axis, use_acceleration, is_goto);
  }

  bool FocuserSlewTo(uint32_t period_ticks, bool direction) {
    uint32_t isSlew = true;
    if (!sti.set_motor_period_ticks(axis, isSlew, period_ticks)) return false;
    if (!sti.set_motor_direction(axis, isSlew, direction)) return false;
    return sti.start_tracking(axis);
  }

  uint32_t GetFocuserHomePosition() {
    return sti.get_steps_per_rotation(axis)/2;
  }

 private:
  Context& ctx;
  SkyTrackerInterface& sti;





    
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
