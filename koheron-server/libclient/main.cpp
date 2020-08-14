#include "log.hpp"
#include <iostream>

int main(){
 std::cout << "Hello World" << std::endl;
syslog_stream clog;

clog << "Hello, world!" << std::endl;
clog << log::emergency << "foo" << "bar" << "baz" << 42 << std::endl;
 return 0;
}
