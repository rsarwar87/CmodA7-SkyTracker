#include <koheron-client.hpp>

#include "fpgafocuser.hpp"
#include "log.hpp"
namespace fpgafocuser_driver {
static std::unique_ptr<KoheronClient> client;
static syslog_stream klog;
}
using namespace fpgafocuser_driver;

indi_focuser_interface::indi_focuser_interface(const char* host, int port) {
  klog << "Initializing driver - connecting to koheron server@" << host << ":" << port << std::endl;
  client = std::make_unique<KoheronClient>(host, port);
  client->connect();
  klog << "Initialization completed" << std::endl;
}
indi_focuser_interface::~indi_focuser_interface(){
  klog << __func__ << std::endl;
  client.reset();
}
bool indi_focuser_interface::Initialize() {
  client->call<op::FocuserInterface::Initialize>();
  auto buffer = client->recv<op::FocuserInterface::Initialize, bool>();
  return buffer;
}

uint32_t indi_focuser_interface::BoardVersion() {
  client->call<op::FocuserInterface::BoardVersion>();
  auto buffer = client->recv<op::FocuserInterface::BoardVersion, uint32_t>();
  return buffer;
}
uint32_t indi_focuser_interface::GetGridPerRevolution() {
  client->call<op::FocuserInterface::GetGridPerRevolution>();
  auto buffer = client->recv<op::FocuserInterface::GetGridPerRevolution, uint32_t>();
  return buffer;
}
uint32_t indi_focuser_interface::GetTimerInterruptFreq() {
  client->call<op::FocuserInterface::GetTimerInterruptFreq>();
  auto buffer = client->recv<op::FocuserInterface::GetTimerInterruptFreq, uint32_t>();
  return buffer;
}
bool indi_focuser_interface::StopFocuser(bool instant) {
  client->call<op::FocuserInterface::StopFocuser>(instant);
  auto buffer = client->recv<op::FocuserInterface::StopFocuser, bool>();
  return buffer;
}
bool indi_focuser_interface::SetFocuserPosition(uint32_t value) {
  client->call<op::FocuserInterface::SetFocuserPosition>(value);
  auto buffer = client->recv<op::FocuserInterface::SetFocuserPosition, bool>();
  return buffer;
}
uint32_t indi_focuser_interface::GetFocuserPosition() {
  client->call<op::FocuserInterface::GetFocuserPosition>();
  auto buffer = client->recv<op::FocuserInterface::GetFocuserPosition, uint32_t>();
  return buffer;
}
std::array<bool, 8> indi_focuser_interface::GetFocuserAxisStatus() {
  client->call<op::FocuserInterface::GetFocuserAxisStatus>();
  auto buffer = client->recv<op::FocuserInterface::GetFocuserAxisStatus, std::array<bool, 8>>();
  return buffer;
}

bool indi_focuser_interface::FocuserIncrement(uint32_t ncycles, uint32_t period_ticks, bool direction) {
  client->call<op::FocuserInterface::FocuserIncrement>(ncycles, period_ticks, direction);
  auto buffer = client->recv<op::FocuserInterface::FocuserIncrement, bool>();
  return buffer;
}
bool indi_focuser_interface::FocuserGotoTarget(uint32_t target, uint32_t period_ticks, bool direction){
  client->call<op::FocuserInterface::FocuserGotoTarget>(target, period_ticks, direction);
  auto buffer = client->recv<op::FocuserInterface::FocuserGotoTarget, bool>();
  return buffer;
}
bool indi_focuser_interface::FocuserSlewTo(uint32_t period_ticks, bool direction) {
  client->call<op::FocuserInterface::FocuserSlewTo>(period_ticks, direction);
  auto buffer = client->recv<op::FocuserInterface::FocuserSlewTo, bool>();
  return buffer;
}
uint32_t indi_focuser_interface::GetFocuserHomePosition() {
  client->call<op::FocuserInterface::GetFocuserHomePosition>();
  auto buffer = client->recv<op::FocuserInterface::GetFocuserHomePosition, uint32_t>();
  return buffer;
}
uint32_t indi_focuser_interface::GetTemp(uint32_t value) {
  client->call<op::FocuserInterface::GetTemp>(value);
  auto buffer = client->recv<op::FocuserInterface::GetTemp, uint32_t>();
  return buffer;
}
uint32_t indi_focuser_interface::get_maximum_period() {
  client->call<op::FocuserInterface::get_max_period_ticks>();
  auto buffer = client->recv<op::FocuserInterface::get_max_period_ticks, uint32_t>();
  return buffer;
}
uint32_t indi_focuser_interface::get_minimum_period() {
  client->call<op::FocuserInterface::get_min_period_ticks>();
  auto buffer = client->recv<op::FocuserInterface::get_min_period_ticks, uint32_t>();
  return buffer;
}

