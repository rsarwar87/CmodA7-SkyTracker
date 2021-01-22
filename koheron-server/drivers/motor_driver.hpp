/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_MOTORDRIVER_HPP__
#define __DRIVERS_MOTORDRIVER_HPP__

#include <context.hpp>

constexpr size_t off_shift = 1;
using namespace std::chrono_literals;
class MotorDriver
{
  public:
    bool m_debug;
    MotorDriver(Context& ctx_)
    : ctx(ctx_),         
      spi(ctx.spi.get("spidev0.0"))
    {
      uint32_t val = 0xFFFFFFFF;
      spi.write_at<reg::tmc_select, mem::control_addr, 1>(&val);
      ctx.log<INFO>("MotorDriver-%s: Class initialized\n", __func__);
      m_debug = false;
    }

    template<uint32_t offset>
    void set_motor_type(bool is_tmc)
    {
      uint32_t ret = 0x0;
      spi.read_at<reg::tmc_select, mem::control_addr, 1> (&ret);
      uint32_t rets = ret;
      if (is_tmc)
         rets |= (1UL << offset);
      else
        rets &= ~(1UL << offset);
      spi.write_at<reg::tmc_select, mem::control_addr, 1>(&rets);
      print_debug<offset>(__func__, ret, rets);
    }
    template<uint32_t offset>
    bool get_motor_type()
    {
      uint32_t ret = 0x0;
      spi.read_at<reg::tmc_select, mem::control_addr, 1> (&ret);
      bool retb = (ret >> offset) & 0x1;
      print_debug<offset>(__func__, ret, retb);
      return retb; 
    }
    template<uint32_t offset>
    uint32_t get_status()
    {
      uint32_t ret = 0xFFFFFFFF;
      spi.read_at<reg::status0/4 + offset, mem::status_addr, 1> (&ret);
      print_debug<offset>(__func__, ret, 0);
      return ret; 
    }
    template<uint32_t offset>
    uint32_t get_stepcount()
    {
      uint32_t ret = 0xFFFFFFFF;
      spi.read_at<reg::step_count0/4 + offset, mem::status_addr, 1> (&ret);
      print_debug<offset>(__func__, ret, 0);
      return ret; 
    }
    template<uint32_t offset>
    void disable_backlash()
    {
      set_backlash<offset>(0,0,0);
    }
    template<uint32_t offset>
    void disable_tracking(bool instant)
    {
      if (!instant)
      {
        uint32_t current_settings;
        spi.read_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&current_settings);
        uint32_t period_ticks = current_settings >> 5;
        uint32_t mode = (current_settings >> 2) & 0x7;
        bool isCCW = (current_settings >> 1) & 0x1;
        if (period_ticks > 0 && period_ticks < 500*1000/20)
        {
          for (size_t i = 2; i < (500*1000/20)/period_ticks; i++)
          {
            std::this_thread::sleep_for(50ms);
            uint32_t tmp = period_ticks*i;
            uint32_t cmd = 1 + (isCCW << 1) + (mode << 2) +((tmp) << 5);
            print_debug<offset>(__func__, isCCW, tmp, mode, cmd);
            spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
          }
        }
      }
      uint32_t tmp= 0;
      spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&tmp);
    }
    template<uint32_t offset>
    void enable_tracking(bool isCCW, uint32_t period_ticks, uint8_t mode, bool update = false)
    {
        uint32_t cmd = 0;
        if (!update)
        if (period_ticks < 500*1000/20)
        {
          for (size_t i = (500*1000/20)/period_ticks; i > 0; i--)
          {
            std::this_thread::sleep_for(50ms);
            uint32_t tmp = period_ticks*i;
            cmd = 1 + (isCCW << 1) + (mode << 2) +((tmp) << 5);
            print_debug<offset>(__func__, isCCW, tmp, mode, cmd);
            spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
          }
        }
        cmd = 1 + (isCCW << 1) + (mode << 2) +((period_ticks) << 5);
        spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
        print_debug<offset>(__func__, isCCW, (period_ticks), mode, cmd);
    }
    template<uint32_t offset>
    void set_backlash(uint32_t period_ticks, uint32_t n_cycle, uint8_t mode)
    {
        uint32_t cmd = (period_ticks << 3) + mode;
        spi.write_at<reg::backlash_tick0/4 + offset, mem::control_addr, 1> (&cmd);
        uint32_t duration = n_cycle* period_ticks;
        spi.write_at<reg::backlash_duration0/4 + offset, mem::control_addr, 1> (&duration);
        if (m_debug)
        ctx.log<INFO>("MotorDriver-%s: %s: period=0x%08x, cycle=%u, cmd=0x%08x, duration=0x%08x \n", 
            get_name<offset>(), __func__,
            (period_ticks), n_cycle, cmd, duration);
    }

    template<uint32_t offset>
    void set_park(bool isCCW, uint32_t period_ticks, uint8_t mode, bool use_accel)
    {
      set_command<offset>(isCCW, 0, period_ticks, mode, true, use_accel);
    }
    template<uint32_t offset>
    void set_command(bool isCCW, uint32_t target, uint32_t period_ticks, uint8_t mode, 
        bool isGoto, bool use_accel) {
        spi.write_at<reg::cmdtick0/4 + offset, mem::control_addr, 1> (&period_ticks);
        spi.write_at<reg::cmdduration0/4 + offset, mem::control_addr, 1> (&target);
        uint32_t cmd = 1 + (isGoto << 1) + (isCCW << 2) + (mode << 4) + (use_accel << 7);
        spi.write_at<reg::cmdcontrol0/4 + offset, mem::control_addr, 1> (&cmd);
        if (m_debug)
        ctx.log<INFO>("MotorDriver-%s: %s: CCW=%u, period=0x%08x, %s=%u mode=%u, cmd=0x%08x \n", 
            get_name<offset>(), __func__,
            isCCW, (period_ticks), isGoto ? "GotoTarget" : "n_cycles", 
            target, mode, cmd);
        std::this_thread::sleep_for(1ms);
        cmd = 0;
        spi.write_at<reg::cmdcontrol0/4 + offset, mem::control_addr, 1> (&cmd);
    }
    template<uint32_t offset>
    void cancel_park(bool instant){cancel_command<offset>(instant);}
    template<uint32_t offset>
    void cancel_goto(bool instant){cancel_command<offset>(instant);}
    template<uint32_t offset>
    void cancel_command(bool instant){
        uint32_t cmd = (1 << 31) + (instant << 30); 
        spi.write_at<reg::cmdcontrol0/4 + offset, mem::control_addr, 1> (&cmd);
        //std::this_thread::sleep_for(1ms);
        //ctl.write<reg::cmdcontrol0 + offset*off_shift>(0);
        print_debug<offset>(__func__, 0, cmd);
    }

    template<uint32_t offset>
    void set_max_step(uint32_t val){
        uint32_t cmd =(1 << 31) + (val & 0x3FFFFFFF); 
        spi.write_at<reg::counter_max0/4 + offset, mem::control_addr, 1> (&cmd);
        print_debug<offset>(__func__, val, cmd);
        cmd = 0;
        spi.write_at<reg::counter_max0/4 + offset, mem::control_addr, 1> (&cmd);
    }
    template<uint32_t offset>
    void set_current_position(uint32_t position){
        uint32_t cmd =(1 << 31) + (position & 0x3FFFFFFF); 
        spi.write_at<reg::counter_load0/4 + offset, mem::control_addr, 1> (&cmd);
        print_debug<offset>(__func__, position, cmd);
        cmd = 0;
        spi.write_at<reg::counter_load0/4 + offset, mem::control_addr, 1> (&cmd);
    }


  private:
    Context& ctx;
    SpiDev& spi;
    template<uint32_t offset>
    void print_debug(std::string func, uint32_t dir, uint32_t period, uint32_t mode, uint32_t cmd)
    {
       if (m_debug)
         ctx.log<INFO>("MotorDriver-%s: %s: CCW=%u, period=0x%08x, mode=%u cmd=0x%08x\n", 
               get_name<offset>(), func, dir, period, mode, cmd);
    }
    template<uint32_t offset>
    void print_debug(std::string func, uint32_t data, uint32_t cmd)
    {
        if (m_debug)
        ctx.log<INFO>("MotorDriver-%s: %s; %u cmd = 0x%08x\n", get_name<offset>(), 
            func, data, cmd);
    }

    template<uint32_t offset>
    std::string get_name()
    {
      if (offset == 0) return "RA";
      else if (offset == 0) return "DE";
      else return "FOCUS";
    }
};

#endif // __DRIVERS_LED_BLINKER_HPP__
