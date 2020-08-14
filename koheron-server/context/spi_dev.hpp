// SPI interface
// (c) Koheron
//
// From http://redpitaya.com/examples-new/spi/
// See also https://www.kernel.org/doc/Documentation/spi/spidev

#ifndef __DRIVERS_LIB_SPI_DEV_HPP__
#define __DRIVERS_LIB_SPI_DEV_HPP__

#include <cstdio>
#include <cstdint>
#include <cassert>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

#include <unordered_map>
#include <string>
#include <memory>
#include <vector>
#include <array>
#include <mutex>
#include <context_base.hpp>
// https://www.kernel.org/doc/Documentation/spi/spidev
class SpiDev
{
  public:
    SpiDev(ContextBase& ctx_, std::string devname_);

    ~SpiDev() {
        if (fd >= 0)
            close(fd);
    }

    bool is_ok() {return fd >= 0;}

    int init(uint8_t mode_, uint32_t speed_, uint8_t word_length_);
    int set_mode(uint8_t mode_);
    int set_full_mode(uint32_t mode32_);
    int set_speed(uint32_t speed_);

    /// Set the number of bits in each SPI transfer word.
    int set_word_length(uint8_t word_length_);

    template<typename T>
    int write(const T *buffer, uint32_t len)
    {
        if (fd >= 0)
            return ::write(fd, buffer, len * sizeof(T));

        return -1;
    }

    template<size_t len>
    int transfer(uint8_t *tx_buff, uint8_t *rx_buff)
    {
        if (! is_ok())
            return -1;
    
        static std::mutex spi_mutex;
        struct spi_ioc_transfer tr{};
        tr.tx_buf = reinterpret_cast<unsigned long>(tx_buff);
        tr.rx_buf = reinterpret_cast<unsigned long>(rx_buff);
    	  tr.cs_change = 0;
        tr.len = len;
        
        spi_mutex.lock();
        int ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
        spi_mutex.unlock();
        return ret;
    }

    template<size_t addr, uint32_t offset, size_t holdoff = 0, typename Tw = uint32_t, typename Ta = uint8_t, uint8_t cmd = 0x80 >
    int write_at(Tw* pData) {
        std::array<uint8_t, sizeof(Tw) + holdoff + sizeof(Ta)> tx_buff = {};
        tx_buff.at(0) = static_cast<uint8_t>(((addr >> (sizeof(Ta) - 1)*8) & 0xFF) | cmd);
        for (size_t i = 1; i < sizeof(Ta); i++)
        {
          tx_buff.at(i) = ((addr + offset) >> (sizeof(Ta) - i - 1)*8) & 0xFF;
        }
        for (size_t i = 0; i < sizeof(Tw); i++)
        {
          tx_buff.at(sizeof(Ta) + i) = ((*pData) >> i*8) & 0xFF;
        }
        std::array<uint8_t, sizeof(Tw) + holdoff + sizeof(Ta)> rx_buff = {{0}};
        return transfer<sizeof(Tw) + holdoff + sizeof(Ta)>(tx_buff.data(), rx_buff.data());
    }
    template<typename Tw = uint32_t, uint8_t cmd = 0x80>
    int write_(Tw* pData) {
        uint8_t* tx_buff = reinterpret_cast<uint8_t*>(pData);
        tx_buff[0] |= cmd;
        std::array<uint8_t, 32> rx_buff = {{0}};
        return transfer<sizeof(Tw)>(tx_buff, rx_buff.data());
    }
    template<typename Tr = uint32_t>
    int read_(Tr* pData) {
        if (pData == NULL) return -1;
        std::array<uint8_t, sizeof(Tr)> tx_buff = {};
        std::array<uint8_t, 32> rx_buff = {{0}};
        int ret = transfer<sizeof(Tr)>(tx_buff.data(), rx_buff.data());
        Tr* var = reinterpret_cast<Tr*>(rx_buff.data());
        *pData = *var;
        return ret;
    }
    template<size_t addr, uint32_t offset, size_t holdoff = 0, typename Tr = uint32_t, typename Ta = uint8_t>
    int read_at(Tr* pData) {
        if (pData == nullptr) return -1;
        std::array<uint8_t, sizeof(Tr) + holdoff + sizeof(Ta)> tx_buff = {};
        for (size_t i = 0; i < sizeof(Ta); i++)
        {
          tx_buff.at(i) = ((addr + offset) >> (sizeof(Ta) - i - 1)*8) & 0xFF;
        }
        std::array<uint8_t, sizeof(Tr) + holdoff + sizeof(Ta)> rx_buff = {{0}};
        int ret = transfer<sizeof(Tr) + holdoff + sizeof(Ta)>(tx_buff.data(), rx_buff.data());
        memcpy(pData, rx_buff.data() + holdoff + sizeof(Ta), sizeof(Tr));
        return ret;
    }

    int recv(uint8_t *buffer, int64_t n_bytes);

    template<typename T>
    int recv(std::vector<T>& vec) {
        return recv(reinterpret_cast<uint8_t*>(vec.data()),
                    vec.size() * sizeof(T));
    }

    template<typename T, size_t N>
    int recv(std::array<T, N>& arr) {
        return recv(reinterpret_cast<uint8_t*>(arr.data()),
                    N * sizeof(T));
    }

  private:
    ContextBase& ctx;
    std::string devname;

    uint8_t mode = SPI_MODE_0;
    uint32_t mode32 = SPI_MODE_0;
    uint32_t speed = 31200000; // SPI bus speed
    uint8_t word_length = 8;

    int fd = -1;
};

class SpiManager
{
  public:
    SpiManager(ContextBase& ctx_);

    int init();

    bool has_device(const std::string& devname);

    SpiDev& get(const std::string& devname,
                uint8_t mode = SPI_MODE_0,
                uint32_t speed = 31200000,
                uint8_t word_length = 8);

  private:
    ContextBase& ctx;
    std::unordered_map<std::string, std::unique_ptr<SpiDev>> spi_drivers;
    SpiDev empty_spidev;
};

#endif // __DRIVERS_LIB_SPI_DEV_HPP__
