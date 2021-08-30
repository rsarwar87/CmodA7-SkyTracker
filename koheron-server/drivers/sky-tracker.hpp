/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_SKY_INTERFACE_HPP__
#define __DRIVERS_SKY_INTERFACE_HPP__

#include <context.hpp>
#include <motor_driver.hpp>
#include <params.hpp>
#include <rpigpio_ledpwm.hpp>
#include <cfg_config.hpp>

constexpr double fclk0_period_us =
      1000000.0 / ((double)(prm::fclk0));  // Number of descriptors

using namespace std::chrono_literals;
class SkyTrackerInterface {
 public:
  SkyTrackerInterface(Context& ctx_)
      : ctx(ctx_),
        spi(ctx.spi.get("spidev0.0")),
        stepper(ctx.get<MotorDriver>()) {
    ctx.log<INFO>("SkyTrackerInterface: %s Started\n", __func__);
    m_debug = false;

    cfg = make_unique<CfgConfig>("/usr/share/koheron-startracker.json", &m_params, ctx_);
    cfg->PrintData();
    cfg->PullData();


    for (size_t i = 0; i < 3; i++) {
      m_params.period_usec[0][i] = 1;     // time period in us
      m_params.period_ticks[0][i] = 100;  // time period in 20ns ticks
      m_params.speed_ratio[0][i] = 1;     // speed of motor
      m_params.period_usec[1][i] = 1;     // time period in us
      m_params.period_ticks[1][i] = 100;  // time period in 20ns ticks
      m_params.speed_ratio[1][i] = 1;     // speed of motor

      m_params.highSpeedMode_fpga[0][i] = false;
      m_params.highSpeedMode_fpga[1][i] = false;
      m_params.highSpeedMode[0][i] = false;
      m_params.highSpeedMode[1][i] = false;
      m_params.GotoTarget[i] = 0;
      m_params.GotoNCycles[i] = 0;

      m_params.minPeriod[i] = (uint32_t)((m_params.minPeriod_usec[i] / fclk0_period_us) + .5);  // slowest speed allowed
      m_params.maxPeriod[i] =
          (uint32_t)((m_params.maxPeriod_usec[i] / fclk0_period_us) + .5);  // Speed at which mount should stop. May be lower than
                    // minSpeed if doing a very slow IVal.

      m_params.motorDirection[0][i] = true;
      m_params.motorDirection[1][i] = true;

     // m_params.motorMode[0][i] = 0x07;  // microsteps 16 => //4
     // m_params.motorMode[1][i] = 0x07;  // microsteps

      m_params.versionNumber[i] = 0xd4444;  //_eVal: Version number

      set_steps_per_rotation_params(i, m_params.motor_revticks[i],
          m_params.motor_ustepping[i],
          m_params.mount_gearticks[i],
          m_params.high_gear_ticks[i],
          m_params.low_gear_ticks[i]);  //_aVal: Steps per axis revolution

      m_params.initialized[i] = false;  //_aVal: Steps per axis revolution

      set_motor_type(i, m_params.is_TMC[i]);
      set_backlash(i, 45, 300, 7);
     // set_steps_per_rotation(i, get_steps_per_rotation(i));
    }
    set_current_position(0, 0x800000);
    set_current_position(1, 0x800000);
    ctx.log<INFO>("SkyTrackerInterface: %s Finished\n", __func__);
    pi = make_unique<PiPolarLed>("RPI@0", 256);
    ctx.log<INFO>("%s(): Class initialized\n", __func__);
  }

  bool SaveConfig()
  {
    if (!cfg->PushData())
    {
      ctx.log<INFO>("SkyTrackerInterface: %s Failed to push\n", __func__);
      cfg->PrintData();
      return false;
    }
    cfg->PrintData();
    cfg->SaveFileContent();
    cfg.reset();
    cfg = make_unique<CfgConfig>("/usr/share/koheron-startracker.json", &m_params, ctx);
    return true;
  }

