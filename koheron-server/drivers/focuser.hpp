/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_FOCUSER_INTERFACE_HPP__
#define __DRIVERS_FOCUSER_INTERFACE_HPP__

#include <context.hpp>
#include <sky-tracker.hpp>
#include <mutex>

using namespace std::chrono_literals;
class FocuserInterface {
 public:
  FocuserInterface(Context& ctx_)
      : ctx(ctx_)
      , sti(ctx.get<SkyTrackerInterface>())
      , spi(ctx.spi.get("spidev0.0"))
  {
    adc_ch = 0;

    ds_lookup();

  }

  bool Initialize() {
    if (sti.get_init(prm::focuser_id)) return false;
    bool ret = true;
    sti.set_steps_per_rotation(prm::focuser_id, 200000);
    
    ret &= sti.disable_raw_tracking(prm::focuser_id, false);
    ret &= sti.disable_raw_backlash(prm::focuser_id);
    ret &= sti.cancel_raw_command(prm::focuser_id, false);
    ret &= sti.set_current_position(prm::focuser_id, sti.get_steps_per_rotation(prm::focuser_id)/2);
    
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

  bool SetGridPerRevolution(uint32_t ticks) {
    return sti.set_steps_per_rotation(prm::focuser_id, ticks);
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

  bool SetFocuserMotorType(bool is_tmc) {
    sti.set_motor_type(prm::focuser_id, is_tmc);
    return true;
  }
  bool GetFocuserMotorType() {
    return sti.get_motor_type(prm::focuser_id);
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

  float GetTemp_pi1w()
  {
    float ret = -6666.66;
    if (!found) return ret;
    try
    {
      w1_mutex.lock();
      int ds_fd = open(dev_path.c_str(), O_RDONLY);
      if (ds_fd == -1)
      {
        ctx.log<PANIC>("DS Device not found");
        return -6666.66;
      }
      size_t numRead;
      char buf[256];
      char temperatureData[6];

      while((numRead = read(ds_fd, buf, 256)) > 0);
      close(ds_fd);
      w1_mutex.unlock();

      strncpy(temperatureData, strstr(buf, "t=") + 2, 5);

      ret = strtof(temperatureData, NULL) / 1000;

      ctx.log<INFO>("FocuserInteface: %s: %0.0f\n", __func__, (double)ret);
    }
    catch (std::exception *e)
    {
      w1_mutex.unlock();
      ctx.log<INFO>("FocuserInteface: %s: something failed. \n", __func__);
    }
    return ret;
  }
  float GetTemp_fpga(uint32_t channel)
  {
    if (adc_ch != channel)
    {
      spi.write_at<reg::temp_channel/4, mem::control_addr, 1> (&channel);
      adc_ch = channel;
    }
    uint32_t ret;
    spi.read_at<reg::temp_sensor/4, mem::status_addr, 1> (&ret);
    float temp = (ret / 4096.0 * 1.5) * 100.0;
    ctx.log<INFO>("FocuserInteface: %s: %u %0.0f\n", __func__, ret, (double)temp);
    return temp;
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
  bool enable_backlash(bool enable) {
    if (enable) return sti.enable_backlash(prm::focuser_id);
    else return sti.disable_raw_backlash(prm::focuser_id);
  }
  uint32_t get_backlash_period()
  {
    return sti.get_backlash_period_ticks(prm::focuser_id);
  }
  uint32_t get_backlash_cycles()
  {
    return sti.get_backlash_ncycles(prm::focuser_id);
  }
  bool set_backlash_period(uint32_t ticks)
  {
    return sti.set_backlash_period(prm::focuser_id, ticks);
  }
  bool set_backlash_cycles(uint32_t cycles)
  {
    return sti.set_backlash_cycles(prm::focuser_id, cycles);
  }
 private:
  Context& ctx;
  SkyTrackerInterface& sti;
  SpiDev& spi;
  uint32_t adc_ch;
  std::mutex w1_mutex;

  const std::string path = "/sys/bus/w1/devices/";
  std::string dev_path;
  bool found = false;


  void ds_lookup(){
    DIR *dir;
    struct dirent *dirent;

    dir = opendir (path.c_str());
    if (dir == NULL) return;
    while ((dirent = readdir (dir)))
    {
      if (dirent->d_type == DT_LNK && strstr(dirent->d_name, "28-") != NULL)
      {
        dev_path = path + dirent->d_name + "/w1_slave";
        ctx.log<INFO>("FocuserInteface - Found temp pi sensor: %s\n", __func__, dev_path);
        found = true;
        return;
      }
    }
    ctx.log<ERROR>("FocuserInteface - Found no temp pi sensor\n");
    found = false;
  }


    
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
