#ifndef __HEADER_PARAMS_
#define __HEADER_PARAMS_
#include <array>
typedef struct {

    uint16_t motorMode[2] = {7, 7};  // microsteps

    double minPeriod_usec = 17.0;  // slowest speed allowed
    double maxPeriod_usec = 268435.0;  // Speed at which mount should stop. May be lower

    uint16_t  motor_ustepping = 64;
    uint16_t  motor_revticks = 200;
    uint16_t  mount_gearticks = 180;
    uint16_t  high_gear_ticks = 48;
    uint16_t  low_gear_ticks = 12;
    bool  is_TMC = true; 
  } settings;
typedef struct {
    // class variables
    double period_usec[2][3];      // time period in us
    uint32_t period_ticks[2][3];  // time period in 20ns ticks
    double speed_ratio[2][3];      // speed of motor
    bool highSpeedMode[2][3];
    bool enable_pec[3];
    uint32_t pec_at[3];  // time period in 20ns ticks
    bool highSpeedMode_fpga[2][3];

    bool motorDirection[2][3];

    uint32_t GotoTarget[3];
    uint32_t GotoNCycles[3];

    uint32_t versionNumber[3];  //_eVal: Version number

    uint32_t stepPerRotation[3];  //_aVal: Steps per axis revolution
    uint32_t stepsPerWorm[3];     //_sVal: Steps per worm gear revolution

    uint32_t minPeriod[3];  // slowest speed allowed
    uint32_t maxPeriod[3];  // Speed at which mount should stop. May be lower
                            // than minSpeed if doing a very slow IVal.

    double backlash_period_usec[3];  // Speed at which mount should stop. May be
                                    // lower than minSpeed if doing a very slow
                                    // IVal.
    uint32_t
        backlash_ticks[3];  // Speed at which mount should stop. May be lower
                            // than minSpeed if doing a very slow IVal.
    uint8_t
        backlash_mode[3];  // Speed at which mount should stop. May be lower
    uint32_t
        backlash_ncycle[3];  // Speed at which mount should stop. May be lower
                             // than minSpeed if doing a very slow IVal.

    std::array<settings, 3> cfg;
    bool  initialized[3]; 
  } parameters;

typedef struct {
    std::atomic<bool> isGoto;
    std::atomic<bool> isSlew;
    std::atomic<bool> isRunning;
    uint32_t currentPeriod;
    std::atomic<bool> currentDirection;
} ip_status;
#endif
