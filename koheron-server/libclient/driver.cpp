#include <koheron-client.hpp>

#include "fpgaskytracker.hpp"
#include "log.hpp"
namespace sky_driver {
static std::unique_ptr<KoheronClient> client;
static syslog_stream klog;
}
using namespace sky_driver;

ASCOM_sky_interface::ASCOM_sky_interface(const char* host, int port) {
  klog << "Initializing driver - connecting to koheron server@" << host << ":" << port << std::endl;
  client = std::make_unique<KoheronClient>(host, port);
  client->connect();
  klog << "Initialization completed" << std::endl;
}
ASCOM_sky_interface::~ASCOM_sky_interface(){
  klog << __func__ << std::endl;
  client.reset();
}
// SetPolarScopeLED          = 'V',
bool ASCOM_sky_interface::SwpSetPolarScopeLED(uint8_t value, bool fpga) {
  client->call<op::ASCOMInterface::SwpSetPolarScopeLED>(value, fpga);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetPolarScopeLED, bool>();
  return buffer;
}
// GetFeatureCmd             = 'q', // EQ8/AZEQ6/AZEQ5 only
uint32_t ASCOM_sky_interface::SwpGetFeature(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetFeature>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetFeature, uint32_t>();
  return buffer;
}
// SetFeatureCmd             = 'W', // EQ8/AZEQ6/AZEQ5 only
bool ASCOM_sky_interface::SwpSetFeature(uint8_t axis,
                                          uint8_t cmd) {  // not used
  client->call<op::ASCOMInterface::SwpSetFeature>(axis, cmd);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetFeature, bool>();
  return buffer;
}
// GetFeatureCmd             = 'q', // EQ8/AZEQ6/AZEQ5 only
// InquireAuxEncoder         = 'd', // EQ8/AZEQ6/AZEQ5 only
uint32_t ASCOM_sky_interface::SwpGetAuxEncoder(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetAuxEncoder>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetAuxEncoder, uint32_t>();
  return buffer;
}
// GetHomePosition           = 'd', // Get Home position encoder count
// (default at startup)
// not used in eqmod
uint32_t ASCOM_sky_interface::SwpGetHomePosition(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetHomePosition>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetHomePosition, uint32_t>();
  return buffer;
}
// StartMotion               = 'J', // start
bool ASCOM_sky_interface::SwpCmdStartMotion(uint8_t axis, bool isSlew,
                                              bool isGoto, bool use_accel) {
  klog << __func__ << " Axis " <<  std::to_string(axis) << " isSLew: " << isSlew << "; isGoto: " << isGoto << "; Accel: " << use_accel << std::endl;
  client->call<op::ASCOMInterface::SwpCmdStartMotion>(axis, isSlew, use_accel, isGoto);
  auto buffer = client->recv<op::ASCOMInterface::SwpCmdStartMotion, bool>();
  return buffer;
}
// SetStepPeriod             = 'I', //set slew speed
bool ASCOM_sky_interface::SwpSetStepPeriod(uint8_t axis, bool isSlew,
                                             uint32_t period_usec) {
  klog << __func__ << " Axis " << std::to_string(axis) << " isSLew: " << isSlew << "; period: " << period_usec << std::endl;
  client->call<op::ASCOMInterface::SwpSetStepPeriod>(axis, isSlew, period_usec);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetStepPeriod, bool>();
  return buffer;
}
// SetGotoTarget             = 'S', // does nothing??
bool ASCOM_sky_interface::SwpSetGotoTarget(uint8_t axis, uint32_t target) {
  klog << __func__ << " Axis " << axis << " NCycles: " << target << std::endl;
  client->call<op::ASCOMInterface::SwpSetGotoTarget>(axis, target);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetGotoTarget, bool>();
  return buffer;
}
// SetBreakStep              = 'U', // does nothing??
bool ASCOM_sky_interface::SwpSetBreakStep(uint8_t axis, uint32_t ncycles) {
  klog << __func__ << " Axis " << axis << " NCycles: " << ncycles << std::endl;
  client->call<op::ASCOMInterface::SwpSetBreakStep>(axis, ncycles);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetBreakStep, bool>();
  return buffer;
}
// NOT SURE SetBreakPointIncrement    = 'M',
// does nothing ??
bool ASCOM_sky_interface::SwpSetBreakPointIncrement(uint8_t axis,
                                                      uint32_t ncycles) {
  klog << __func__ << " Axis " << axis << " NCycles: " << ncycles << std::endl;
  client->call<op::ASCOMInterface::SwpSetBreakPointIncrement>(axis, ncycles);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetBreakPointIncrement, bool>();
  return buffer;
}
// set goto target - SetGotoTargetIncrement    = 'H', // set goto position
bool ASCOM_sky_interface::SwpSetGotoTargetIncrement(uint8_t axis,
                                                      uint32_t ncycles) {
  klog << __func__ << " Axis " << axis << " NCycles: " << ncycles << std::endl;
  client->call<op::ASCOMInterface::SwpSetGotoTargetIncrement>(axis, ncycles);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetGotoTargetIncrement, bool>();
  return buffer;
}
// SetMotionMode             = 'G', mode and direction
bool ASCOM_sky_interface::SwpSetMotionModeDirection(uint8_t axis,
                                                      bool isForward,
                                                      bool isSlew,
                                                      bool isHighSpeed) {
  klog << __func__ << " Aaxis " << std::to_string(axis) << "; Forward " << isForward << "; isSlew "
        << isSlew << " HighSpeed " << isHighSpeed << std::endl;
  client->call<op::ASCOMInterface::SwpSetMotionModeDirection>(axis, isForward, isSlew, 
      isHighSpeed);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetMotionModeDirection, bool>();
  return buffer;
}