  bool set_led_pwm(uint8_t val, bool fpga) {
    uint32_t value = val;
    if (fpga)
      spi.write_at<reg::led_pwm/4, mem::control_addr, 1> (&value); 
    else if (pi)
      pi->set_duty(val);

    if (m_debug)
    ctx.log<INFO>("%s(): %d\n", __func__, val);
    return true;
  }
  bool set_speed_ratio(uint8_t axis, bool isSlew, double val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val < 0.25) {
      ctx.log<ERROR>("%s(%u) val out of range %9.5f\n", __func__, axis, val);
      return false;
    }
    m_params.speed_ratio[isSlew][axis] = val;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %9.5f\n", __func__, axis,
                  m_params.speed_ratio[isSlew][axis]);
    return true;
  }
  double get_speed_ratio(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return -1.;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %9.5f\n", __func__, axis,
                  m_params.speed_ratio[isSlew][axis]);
    return m_params.speed_ratio[isSlew][axis];
  }
  uint32_t get_steps_per_rotation(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.stepPerRotation[axis]);
    return m_params.stepPerRotation[axis];
  }
  std::array<uint32_t, 5> get_steps_per_rotation_params(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return std::array<uint32_t, 5> {0xfff, 0xfff, 0xfff, 0xfff, 0xfff};
    std::array<uint32_t, 5> ret = {
     m_params.motor_ustepping[axis] ,
     m_params.motor_revticks [axis]  ,
     m_params.mount_gearticks[axis] ,
     m_params.high_gear_ticks[axis] ,
     m_params.low_gear_ticks [axis] 
    };
    return ret;
  }
  bool restore_steps_per_rotation(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0) stepper.set_max_step<0>(get_steps_per_rotation(0));
    else if (axis == 2) stepper.set_max_step<2>(get_steps_per_rotation(2));
    else stepper.set_max_step<1>(get_steps_per_rotation(1));
    return true;
  }
  bool override_steps_per_rotation(uint8_t axis, uint32_t steps) {
    if (!check_axis_id(axis, __func__)) return false;
    if (steps > 0x3FFFFFFF) {
      ctx.log<ERROR>("%s(%u): %u steps (Max %u ticks)\n", __func__, axis, steps,
                     0x3FFFFFFF);
      return false;
    }
    if (axis == 0) stepper.set_max_step<0>(steps);
    else if (axis == 2) stepper.set_max_step<2>(steps);
    else stepper.set_max_step<1>(steps);
    return true;
  }
  bool set_steps_per_rotation(uint8_t axis, uint32_t steps) {
    if (!check_axis_id(axis, __func__)) return false;
    if (steps > 0x3FFFFFFF) {
      ctx.log<ERROR>("%s(%u): %u steps (Max %u ticks)\n", __func__, axis, steps,
                     0x3FFFFFFF);
      return false;
    }
    m_params.stepPerRotation[axis] = steps;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.stepPerRotation[axis]);
    if (axis == 0) stepper.set_max_step<0>(steps);
    else if (axis == 2) stepper.set_max_step<2>(steps);
    else stepper.set_max_step<1>(steps);
    return true;
  }
  bool set_steps_per_rotation_params(uint8_t axis, uint8_t rev, uint8_t usteps, 
          uint8_t mount_gear, uint8_t high_gear, uint32_t low_gear) {
    if (!check_axis_id(axis, __func__)) return false;
    if (usteps < 1 || rev < 1 || mount_gear < 1 || high_gear < 1 || low_gear < 1) {
      ctx.log<ERROR>("%s(%u): Failed to set. %u ticks/rev, %u ustepping, %u mount gear teeth," 
        "%u high gear teeth, %u low gear teeth\n", __func__, axis,
        rev, usteps, mount_gear, high_gear, low_gear);
      return false;
    }

    m_params.motor_revticks [axis] = rev;
    m_params.motor_ustepping[axis] = usteps;
    m_params.mount_gearticks[axis] = mount_gear;
    m_params.high_gear_ticks[axis] = high_gear;
    m_params.low_gear_ticks [axis] = low_gear; 
    ctx.log<INFO>("%s(%u): %u total ticks, %u ticks/rev, %u ustepping, %u mount gear teeth," 
        "%u high gear teeth, %u low gear teeth\n", __func__, axis,
        m_params.stepPerRotation[axis], m_params.motor_revticks [axis],
        m_params.motor_ustepping[axis], m_params.mount_gearticks[axis],
        m_params.high_gear_ticks[axis], m_params.low_gear_ticks [axis]);

    m_params.stepPerRotation      [axis] =
          m_params.motor_revticks [axis]*
          m_params.motor_ustepping[axis]*
          m_params.mount_gearticks[axis]*
          m_params.high_gear_ticks[axis]/
          m_params.low_gear_ticks [axis];  //_aVal: Steps per axis revolution
    //if (m_debug)
    if (axis == 0) stepper.set_max_step<0>(0xFFFFFF);
    else if (axis == 2) stepper.set_max_step<2>(m_params.stepPerRotation[2]);
    else stepper.set_max_step<1>(0xFFFFFF);
    return true;
  }

  uint32_t get_version() { return (m_params.versionNumber[0]); }
  uint32_t get_backlash_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.backlash_ticks[axis]);
    return m_params.backlash_ticks[axis];
  }
  double get_backlash_period_usec(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %9.5f us\n", __func__, axis,
                  m_params.backlash_period_usec[axis]);
    return m_params.backlash_period_usec[axis];
  }
  uint32_t get_backlash_ncycles(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u cycles\n", __func__, axis,
                  m_params.backlash_ncycle[axis]);
    return m_params.backlash_ncycle[axis];
  }
  bool set_backlash(uint8_t axis, double period_usec, uint32_t cycles, uint8_t mode) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((period_usec  / fclk0_period_us) + .5);
    if (mode > 7) {
      ctx.log<ERROR>("%s(%u): mode out of range %u (%u max)\n",
                     __func__, axis, mode, 7);
      return false;
    }
    if (_ticks > m_params.maxPeriod[axis] ||
        _ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): period out of range %9.5f usec (%u ticks)\n",
                     __func__, axis, period_usec, _ticks);
      return false;
    }
    m_params.backlash_period_usec[axis] = period_usec;
    m_params.backlash_ticks[axis] = _ticks;
    m_params.backlash_ncycle[axis] = cycles;
    m_params.backlash_mode[axis] = mode;
    if (m_debug)
    ctx.log<INFO>(
        "%s(%u): backlash period set to %9.5f us (%u ticks) for %u cycles\n",
        __func__, axis, period_usec, _ticks, cycles);
    return true;
  }
  bool set_motor_mode(uint8_t axis, bool isSlew, uint8_t val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val > 7) {
      ctx.log<ERROR>("%s(%u): invalid mode for %s (%u)\n", __func__, axis,
                     isSlew ? "Slew" : "GoTo", val);
      return false;
    }
    //if (m_debug)
    ctx.log<INFO>("%s(%u): %s mode set to %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", val);

    m_params.motorMode[isSlew][axis] = val;
    return true;
  }
  uint32_t get_motor_mode(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t ret = m_params.motorMode[isSlew][axis];
    if (m_debug)
    ctx.log<INFO>("%s(%u): %s is in %u mode\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret);
    return (ret);
  }
  bool set_motor_highspeedmode(uint8_t axis, bool isSlew, bool isHighSpeed) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.highSpeedMode[isSlew][axis] = isHighSpeed;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %s high speed = %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo",
                  isHighSpeed ? "True" : "False");
    return true;
  }
  bool get_motor_highspeedmode(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    bool ret = m_params.highSpeedMode_fpga[isSlew][axis];
    if (m_debug)
    ctx.log<INFO>("%s(%u): %s highspeed: %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret ? "True" : "False");
    return (ret);
  }
  bool set_motor_direction(uint8_t axis, bool isSlew, bool isForward) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.motorDirection[isSlew][axis] = isForward;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %s is in %s direction\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", isForward ? "Forward" : "Backward");
    return true;
  }
  bool get_motor_direction(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    bool ret = m_params.motorDirection[isSlew][axis];
    if (m_debug)
    ctx.log<INFO>("%s(%u): %s is in %s direction\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret ? "Forward" : "Backward");
    return (ret);
  }
  bool set_min_period(uint8_t axis, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((val_usec / fclk0_period_us) + .5);
    if (_ticks < 2) {
      ctx.log<ERROR>(
          "%s(%u): %9.5f usec (%u ticks). Minimum allowed is 0.05 usec\n",
          __func__, axis, val_usec, _ticks);
      return false;
    }
    m_params.minPeriod_usec[axis] = val_usec;
    m_params.minPeriod[axis] = _ticks;
    //if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks (%9.5f usec)\n", __func__, axis,
                  m_params.minPeriod[axis], val_usec);
    return true;
  }
  bool set_max_period(uint8_t axis, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val_usec > 2684354.) {
      ctx.log<ERROR>("%s(%u): %9.5f usec. Max allowed is 2683454 usec \n",
                     __func__, axis, val_usec);
      return false;
    }
    uint32_t _ticks = (uint32_t)((val_usec / fclk0_period_us) + .5);
    m_params.maxPeriod_usec[axis] = val_usec;
    m_params.maxPeriod[axis] = _ticks;
    //if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks; %9.5f usec\n", __func__, axis, m_params.maxPeriod[axis], _ticks);
    return true;
  }
  uint32_t get_min_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis, m_params.minPeriod[axis]);
    return (m_params.minPeriod[axis]);
  }
  double get_min_period(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return -1;
    return m_params.minPeriod_usec[axis];
  }
  double get_max_period(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return -1;
    return m_params.maxPeriod_usec[axis];
  }
  uint32_t get_max_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis, m_params.maxPeriod[axis]);
    return (m_params.maxPeriod[axis]);
  }
  uint32_t get_motor_period_ticks(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u-%u): %u\n", __func__, axis, isSlew,
                  m_params.period_ticks[isSlew][axis]);
    return (m_params.period_ticks[isSlew][axis]);
  }
  bool set_motor_type(uint8_t axis, bool is_tmc) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.is_TMC[axis] = is_tmc;
    ctx.log<INFO>("%s(%u): %s-%s\n", __func__, axis, is_tmc ? "True" : "False",
        m_params.is_TMC[axis] ? "True" : "False");
    //return true;
    if (axis == 0) return stepper.set_motor_type<0>(is_tmc);
    else if (axis == 1) return stepper.set_motor_type<1>(is_tmc);
    else return stepper.set_motor_type<2>(is_tmc);
  }
  bool get_motor_type(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    //return true;
    bool is_tmc;
    if (axis == 0) is_tmc =  stepper.get_motor_type<0>();
    else if (axis == 1) is_tmc = stepper.get_motor_type<1>();
    else is_tmc = stepper.get_motor_type<2>();
    m_params.is_TMC[axis] = is_tmc; 
    return is_tmc;
  }
  double get_motor_period_usec(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u-%u): %9.5f\n", __func__, axis, isSlew,
                  m_params.period_usec[isSlew][axis]);
    return (m_params.period_usec[isSlew][axis]);
  }
  bool set_motor_period_usec(uint8_t axis, bool isSlew, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((val_usec  / fclk0_period_us) + .5);
    if (_ticks > m_params.maxPeriod[axis] ||
        _ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %9.5f usec (%u ticks)\n", __func__, 
          axis, val_usec, _ticks);
      return false;
    }
    m_params.period_usec[isSlew][axis] = val_usec;
    m_params.period_ticks[isSlew][axis] = _ticks;
    // m_params.motorSpeed[isSlew][axis] = m_params.stepPerRotation[axis]*;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %9.5f usec (%u ticks)\n", __func__, axis,
                  m_params.period_usec[isSlew][axis], _ticks);
    return true;
  }
  bool set_motor_period_ticks(uint8_t axis, bool isSlew, uint32_t val_ticks) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val_ticks > m_params.maxPeriod[axis] ||
        val_ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %u (min-%u, max-%u)\n", __func__, axis, val_ticks, m_params.minPeriod[axis], m_params.maxPeriod[axis]);
      return false;
    }
    m_params.period_usec[isSlew][axis] = val_ticks * fclk0_period_us;
    m_params.period_ticks[isSlew][axis] = val_ticks;
    // m_params.motorSpeed[isSlew][axis] = m_params.stepPerRotation[axis]*;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis,
                  m_params.period_ticks[isSlew][axis]);

    if (isSlew)
      if (m_status[axis].isSlew & m_status[axis].isRunning)
      {
        start_raw_tracking(axis, m_params.motorDirection[isSlew][axis],
                              m_params.period_ticks[isSlew][axis],
                              m_params.motorMode[isSlew][axis], true);
      }
    return true;
  }

  bool set_init(uint8_t axis, bool val)
  {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.initialized[axis] = val;
    return true; 
  }
  bool get_init(uint8_t axis)
  {
    if (!check_axis_id(axis, __func__)) return false;
    return m_params.initialized[axis];
  }
  bool set_backlash_period(uint8_t axis, uint32_t ticks)
  {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t period_usec = (uint32_t)((ticks  * fclk0_period_us) );
    if (ticks > m_params.maxPeriod[axis] ||
        ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): period out of range %9.5f usec (%u ticks)\n",
                     __func__, axis, period_usec, ticks);
      return false;
    }
    m_params.backlash_period_usec[axis] = period_usec;
    m_params.backlash_ticks[axis] = ticks;
    if (m_debug)
    ctx.log<INFO>(
        "%s(%u): backlash period set to %9.5f us (%u ticks) \n",
        __func__, axis, period_usec, ticks);
    return true; 
  }
  bool set_backlash_cycles(uint8_t axis, uint32_t cycles)
  {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.backlash_ncycle[axis] = cycles;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, cycles);
    return true; 
  }
  uint32_t get_raw_status(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (axis == 0)
      return stepper.get_status<0>();
    else if (axis == 2)
      return stepper.get_status<2>();
    else
      return stepper.get_status<1>();
  }
  uint32_t get_raw_stepcount(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (axis == 0)
      return stepper.get_stepcount<0>();
    else if (axis == 2)
      return stepper.get_stepcount<2>();
    else
      return stepper.get_stepcount<1>();
  }

  bool enable_backlash(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_backlash<0>(m_params.backlash_ticks[axis], m_params.backlash_ncycle[axis], m_params.backlash_mode[axis]);
    else if (axis ==1)
      stepper.set_backlash<1>(m_params.backlash_ticks[axis], m_params.backlash_ncycle[axis], m_params.backlash_mode[axis]);
    else
      stepper.set_backlash<2>(m_params.backlash_ticks[axis], m_params.backlash_ncycle[axis], m_params.backlash_mode[axis]);
    return true;
  }
  bool assign_raw_backlash(uint8_t axis, uint32_t ticks, uint32_t ncycles, uint8_t mode) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_backlash<0>(ticks, ncycles, mode);
    else if (axis == 2)
      stepper.set_backlash<2>(ticks, ncycles, mode);
    else if (axis == 1)
      stepper.set_backlash<1>(ticks, ncycles, mode);
    else
      stepper.set_backlash<2>(ticks, ncycles, mode);
    return true;
  }
  bool disable_raw_backlash(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.disable_backlash<0>();
    else if (axis == 2)
      stepper.disable_backlash<2>();
    else
      stepper.disable_backlash<1>();
    return true;
  }
  bool disable_raw_tracking(uint8_t axis, bool instant) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.highSpeedMode_fpga[0][axis] = false;
    m_params.highSpeedMode_fpga[1][axis] = false;
    if (axis == 0)
      stepper.disable_tracking<0>(instant);
    else if (axis == 2)
      stepper.disable_tracking<2>(instant);
    else
      stepper.disable_tracking<1>(instant);
    return true;
  }
  bool start_tracking(uint8_t axis) {
      uint32_t isSlew = true;
      return start_raw_tracking(axis, m_params.motorDirection[isSlew][axis],
                              m_params.period_ticks[isSlew][axis],
                              m_params.motorMode[isSlew][axis]);
  }
  bool start_raw_tracking(uint8_t axis, bool isForward, uint32_t periodticks,
                          uint8_t mode, bool update = false) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t isSlew = true;
    if (m_status[axis].isGoto & m_status[axis].isRunning)
    {
      ctx.log<ERROR>("ASCOMInteface: %s- Motor already in goto state: %u\n", __func__, axis);
      return false;
    }
    update &= m_status[axis].isSlew & m_status[axis].isRunning;
    bool stopFirst = false;
    if (update)
    {
      bool isInHighSpeed = m_status[axis].currentPeriod < 7000;
      bool isNewHighSpeed = periodticks < 7000;
      if (!isInHighSpeed & !isNewHighSpeed) // both slow speed
        update = true;
      else if (isInHighSpeed & isInHighSpeed) // both high speed
      {
        stopFirst = true;
        update = false;
      }
      else if (!isInHighSpeed & isNewHighSpeed) // low to high speed
        update = false;
      else if (isInHighSpeed & !isNewHighSpeed) // high to low speed
      {
        stopFirst = true;
        update = true;
      }
    }
    if (axis == 0)
      stepper.enable_tracking<0>(isForward, periodticks, mode, update, stopFirst);
    else if (axis == 2)
      stepper.enable_tracking<2>(isForward, periodticks, mode, update, stopFirst);
    else
      stepper.enable_tracking<1>(isForward, periodticks, mode, update, stopFirst);
    m_params.highSpeedMode_fpga[isSlew][axis] = periodticks < 7000;
    m_status[axis].currentPeriod = periodticks;
    return true;
  }
  bool park_raw_telescope(uint8_t axis, bool isForward, uint32_t period_ticks,
                          uint8_t mode, bool use_accel) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_park<0>(isForward, period_ticks, mode, use_accel);
    else if (axis == 2)
      stepper.set_park<2>(isForward, period_ticks, mode, use_accel);
    else
      stepper.set_park<1>(isForward, period_ticks, mode, use_accel);
    return true;
  }
  bool send_command(uint8_t axis, bool use_accel, bool isGoto) {
      uint32_t isSlew = false;
      m_params.highSpeedMode_fpga[isSlew][axis] = m_params.period_ticks[isSlew][axis] < 7000;
      return send_raw_command(axis, m_params.motorDirection[isSlew][axis],
                             isGoto ? m_params.GotoTarget[axis] : m_params.GotoNCycles[axis],
                             m_params.period_ticks[isSlew][axis],
                             m_params.motorMode[isSlew][axis], isGoto, use_accel);
  }
  bool send_raw_command(uint8_t axis, bool isForward, uint32_t ncycles,
                        uint32_t period_ticks, uint8_t mode, bool isGoTo, bool use_accel) {
    if (!check_axis_id(axis, __func__)) return true;
    if (m_status[axis].isGoto & m_status[axis].isRunning)
    {
      ctx.log<ERROR>("ASCOMInteface: %s- Motor already in goto state: %u\n", __func__, axis);
      return false;
    }
    if (axis == 0)
      stepper.set_command<0>(isForward, ncycles, period_ticks, mode, isGoTo, use_accel);
    else if (axis == 2)
      stepper.set_command<2>(isForward, ncycles, period_ticks, mode, isGoTo, use_accel);
    else
      stepper.set_command<1>(isForward, ncycles, period_ticks, mode, isGoTo, use_accel);
    return true;
  }
  bool cancel_raw_command(uint8_t axis, bool instant) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.highSpeedMode_fpga[0][axis] = false;
    m_params.highSpeedMode_fpga[1][axis] = false;
    if (axis == 0)
      stepper.cancel_command<0>(instant);
    else if (axis == 2)
      stepper.cancel_command<2>(instant);
    else
      stepper.cancel_command<1>(instant);
    return true;
  }
  bool set_current_position(uint8_t axis, uint32_t val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val > 0xFFFFFF) { //m_params.stepPerRotation[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %u; MaxTick=%u\n", __func__,
                     axis, val, 0xFFFFFF);//m_params.stepPerRotation[axis]);
      return false;
    } else if (val == 0xFFFFFF) //m_params.stepPerRotation[axis])
      val = 0;
    if (axis == 0) stepper.set_current_position<0>(val);
    else if (axis == 2) stepper.set_current_position<2>(val);
    else stepper.set_current_position<1>(val);
    return true;
  }
  uint32_t get_goto_increment(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, m_params.GotoNCycles[axis]);
    return m_params.GotoNCycles[axis];
  }
  bool set_goto_increment(uint8_t axis, uint32_t ncycles) {
    if (!check_axis_id(axis, __func__)) return false;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, ncycles);
    m_params.GotoNCycles[axis] = ncycles;// % m_params.stepPerRotation[axis];
    return true;
  }
  uint32_t get_goto_target(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, m_params.GotoTarget[axis]);
    return m_params.GotoTarget[axis];
  }
  bool set_goto_target(uint8_t axis, uint32_t target) {
    if (!check_axis_id(axis, __func__)) return false;
    if (target > 0xFFFFFF) { //m_params.stepPerRotation[axis]) {
      ctx.log<ERROR>("%s(%u) val out of range %u (max=%u)\n", __func__, axis,
                     target,  0xFFFFFF); //m_params.stepPerRotation[axis]);
      return false;
    }
    if (m_debug)
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, target);
    m_params.GotoTarget[axis] = target;
    return true;
  }

  void set_debug(bool value){
    m_debug = value;
    stepper.m_debug = value;
  }
  ip_status m_status[3];

  void set_encoder_position(uint32_t value){
    ctx.log<INFO>("%s(): %u\n", __func__, value);
    spi.write_at<reg::encoder_position/4, mem::control_addr, 1> (&value); 
  }

  void set_pec_calib_data(uint32_t encoder, uint32_t value){
    ctx.log<INFO>("%s(): %u at encoder position of %u \n", __func__, value, encoder);
    uint32_t  tmp = (value & 0xFFFF) + (encoder << 20);
    spi.write_at<reg::pec_calib_data/4, mem::control_addr, 1> (&tmp); 
  }

  uint32_t get_pec_data_readback(){
    uint32_t value;
    spi.read_at<reg::pec_data_readback/4, mem::status_addr, 1> (&value);
    ctx.log<INFO>("%s(): %u\n", __func__, value);
    return value;
  }
  uint32_t get_encoder_readback(){
    uint32_t value;
    spi.read_at<reg::encoder_position_readback/4, mem::status_addr, 1> (&value);
    ctx.log<INFO>("%s(): %u\n", __func__, value);
    return value;
  }
  std::array<uint16_t, 2>  get_iic_encoder(){
    uint32_t value;
    spi.read_at<reg::iic_encoder/4, mem::status_addr, 1> (&value);
    std::array<uint16_t, 2> ret = {static_cast<uint16_t>(value & 0xFFFF), static_cast<uint16_t>((value >> 16) & 0x0F)};
    ctx.log<INFO>("%s(): raw: %u, decoded %u status %u\n", __func__, value, ret[0], ret[1]);
    return ret;
  }
  uint32_t get_encoder_position(){
    uint32_t value;
    spi.read_at<reg::encoder_position/4, mem::control_addr, 1> (&value);
    ctx.log<INFO>("%s(): %u\n", __func__, value);
    return value;
  }
  std::array<uint32_t, 2> get_pec_calib_data(){
    uint32_t value;
    spi.read_at<reg::encoder_position/4, mem::control_addr, 1> (&value);
    std::array<uint32_t, 2> ret = {value>>20, value & 0xFFFF};
    ctx.log<INFO>("%s(): %u at encoder position of %u \n", __func__, ret[0], ret[1]);
    return ret;
  }

 private:
  Context& ctx;
  SpiDev& spi;
  MotorDriver& stepper;
  bool m_debug;
  std::unique_ptr<PiPolarLed> pi;

  parameters m_params;
  std::unique_ptr<CfgConfig> cfg;

  bool check_axis_id(uint8_t axis, std::string str) {
    if (axis > 2) {
      ctx.log<ERROR>("ASCOMInteface: %s- Invalid axis: %u\n", str, axis);
      return false;
    }
    return true;
  }
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
