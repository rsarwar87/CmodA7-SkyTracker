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
        struct ifaddrs *addrs;
        getifaddrs(&addrs);
        ifaddrs *tmp = addrs;

        // Turn all the leds ON
        int ip = 255;
        spi.write_at<reg::led/4, mem::control_addr, 1> (&ip); 

        char interface[] = "eth0";

        while (tmp) {
            // Works only for IPv4 address
            if (tmp->ifa_addr && tmp->ifa_addr->sa_family == AF_INET) {
                #pragma GCC diagnostic push
                #pragma GCC diagnostic ignored "-Wcast-align"
                struct sockaddr_in *pAddr = reinterpret_cast<struct sockaddr_in *>(tmp->ifa_addr);
                #pragma GCC diagnostic pop
                int val = strcmp(tmp->ifa_name,interface);

                if (val != 0) {
                    tmp = tmp->ifa_next;
                    continue;
                }

                printf("Interface %s found: %s\n",
                       tmp->ifa_name, inet_ntoa(pAddr->sin_addr));
                ip = htonl(pAddr->sin_addr.s_addr);

                // Write IP address in FPGA memory
                // The 8 Least Significant Bits should be connected to the FPGA LEDs
                spi.write_at<reg::led/4, mem::control_addr, 1> (&ip); 
                break;
            }

            tmp = tmp->ifa_next;
        }

        freeifaddrs(addrs);
    }

  private:
    Context& ctx;
    SpiDev& spi;
};

#endif // __DRIVERS_COMMON_HPP__
