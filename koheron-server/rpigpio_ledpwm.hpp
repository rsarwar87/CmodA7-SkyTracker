#include <memory>
#include <iostream>
#include <chrono>
#include <thread>
#include <assert.h> 
#include <stdio.h>
#include <array>
#include <string>
#include <algorithm>
#include <string.h>
#include <stdio.h>

using namespace std;

class PiPwmWrapper
{

   string m_gpio_id;
   uint32_t m_timeout;
   uint32_t m_freq;
   uint32_t m_duty;
   
   const std::string m_export = "/sys/class/pwm/pwmchip0/export";
   const std::string m_unexport = "/sys/class/pwm/pwmchip0/unexport";

   std::string m_henable = "/sys/class/pwm/pwmchip0/pwm";
   std::string m_hfreq   = "/sys/class/pwm/pwmchip0/pwm";
   std::string m_hduty   = "/sys/class/pwm/pwmchip0/pwm";

   FILE* ptr_henable = nullptr;
   FILE* ptr_hfreq = nullptr;
   FILE* ptr_hduty = nullptr;

   public:

   PiPwmWrapper(string gpio, uint32_t freq, uint32_t timeout=5){
      m_gpio_id = gpio;
      m_timeout = timeout;
      m_duty = 100;
      FILE *fhandle = fopen(m_export.c_str(), "w");
      string out = (m_gpio_id);
    cout << __func__ << endl;
      if (fwrite(out.c_str(), out.size(), 1, fhandle)){
        fclose(fhandle);
        m_henable = m_henable + out + "/enable";
        m_hfreq = m_hfreq + out + "/period";
        m_hduty = m_hduty + out + "/duty_cycle";
    cout << m_henable << endl;
    cout << m_hfreq << endl;
    cout << m_hduty << endl;
        using namespace std::chrono_literals;
        std::this_thread::sleep_for(100ms);
        SetFreq(freq);
        SetDuty(0);
        SetEnable(true);
      }
    cout << __func__ << endl;
   }
   ~PiPwmWrapper()
   {
     FILE *fhandle = fopen(m_unexport.c_str(), "w");
     string out = (m_gpio_id);
     fwrite(out.c_str(), out.size(), 1, fhandle);
     fclose(fhandle);
   }

   void SetEnable(bool value)
   {
    cout << __func__ << endl;
     string val = "1";
     if (!value) val = "0";
     ptr_henable = fopen(m_henable.c_str(), "w");
     if (fwrite(val.c_str(), val.size(), 1, ptr_henable) == 1)
     fclose(ptr_henable);
    cout << __func__ << endl;
   }
   bool SetFreq(uint32_t value)
   {
    cout << __func__ << endl;
     m_freq = value;
     ptr_hfreq = fopen(m_hfreq.c_str(), "w");
     const string out = std::to_string(m_freq);
     if (!fwrite(out.c_str(), out.size(), 1, ptr_hfreq))
       return false;
    cout << __func__ << endl;
     fclose(ptr_hfreq);
     return true;
   }
   bool SetDuty(uint32_t value)
   {
    cout << __func__ << endl;
     m_duty = value;
     ptr_hduty = fopen(m_hduty.c_str(), "w");
     const string out = std::to_string(m_duty);
     if (!fwrite(out.c_str(), out.size(), 1, ptr_hduty))
       return false;
    cout << __func__ << endl;
     fclose(ptr_hduty);
     return true;
   }
};

class PiPolarLed
{
  public:
  PiPolarLed (std::string port, uint32_t freq)
  {
    size_t n = std::count(port.begin(), port.end(), '@');
    size_t found = port.find('@');
    if (n != 1 || found != 3 || port.size() - found > 3) 
    {
      return;
    }
    port.erase(0, found + 1);
		if (port.find_first_not_of("01") != std::string::npos)
		{
      return;

		}
    cout << __func__ << endl;
		ptr_gpio = make_unique<PiPwmWrapper>(port, freq);
  }

  ~PiPolarLed()
  {
    ptr_gpio.reset();
  }

  void set_freq(uint32_t val)
  {
    ptr_gpio->SetFreq(val);
  }
  void set_duty(uint32_t val)
  {
    ptr_gpio->SetDuty(val);
  }
  void set_enable(bool val)
  {
    ptr_gpio->SetEnable(val);
  }

  private:
  std::unique_ptr<PiPwmWrapper> ptr_gpio;

};

#if 0 
int main()
{

	PiPolarLed dut("PPI@0", 256);
  cout << strncmp("RPI@0", "DSUSB", 4) << endl;
  cout << strncmp("RPI@0", "RPI", 3) << endl;
  uint8_t cnt = 0;
  while (1)
  {
    dut.set_duty(cnt);
    using namespace std::chrono_literals;
    std::this_thread::sleep_for(4ms);
    cnt++;
  }
}
#endif
