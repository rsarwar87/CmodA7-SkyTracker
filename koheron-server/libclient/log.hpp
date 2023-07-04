#ifndef SYSLOG_HPP
#define SYSLOG_HPP

#include <ostream>
#include <streambuf>
#include <string>

#include <syslog.h>

namespace logkk
{

enum level
{
    emergency = LOG_EMERG,
    alert     = LOG_ALERT,
    critical  = LOG_CRIT,
    error     = LOG_ERR,
    warning   = LOG_WARNING,
    notice    = LOG_NOTICE,
    info      = LOG_INFO,
    debug     = LOG_DEBUG,
};

enum type
{
    auth   = LOG_AUTH,
    cron   = LOG_CRON,
    daemon = LOG_DAEMON,
    local0 = LOG_LOCAL0,
    local1 = LOG_LOCAL1,
    local2 = LOG_LOCAL2,
    local3 = LOG_LOCAL3,
    local4 = LOG_LOCAL4,
    local5 = LOG_LOCAL5,
    local6 = LOG_LOCAL6,
    local7 = LOG_LOCAL7,
    print  = LOG_LPR,
    mail   = LOG_MAIL,
    news   = LOG_NEWS,
    user   = LOG_USER,
    uucp   = LOG_UUCP,
};

}

class syslog_stream;

class syslog_streambuf: public std::basic_streambuf<char>
{
public:
    explicit syslog_streambuf(const std::string& name, logkk::type type):
        std::basic_streambuf<char>()
    {
        openlog(name.size() ? name.data() : nullptr, LOG_PID, type);
    }
    ~syslog_streambuf() override { closelog(); }

protected:
    int_type overflow(int_type c = traits_type::eof()) override
    {
        if(traits_type::eq_int_type(c, traits_type::eof()))
            sync();
        else buffer += traits_type::to_char_type(c);

        return c;
    }

    int sync() override
    {
        if(buffer.size())
        {
          std::string output;
          for (const char c: buffer) {
             switch (c) {
                 case '\a':  output += "\\a";        break;
                 case '\b':  output += "\\b";        break;
                 case '\f':  output += "\\f";        break;
                 case '\n':  output += "\\n";        break;
                 case '\r':  output += "\\r";        break;
                 case '\t':  output += "\\t";        break;
                 case '\v':  output += "\\v";        break;
                 default:    output += c;            break;
             }
          }
            syslog(level, "%s", output.data());

            buffer.clear();
            level = ini_level;
        }
        return 0;
    }

    friend class syslog_stream;
    void set_level(logkk::level new_level) noexcept { level = new_level; }

private:
    static constexpr logkk::level ini_level = logkk::info;
    logkk::level level = ini_level;

    std::string buffer;
};

class syslog_stream: public std::basic_ostream<char>
{
public:
    explicit syslog_stream(const std::string& name = std::string(), logkk::type type = logkk::user):
        std::basic_ostream<char>(&streambuf),
        streambuf(name, type)
    { }

    syslog_stream& operator<<(logkk::level level) noexcept
    {
        streambuf.set_level(level);
        return (*this);
    }

private:
    syslog_streambuf streambuf;
};

#endif // SYSLOG_HPP