// GetAxisStatus             = 'f',
std::array<bool, 8> ASCOM_sky_interface::SwpGetAxisStatus(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetAxisStatus>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetAxisStatus, std::array<bool, 8>>();
  return buffer;
}

// GetAxisPosition           = 'j', // current position
uint32_t ASCOM_sky_interface::SwpGetAxisPosition(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetAxisPosition>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetAxisPosition, uint32_t>();
  return buffer;
}

// SetAxisPositionCmd        = 'E', set current position
bool ASCOM_sky_interface::SwpSetAxisPosition(uint8_t axis, uint32_t value) {
  klog << __func__ <<  ": " << value << std::endl;
  client->call<op::ASCOMInterface::SwpSetAxisPosition>(axis, value);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetAxisPosition, bool>();
  return buffer;
}

// InstantAxisStop (L) + NotInstantAxisStop (K)
bool ASCOM_sky_interface::SwpCmdStopAxis(uint8_t axis, bool instant) {
  klog << __func__ << std::endl;
  client->call<op::ASCOMInterface::SwpCmdStopAxis>(axis, instant);
  auto buffer = client->recv<op::ASCOMInterface::SwpCmdStopAxis, bool>();
  return buffer;
}
// Encoder stuff (g) // speed scalar for high speed skew
// InquireHighSpeedRatio     = 'g',
double ASCOM_sky_interface::SwpGetHighSpeedRatio(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetHighSpeedRatio>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetHighSpeedRatio, double>();
  return buffer;
}
// InquireTimerInterruptFreq = 'b', // sidereal rate of axis   steps per
// worm???
uint32_t ASCOM_sky_interface::SwpGetTimerInterruptFreq() {
  client->call<op::ASCOMInterface::SwpGetTimerInterruptFreq>();
  auto buffer = client->recv<op::ASCOMInterface::SwpGetTimerInterruptFreq, uint32_t>();
  return buffer;
}
// InquireGridPerRevolution  = 'a', // steps per axis revolution
uint32_t ASCOM_sky_interface::SwpGetGridPerRevolution(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetGridPerRevolution>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetGridPerRevolution, uint32_t>();
  klog <<  __func__ << ":" << buffer << std::endl;
  return buffer;
}
// InquireMotorBoardVersion  = 'e',
uint32_t ASCOM_sky_interface::SwpGetBoardVersion() {
  client->call<op::ASCOMInterface::SwpGetBoardVersion>();
  auto buffer = client->recv<op::ASCOMInterface::SwpGetBoardVersion, uint32_t>();
  klog << __func__ << ": " << buffer << std::endl;
  return buffer;
}
// Initialize                = 'F',
bool ASCOM_sky_interface::SwpCmdInitialize(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpCmdInitialize>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpCmdInitialize, bool>();
  klog << __func__ << std::endl;
  return buffer;
}
bool ASCOM_sky_interface::cmd_enable_backlash(uint8_t axis, bool enable) {
  client->call<op::ASCOMInterface::enable_backlash>(axis, enable);
  auto buffer = client->recv<op::ASCOMInterface::enable_backlash, bool>();
  klog  << __func__ << " enabled: " << enable << std::endl;
  return buffer;
}
bool ASCOM_sky_interface::cmd_set_backlash_period(uint8_t axis, uint32_t ticks) {
  client->call<op::ASCOMInterface::set_backlash_period>(axis, ticks);
  auto buffer = client->recv<op::ASCOMInterface::set_backlash_period, bool>();
  klog << __func__ << ": " << ticks << std::endl;
  return buffer;
}
bool ASCOM_sky_interface::cmd_set_backlash_cycles(uint8_t axis, uint32_t ticks) {
  client->call<op::ASCOMInterface::set_backlash_cycles>(axis, ticks);
  auto buffer = client->recv<op::ASCOMInterface::set_backlash_cycles, bool>();
  klog << __func__ << ": " << ticks << std::endl;
  return buffer;
}

