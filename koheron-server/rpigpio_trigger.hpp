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

class PiGpioWrapper
{

   string m_gpio_id;
   uint32_t m_timeout;
   string m_mode;
   
   const std::string m_export = "/sys/class/gpio/export";
   const std::string m_unexport = "/sys/class/gpio/unexport";

   std::string m_dir = "/sys/class/gpio/gpio";
   std::string m_val = "/sys/class/gpio//gpio";

   FILE* ptr_hdir = nullptr;
   FILE* ptr_hval = nullptr;

   public:

   PiGpioWrapper(string gpio, bool isoutput, uint32_t timeout=5){
      m_gpio_id = gpio;
      m_timeout = timeout;
      FILE *fhandle = fopen(m_export.c_str(), "w");
      string out = (m_gpio_id);
      if (fwrite(out.c_str(), out.size(), 1, fhandle)){
        fclose(fhandle);
        m_dir = m_dir + out + "/direction";
        m_val = m_val + out + "/value";
        using namespace std::chrono_literals;
        std::this_thread::sleep_for(100ms);
        SetMode(isoutput);
      }
   }
   ~PiGpioWrapper()
   {
     FILE *fhandle = fopen(m_unexport.c_str(), "w");
     string out = (m_gpio_id);
     fwrite(out.c_str(), out.size(), 1, fhandle);
     fclose(fhandle);
   }

   bool GetMode()
   {  
     std::array<char, 1> buff{};
     ptr_hdir = fopen(m_dir.c_str(), "r");
     if (fread(buff.data(), 1, 1, ptr_hdir) == 1) return -1;
     return buff[0] == 'i' ? false : true;
     fclose(ptr_hdir);
   }
   void SetMode(bool isoutput)
   {  
     if (isoutput) m_mode = "out";
     else m_mode = "in";
     ptr_hdir = fopen(m_dir.c_str(), "w");
     if (fwrite(m_mode.c_str(), m_mode.size(), 1, ptr_hdir) == 1)
     fclose(ptr_hdir);
   }
   bool ClearGpio()
   {
     if (m_mode == "in") 
       return false;
    ptr_hval = fopen(m_val.c_str(), "w");
     const string out = "0";
     if (!fwrite(out.c_str(), out.size(), 1, ptr_hval))
       return false;
     fclose(ptr_hval);
     return true;
   }
   bool SetGpio()
   {
     if (m_mode == "in") 
       return false;
    ptr_hval = fopen(m_val.c_str(), "w");
     const string out = "1";
     if (!fwrite(out.c_str(), out.size(), 1, ptr_hval))
       return false;
     fclose(ptr_hval);
     return true;
   }
   int32_t GetValue()
   {
     std::array<char, 1> buff{};
    ptr_hval = fopen(m_val.c_str(), "r");
     if (fread(buff.data(), 1, 1, ptr_hval) == 1) return -1;
     fclose(ptr_hval);
     return buff[0] == '0' ? 0 : 1;
   }
};

class PiCameraTrigger
{
  public:
  PiCameraTrigger (std::string port)
  {
    size_t n = std::count(port.begin(), port.end(), '@');
    size_t found = port.find('@');
    if (n != 1 || found != 3 || port.size() - found > 3) 
    {
      return;
    }
    port.erase(0, found + 1);
		if (port.find_first_not_of("0123456789") != std::string::npos)
		{
      return;

		}
		ptr_gpio = make_unique<PiGpioWrapper>(port,true);
  }

  ~PiCameraTrigger()
  {
    ptr_gpio.reset();
  }

  void open_shutter()
  {
    ptr_gpio->SetGpio();
  }
  void close_shutter()
  {
    ptr_gpio->ClearGpio();
  }

  private:
  std::unique_ptr<PiGpioWrapper> ptr_gpio;

};

#if 0
int main()
{

	PiCameraTrigger dut("RPI@21");
  cout << strncmp("RPI@21", "DSUSB", 4) << endl;
  cout << strncmp("RPI@21", "RPI", 3) << endl;
  while (1)
  {
    dut.open_shutter();
    using namespace std::chrono_literals;
    std::this_thread::sleep_for(1s);
    dut.close_shutter();
    std::this_thread::sleep_for(1s);
  }
}
#endif
