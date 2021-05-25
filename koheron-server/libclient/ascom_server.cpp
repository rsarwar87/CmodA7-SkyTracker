// Server side C/C++ program to demonstrate Socket programming
#include <inttypes.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include <iomanip>
#include <sstream>
#include <koheron-client.hpp>
#include "log.hpp"

namespace sky_driver {
static std::unique_ptr<KoheronClient> client;
static syslog_stream klog;
}
using namespace sky_driver;
#define PORT 8899

#define numberOfCommands 40

const char startInChar = ':';
const char startOutChar = '=';
const char errorChar = '!';
const char endChar = '\r';
const char cmd_commands[numberOfCommands][3] = {
    {'j', 0,
     6},  // arranged in order of most frequently used to reduce searching time.
    {'f', 0, 3}, {'I', 6, 0}, {'G', 2, 0}, {'J', 0, 0}, {'K', 0, 0},
    {'H', 6, 0}, {'M', 6, 0}, {'e', 0, 6}, {'a', 0, 6}, {'b', 0, 6},
    {'g', 0, 2}, {'s', 0, 6}, {'E', 6, 0}, {'P', 1, 0}, {'F', 0, 0},
    {'L', 0, 0}, {'V', 2, 0},
    // Programmer Entry Command
    {'O', 1, 0},
    // Programmer Commands - Ignored in Run-Mode
    {'A', 6, 0}, {'B', 6, 0}, {'S', 6, 0}, {'n', 0, 6}, {'N', 6, 0},
    {'D', 2, 0}, {'d', 0, 2}, {'C', 1, 0}, {'c', 0, 2}, {'Z', 2, 0},
    {'z', 0, 2}, {'R', 6, 0}, {'r', 0, 6}, {'Q', 2, 0}, {'q', 0, 2},
    {'o', 0, 2}, {'X', 6, 0}, {'x', 0, 6}, {'Y', 2, 0}, {'W', 2, 0},
    {'T', 1, 0}};

char Commands_getLength(char cmd, bool sendRecieve);
uint32_t Revu24str2long(char *s);
void synta_assembleResponse(char *dataPacket, char commandOrError,
                            unsigned long responseData);

