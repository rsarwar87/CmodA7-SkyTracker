#include <yaml-cpp/yaml.h>

#include <fstream>
#include <params.hpp>
#include <string>


namespace YAML {
template <>
struct convert<settings> {
  static Node encode(const settings& rhs) {
    Node node;
    node["Mode_Track"] = (rhs.motorMode[0]);
    node["Mode_GoTo"] = (rhs.motorMode[1]);
    node["MinPeriodUsec"] = rhs.minPeriod_usec;
    node["MaxPeriodUsec"] = rhs.maxPeriod_usec;
    node["is_TMC"] = rhs.is_TMC;
    node["LowGearTicks"] = rhs.low_gear_ticks;
    node["HighGearTicks"] = rhs.high_gear_ticks;
    node["MountGearTicks"] = rhs.mount_gearticks;
    node["UStepping"] = rhs.motor_ustepping;
    node["MotorSteps"] = rhs.motor_revticks;
    return node;
  }

  static bool decode(const Node& node, settings& rhs) {
    try {
      rhs.motorMode[0] = node["Mode_Track"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.motorMode[1] = node["Mode_GoTo"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.minPeriod_usec = node["MinPeriodUsec"].as<double>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.maxPeriod_usec = node["MaxPeriodUsec"].as<double>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.is_TMC = node["is_TMC"].as<bool>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.low_gear_ticks = node["LowGearTicks"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.high_gear_ticks = node["HighGearTicks"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.mount_gearticks = node["MountGearTicks"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.motor_ustepping = node["UStepping"].as<uint16_t>();
    } catch (YAML::InvalidNode  const &ex) {
      std::cout << ex.what();
    }
    try {
      rhs.motor_revticks = node["MotorSteps"].as<uint16_t>();
    } catch (YAML::InvalidNode const &ex) {
      std::cout << ex.what();
    }
    return true;
  }
};
}  // namespace YAML

