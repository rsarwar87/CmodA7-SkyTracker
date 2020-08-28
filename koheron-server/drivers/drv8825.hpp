/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_DRV8825_HPP__
#define __DRIVERS_DRV8825_HPP__

#include <context.hpp>

constexpr size_t off_shift = 1;
using namespace std::chrono_literals;
class Drv8825
{
  public:
    Drv8825(Context& ctx_)
    : ctx(ctx_),         
      spi(ctx.spi.get("spidev0.0"))
    {}

    template<uint32_t offset>
    uint32_t get_status()
    {
      uint32_t ret = 0xFFFFFFFF;
      spi.read_at<reg::status0/4 + offset, mem::status_addr, 1> (&ret);
      ctx.log<INFO>("DRV8825-%s: %s=0x%08x\n", offset == 0 ? "SA" : "DC", __func__, ret);
      return ret; 
    }
    template<uint32_t offset>
    uint32_t get_stepcount()
    {
      uint32_t ret = 0xFFFFFFFF;
      spi.read_at<reg::step_count0/4 + offset, mem::status_addr, 1> (&ret);
      ctx.log<INFO>("DRV8825-%s: %s=0x%08x\n", offset == 0 ? "SA" : "DC", __func__, ret);
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
            ctx.log<INFO>("DRV8825-%s: %s: CCW=%u, period=0x%08x, mode=%u cmd=0x%08x\n", 
                    offset == 0 ? "SA" : "DC", __func__,
                    isCCW, tmp, mode, cmd);
            spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
          }
        }
      }
      uint32_t tmp= 0;
      spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&tmp);
      ctx.log<INFO>("DRV8825-%s: %s\n", offset == 0 ? "SA" : "DC", __func__);
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
            ctx.log<INFO>("DRV8825-%d: %s: CCW=%u, period=0x%08x, mode=%u cmd=0x%08x\n", 
                    offset, __func__,
                    isCCW, tmp, mode, cmd);
            spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
          }
        }
        cmd = 1 + (isCCW << 1) + (mode << 2) +((period_ticks) << 5);
        spi.write_at<reg::trackctrl0/4 + offset, mem::control_addr, 1> (&cmd);
        ctx.log<INFO>("DRV8825-%d: %s: CCW=%u, period=0x%08x, mode=%u cmd=0x%08x\n", 
            offset, __func__,
            isCCW, (period_ticks), mode, cmd);
    }
    template<uint32_t offset>
    void set_backlash(uint32_t period_ticks, uint32_t n_cycle, uint8_t mode)
    {
        uint32_t cmd = (period_ticks << 3) + mode;
        spi.write_at<reg::backlash_tick0/4 + offset, mem::control_addr, 1> (&cmd);
        spi.write_at<reg::backlash_duration0/4 + offset, mem::control_addr, 1> (&n_cycle);
        ctx.log<INFO>("DRV8825-%s: %s: period=0x%08x, cycle=%u, cmd=0x%08x, duration=0x%08x \n", 
            offset == 0 ? "SA" : "DC", __func__,
            (period_ticks), n_cycle, cmd, n_cycle);
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
        ctx.log<INFO>("DRV8825-%s: %s: CCW=%u, period=0x%08x, %s=%u mode=%u, cmd=0x%08x \n", 
            offset == 0 ? "SA" : "DC", __func__,
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
        ctx.log<INFO>("DRV8825-%s: %s; cmd = 0x%08x\n", offset == 0 ? "SA" : "DC", 
            __func__, cmd);
    }

    template<uint32_t offset>
    void set_max_step(uint32_t val){
        uint32_t cmd =(1 << 31) + (val & 0x3FFFFFFF); 
        spi.write_at<reg::counter_max0/4 + offset, mem::control_addr, 1> (&cmd);
        ctx.log<INFO>("DRV8825-%s: %s: %u; cmd=0x%08x\n", offset == 0 ? "SA" : "DC", 
            __func__, val, cmd);
        cmd = 0;
        spi.write_at<reg::counter_max0/4 + offset, mem::control_addr, 1> (&cmd);
    }
    template<uint32_t offset>
    void set_current_position(uint32_t position){
        uint32_t cmd =(1 << 31) + (position & 0x3FFFFFFF); 
        spi.write_at<reg::counter_load0/4 + offset, mem::control_addr, 1> (&cmd);
        ctx.log<INFO>("DRV8825-%s: %s: %u cmd=0x%08x\n", offset == 0 ? "SA" : "DC", 
            __func__, position, cmd);
        cmd = 0;
        spi.write_at<reg::counter_load0/4 + offset, mem::control_addr, 1> (&cmd);
    }


  private:
    Context& ctx;
    SpiDev& spi;

};

#endif // __DRIVERS_LED_BLINKER_HPP__