char Commands_getLength(char cmd, bool sendRecieve) {
  for (size_t i = 0; i < numberOfCommands; i++) {
    if (cmd_commands[i][0] == cmd) {
      if (sendRecieve) {
        return cmd_commands[i][1];
      } else {
        return cmd_commands[i][2];
      }
    }
  }
  return -1;
}
void synta_assembleResponse(char *dataPacket, char commandOrError,
                            unsigned long responseData) {
  char replyLength =
      (commandOrError == '\0')
          ? -1
          : Commands_getLength(commandOrError,
                               0);  // get the number of data bytes for response
  char hexa[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
                   '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

  if (replyLength < 0) {
    replyLength = 0;
    dataPacket[0] = errorChar;
  } else {
    dataPacket[0] = startOutChar;

    if (replyLength == 2) {
      dataPacket[1] = hexa[(responseData & 0xF0) >> 4];
      dataPacket[2] = hexa[(responseData & 0x0F)];
    } else if (replyLength == 3) {
      dataPacket[1] = hexa[(responseData & 0xF0) >> 4];
      dataPacket[2] = hexa[(responseData & 0x0F)];
      dataPacket[3] = hexa[(responseData & 0xF00) >> 8];
    } else if (replyLength == 6) {
      dataPacket[1] = hexa[(responseData & 0xF0) >> 4];
      dataPacket[2] = hexa[(responseData & 0x0F)];
      dataPacket[3] = hexa[(responseData & 0xF000) >> 12];
      dataPacket[4] = hexa[(responseData & 0x0F00) >> 8];
      dataPacket[5] = hexa[(responseData & 0xF00000) >> 20];
      dataPacket[6] = hexa[(responseData & 0x0F0000) >> 16];
    }
    // dataPacket = dataPacket + (size_t)replyLength;
  }
  dataPacket[replyLength + 1] = endChar;
  dataPacket[replyLength + 2] = '\0';
  return;
}
#define HEX(c) (((c) < 'A') ? ((c) - '0') : ((c) - 'A') + 10)

uint32_t Revu24str2long(char *s) {
  uint32_t res = 0;
  res = HEX(s[4]);
  res <<= 4;
  res |= HEX(s[5]);
  res <<= 4;
  res |= HEX(s[2]);
  res <<= 4;
  res |= HEX(s[3]);
  res <<= 4;
  res |= HEX(s[0]);
  res <<= 4;
  res |= HEX(s[1]);
  return res;
}

int main(int argc, char const *argv[]) {
  int server_fd, new_socket, valread;
  struct sockaddr_in address;
  int opt = 1;
  int addrlen = sizeof(address);
  char buffer[1024] = {0};

  // Creating socket file descriptor
  if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
    klog << "socket failed" << std::endl;
    exit(EXIT_FAILURE);
  }

  // Forcefully attaching socket to the port 8080
  if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt,
                 sizeof(opt))) {
    klog << "setsockopt failed" << std::endl;
    exit(EXIT_FAILURE);
  }
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port = htons(PORT);

  // Forcefully attaching socket to the port 8080
  if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
    klog << "bind failed" << std::endl;
    exit(EXIT_FAILURE);
  }
  if (listen(server_fd, 3) < 0) {
    klog << "listen failed" << std::endl;
    exit(EXIT_FAILURE);
  }
  if ((new_socket = accept(server_fd, (struct sockaddr *)&address,
                           (socklen_t *)&addrlen)) < 0) {
    klog << "accept failed" << std::endl;
    exit(EXIT_FAILURE);
  }

  klog << "Initializing driver - connecting to koheron server@"
       << "127.0.0.1"
       << ":" << 36000 << std::endl;
  client = std::make_unique<KoheronClient>("127.0.0.1", 36000);
  client->connect();
  klog << "Initialization completed" << std::endl;

  bool isSlew = false;
  bool isForward = false;
  bool isIncrement = false;
  char command[64];
  for (;;) {
    valread = read(new_socket, buffer, 1024);

    if (buffer[0] == ':') {
      uint8_t axis = HEX(buffer[2]);
      switch (buffer[1]) {
        case 'e': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetBoardVersion>();
          resp =
              client->recv<op::ASCOMInterface::SwpGetBoardVersion, uint32_t>();
          klog << "InquireMotorBoardVersion Axis" << axis << " " << resp
               << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'g': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetHighSpeedRatio>(axis);
          resp = (uint32_t)client
                     ->recv<op::ASCOMInterface::SwpGetHighSpeedRatio, double>();
          klog << "InquireHighSpeedRatio Axis" << axis << " " << resp
               << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'b': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetTimerInterruptFreq>();
          resp = client->recv<op::ASCOMInterface::SwpGetTimerInterruptFreq,
                              uint32_t>();
          klog << "InquireTimerInterruptFreq Axis" << axis << " " << resp
               << std::endl;
          synta_assembleResponse(command, buffer[1], resp / 5);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'f': {
          unsigned int fVal = 0;
          client->call<op::ASCOMInterface::SwpGetAxisStatus>(axis);
          std::array<bool, 8> resp = client->recv<op::ASCOMInterface::SwpGetAxisStatus, std::array<bool, 8>>();
          /*if (false ) {    //cmd.highSpeedMode[target]
            fVal |= (1 << 10);
          }*/
          if (resp[2] /*cmd.dir[target]*/) {
            fVal |= (1 << 9);
          }
          if (resp[5] /*!cmd.gotoEn[target]*/) {
            fVal |= (1 << 8);
          }
          if (resp[1] /*!cmd.stopped[target]*/) {
            fVal |= (1 << 4);
          }
          if (resp[0] /*cmd.FVal[target]*/) {
            fVal |= (1 << 0);
          }
          synta_assembleResponse(command, buffer[1], fVal);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'P': {
          uint32_t resp = 0;
          klog << "SetST4GuideRateCmd Axis" << axis << " " << resp << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'W': {
          uint32_t resp = 0;
          uint8_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetFeature>(axis, cmd);
          resp = client->recv<op::ASCOMInterface::SwpSetFeature, bool>();
          klog << "SetFeatureCmd Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'q': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetFeature>(axis);
          resp = client->recv<op::ASCOMInterface::SwpGetFeature, uint32_t>();
          klog << "GetFeatureCmd Axis" << axis << " " << resp << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'a': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetGridPerRevolution>(axis);
          resp = client->recv<op::ASCOMInterface::SwpGetGridPerRevolution,
                              uint32_t>();
          klog << "InquireGridPerRevolution Axis" << axis << " " << resp
               << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'j': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpGetAxisPosition>(axis);
          resp =
              client->recv<op::ASCOMInterface::SwpGetAxisPosition, uint32_t>();
          klog << "GetAxisPosition Axis" << axis << " " << resp << std::endl;
          synta_assembleResponse(command, buffer[1], resp);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'E': {
          uint32_t resp = 0;
          uint32_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetAxisPosition>(axis, cmd);
          resp = client->recv<op::ASCOMInterface::SwpSetAxisPosition, bool>();
          klog << "SetAxisPositionCmd Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'F': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpCmdInitialize>(axis);
          resp = client->recv<op::ASCOMInterface::SwpCmdInitialize, bool>();
          klog << "Initialize Axis" << axis << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'L': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpCmdStopAxis>(axis, true);
          resp = client->recv<op::ASCOMInterface::SwpCmdStopAxis, bool>();
          klog << "InstantAxisStop Axis" << axis << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'K': {
          uint32_t resp = 0;
          client->call<op::ASCOMInterface::SwpCmdStopAxis>(axis, false);
          resp = client->recv<op::ASCOMInterface::SwpCmdStopAxis, bool>();
          klog << "NotInstantAxisStop Axis" << axis << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'O': {
          synta_assembleResponse(command, buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'G': {
          uint16_t cmd = Revu24str2long(buffer + 2);
          isForward = (buffer[4] != '0') ? false : true;
          isSlew = (((buffer[2] - '0') & 0x1)  == 0) ? false : true;
          client->call<op::ASCOMInterface::SwpSetMotionModeDirection>(axis, isForward, isSlew, false);
          bool resp = client->recv<op::ASCOMInterface::SwpSetMotionModeDirection, bool>();
          klog << "SetMotionMode Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'B': {
          klog << "---ActivateMotor-- why?";
          synta_assembleResponse(command, buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'V': {
          uint8_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetPolarScopeLED>(cmd, true);
          bool resp = client->recv<op::ASCOMInterface::SwpSetPolarScopeLED, bool>();
          klog << "SwpSetPolarScopeLED Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'I': {
          uint32_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetStepPeriod>(axis, isSlew, cmd);
          bool resp = client->recv<op::ASCOMInterface::SwpSetStepPeriod, bool>();
          klog << "SetStepPeriod Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'J': {
          client->call<op::ASCOMInterface::SwpCmdStartMotion>(axis, isSlew, true, isIncrement);
          bool resp = client->recv<op::ASCOMInterface::SwpCmdStartMotion, bool>();
          klog << "StartMotion Axis" << axis << " " << resp<< std::endl;
          synta_assembleResponse(command, resp == false ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'U': {
          klog << "---SetBreakStep -- why?";
          synta_assembleResponse(command, buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'M': {
          klog << "---SetBreakPointIncrement -- why?";
          synta_assembleResponse(command, buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'H': {
          uint32_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetGotoTargetIncrement>(axis, cmd);
          bool resp = client->recv<op::ASCOMInterface::SwpSetGotoTargetIncrement, bool>();
          if (resp) isIncrement = true;
          klog << "SetGotoTargetIncrement Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        case 'S': {
          uint32_t cmd = Revu24str2long(buffer + 2);
          client->call<op::ASCOMInterface::SwpSetGotoTarget>(axis, cmd);
          bool resp = client->recv<op::ASCOMInterface::SwpSetGotoTarget, bool>();
          if (resp) isIncrement = false;
          klog << "SetGotoTarget Axis" << axis << " " << cmd << std::endl;
          synta_assembleResponse(command, resp == 0 ? '\0' : buffer[1], 0);
          send(new_socket, command, strlen(command), 0);
          break;
        }
        default:
          klog << "Unknown Command Recieved: " << buffer << "(" << valread << ")" << std::endl;
      }
    }
  }
  return 0;
}
