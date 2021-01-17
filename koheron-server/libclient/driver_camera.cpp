#include <koheron-client.hpp>

#include "fpgacameratrigger.hpp"
#include "log.hpp"
namespace cameratrigger_driver {
static std::unique_ptr<KoheronClient> client;
static syslog_stream klog;
}
using namespace cameratrigger_driver;

indi_cameratrigger_interface::indi_cameratrigger_interface(const char* host, int port) {
  klog << "Initializing driver - connecting to koheron server@" << host << ":" << port << std::endl;
  client = std::make_unique<KoheronClient>(host, port);
  client->connect();
  klog << "Initialization completed" << std::endl;
}
indi_cameratrigger_interface::~indi_cameratrigger_interface(){
  klog << __func__ << std::endl;
  client.reset();
}
void indi_cameratrigger_interface::set_debug(bool val) {
  client->call<op::ASCOMInterface::set_debug>(val);
}
bool indi_cameratrigger_interface::set_cameratrigger_reg(uint8_t value, bool fpga) {
  client->call<op::CameraInterface::set_cameratrigger_reg>(value, fpga);
  auto buffer = client->recv<op::CameraInterface::set_cameratrigger_reg, bool>();
  return buffer;
}
uint8_t indi_cameratrigger_interface::get_cameratrigger_reg() {
  client->call<op::CameraInterface::get_cameratrigger_reg>();
  auto buffer = client->recv<op::CameraInterface::get_cameratrigger_reg, uint8_t>();
  return buffer;
}
bool indi_cameratrigger_interface::open_shutter(bool fpga) {
  client->call<op::CameraInterface::open_shutter>(fpga);
  auto buffer = client->recv<op::CameraInterface::open_shutter, bool>();
  return buffer;
}

bool indi_cameratrigger_interface::close_shutter(bool fpga) {
  client->call<op::CameraInterface::close_shutter>(fpga);
  auto buffer = client->recv<op::CameraInterface::close_shutter, bool>();
  return buffer;
}

float indi_cameratrigger_interface::GetTemp_pi1w() {
  client->call<op::FocuserInterface::GetTemp_pi1w>();
  auto buffer = client->recv<op::FocuserInterface::GetTemp_pi1w, float>();
  return buffer;
}
float indi_cameratrigger_interface::GetTemp_fpga(uint32_t value) {
  client->call<op::FocuserInterface::GetTemp_fpga>(value);
  auto buffer = client->recv<op::FocuserInterface::GetTemp_fpga, float>();
  return buffer;
}