uint32_t ASCOM_sky_interface::get_forty_two() {
  client->call<op::Common::get_forty_two>();
  auto buffer = client->recv<op::Common::get_forty_two, uint32_t>();
  return buffer;
}
uint32_t ASCOM_sky_interface::get_maximum_period(uint8_t axis) {
  client->call<op::ASCOMInterface::get_max_period_ticks>(axis);
  auto buffer = client->recv<op::ASCOMInterface::get_max_period_ticks, uint32_t>();
  klog << __func__ << ": " << buffer << " Axis: " << std::to_string(axis) << std::endl;
  return buffer;
}
uint32_t ASCOM_sky_interface::get_minimum_period(uint8_t axis) {
  client->call<op::ASCOMInterface::get_min_period_ticks>(axis);
  auto buffer = client->recv<op::ASCOMInterface::get_min_period_ticks, uint32_t>();
  klog << __func__ << ": " << buffer << " Axis: " << std::to_string(axis) << std::endl;
  return buffer;
}
uint64_t ASCOM_sky_interface::get_dna() {
  client->call<op::Common::get_dna>();
  auto buffer = client->recv<op::Common::get_dna, uint64_t>();
  return buffer;
}
void ASCOM_sky_interface::set_debug(bool val) {
  client->call<op::ASCOMInterface::set_debug>(val);
}
void ASCOM_sky_interface::print_status(std::string fname, std::string str) {
  klog << "STATUS " << fname << "(): " << str << std::endl;
}
void ASCOM_sky_interface::print_error(std::string fname, std::string str) {
  klog << "ERROR " << fname << "(): " << str << std::endl;
}
bool ASCOM_sky_interface::SwpGetMotorType(uint8_t axis) {
  client->call<op::ASCOMInterface::SwpGetMotorType>(axis);
  auto buffer = client->recv<op::ASCOMInterface::SwpGetMotorType, bool>();
  klog << __func__ << std::endl;
  return buffer;
}
bool ASCOM_sky_interface::SwpSetMotorType(uint8_t axis, bool enable) {
  client->call<op::ASCOMInterface::SwpSetMotorType>(axis, enable);
  auto buffer = client->recv<op::ASCOMInterface::SwpSetMotorType, bool>();
  klog  << __func__ << " enabled: " << enable << std::endl;
  return buffer;
}

