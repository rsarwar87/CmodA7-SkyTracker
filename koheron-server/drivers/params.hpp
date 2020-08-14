#ifndef __HEADER_PARAMS_
#define __HEADER_PARAMS_
typedef struct {
    // class variables
    double period_usec[2][2];      // time period in us
    uint32_t period_ticks[2][2];  // time period in 20ns ticks
    double speed_ratio[2][2];      // speed of motor
    bool highSpeedMode[2][2];

    uint8_t motorMode[2][2];  // microsteps
    bool motorDirection[2][2];

    uint32_t GotoTarget[2];
    uint32_t GotoNCycles[2];

    uint32_t versionNumber[2];  //_eVal: Version number

    uint32_t stepPerRotation[2];  //_aVal: Steps per axis revolution
    uint32_t stepsPerWorm[2];     //_sVal: Steps per worm gear revolution

    uint32_t minPeriod[2];  // slowest speed allowed
    uint32_t maxPeriod[2];  // Speed at which mount should stop. May be lower
                            // than minSpeed if doing a very slow IVal.

    double backlash_period_usec[2];  // Speed at which mount should stop. May be
                                    // lower than minSpeed if doing a very slow
                                    // IVal.
    uint32_t
        backlash_ticks[2];  // Speed at which mount should stop. May be lower
                            // than minSpeed if doing a very slow IVal.
    uint8_t
        backlash_mode[2];  // Speed at which mount should stop. May be lower
    uint32_t
        backlash_ncycle[2];  // Speed at which mount should stop. May be lower
                             // than minSpeed if doing a very slow IVal.
    bool  initialized[2]; 
  } parameters;

#endif
