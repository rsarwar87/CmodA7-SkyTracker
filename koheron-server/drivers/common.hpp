/// Common commands for all bitstreams
///
/// (c) Koheron

#ifndef __DRIVERS_COMMON_HPP__
#define __DRIVERS_COMMON_HPP__

#include <cstring>
#include <array>

extern "C" {
  #include <sys/socket.h>
  #include <sys/types.h>
  #include <arpa/inet.h>
  #include <ifaddrs.h>
}

#include <context.hpp>

class Common
{
  public:
    Common(Context& ctx_)
    : ctx(ctx_),
      spi(ctx.spi.get("spidev0.0"))
    {}
    uint32_t get_forty_two() {
        ctx.log<INFO>("TRACE: calling get forty_two \n");
        uint32_t ret = 0;
        spi.read_at<reg::forty_two/4, mem::status_addr, 1> (&ret); 
        ctx.log<INFO>("TRACE: successfullt retrieved value: %d\n", ret);
        return ret;
    }

    uint64_t get_dna() {
        uint64_t ret = 0;
        uint32_t* p = reinterpret_cast<uint32_t*>(&ret);
        spi.read_at<reg::dna/4, mem::status_addr, 1> (&p[0]); 
        spi.read_at<reg::dna/4 + 1, mem::status_addr, 1> (&p[1]); 
        return ret; 
    }

    void set_led(uint32_t value) {
        spi.write_at<reg::led/4, mem::control_addr, 1> (&value); 
    }

    uint32_t get_led() {
        uint32_t ret = 0;
        spi.read_at<reg::led/4, mem::control_addr, 1> (&ret); 
        return ret; 
    }

    void init() {
        ip_on_leds();
    };

    std::string get_instrument_config() {
        return CFG_JSON;
    }


    void ip_on_leds() {
        size_t cnt = get_iplist();
        bool found = false;
        // Turn all the leds ON
        uint32_t ip = 255;
        spi.write_at<reg::led/4, mem::control_addr, 1> (&ip); 
        for (size_t i = 0; i < cnt; i++) {

          struct ifaddrs* addrs;
          getifaddrs(&addrs);
          ifaddrs* tmp = addrs;
          while (tmp) {
            // Works only for IPv4 address
            if (tmp->ifa_addr && tmp->ifa_addr->sa_family == AF_INET) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wcast-align"
              struct sockaddr_in* pAddr =
                  reinterpret_cast<struct sockaddr_in*>(tmp->ifa_addr);
#pragma GCC diagnostic pop
              int val = strcmp(tmp->ifa_name, iplist.at(i).c_str());

              if (val != 0) {
                tmp = tmp->ifa_next;
                continue;
              }

              ip = htonl(pAddr->sin_addr.s_addr);

              // Write IP address in FPGA memory
              // The 8 Least Significant Bits should be connected to the FPGA
              // LEDs
              ctx.log<INFO>("IP_found[%s]: %d\n", iplist.at(i), ip);
              spi.write_at<reg::led/4, mem::control_addr, 1> (&ip); 
              found = true;
              break;
            }

            tmp = tmp->ifa_next;
          }
          freeifaddrs(addrs);
          if (found) break;
        }
    }
  private:
    Context& ctx;
    SpiDev& spi;
        std::vector<std::string> iplist;

    size_t get_iplist () {
        std::string s = exec("find /sys/class/net -type l -not -lname '*virtual*' -printf '%f\n'");
        std::string delimiter = "\n";
        size_t pos = 0;
        std::string token;
        while ((pos = s.find(delimiter)) != std::string::npos) {
          token = s.substr(0, pos);
          if (token.size() > 2) {
             ctx.log<INFO>("IP_LIST[%d]: %s\n", iplist.size(), token);
             iplist.push_back(token);
          }
          s.erase(0, pos + delimiter.length());
        }
        return iplist.size();
    }

    std::string exec(const char* cmd) {
      std::array<char, 128> buffer;
      std::string result;
      std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
      if (!pipe) {
        return "";
      }
      while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
      }
      return result;
    }
};

#endif // __DRIVERS_COMMON_HPP__
