#ifndef __CONFIG_KOHERON__
#define __CONFIG_KOHERON__
#include "rapidjson/rapidjson.h"     // rapidjson's DOM-style API
#include "rapidjson/document.h"     // rapidjson's DOM-style API
#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h" // for stringify JSON
#include "params.hpp"
#include <context.hpp>
#include <fstream>
#include <vector>
#include <array>
#include <iostream>
#include <cstdio>
#include <stdexcept>
#include <type_traits>
#include "rapidjson/filereadstream.h"
#include "rapidjson/filewritestream.h"
using namespace rapidjson;

class CfgConfig {
  public:
      CfgConfig(const std::string& path, parameters* params, Context& ctx_)
      : ctx(ctx_)
      {
        m_path = path;
        m_params = params;
        //std::string str = GetFileContent();
        FILE* fp = fopen(m_path.c_str(), "r");
        char str[65536];
        if (fp != NULL)
        FileReadStream is(fp, str, sizeof(str));
        else
          ctx.log<ERROR>("CfgCnfig: %s- Failed open init file\n",__func__);


        if (m_doc.ParseInsitu(&str[0]).HasParseError() && !m_doc.IsObject())
        {
          ctx.log<ERROR>("CfgCnfig: %s- Failed load init file\n",__func__);
          printf("\nParsing to document succeeded.\n");
          std::string _str = "{ }";//init();
          m_doc.ParseInsitu(&_str[0]);
        }
        if (fp != NULL)
        fclose(fp);
        sanity_checks();
      }

      void PrintData()
      {
        ctx.log<INFO>("CfgCnfig: %s- %s\n",__func__, JToString());
      }

      void SaveFileContent()
      {
        /*FILE* fp = fopen(m_path.c_str(), "w"); // non-Windows use "w"
 
        char writeBuffer[65536];
        FileWriteStream os(fp, writeBuffer, sizeof(writeBuffer));
         
        Writer<FileWriteStream> writer(os);
        m_doc.Accept(writer);
         
        fclose(fp);
        */
        std::ofstream file(m_path);
        std::string str = JToString();
        file.write(str.c_str(), str.size());
        file.close();
        
        return;
      }
      void RemoteUnwantedOnes()
      {
        std::vector<std::string> vec;
        for (Value::ConstMemberIterator itr = m_doc.MemberBegin();
            itr != m_doc.MemberEnd(); ++itr)
        {
            if (!(
               strcom(itr->name.GetString(), "MotorModeSlew")     || 
               strcom(itr->name.GetString(), "MotorModeGoTo")     || 
               strcom(itr->name.GetString(), "MotorUStepping")     || 
               strcom(itr->name.GetString(), "MotorFullStepCount") || 
               strcom(itr->name.GetString(), "HighGearTicks")      || 
               strcom(itr->name.GetString(), "IsTMC")              ||
               strcom(itr->name.GetString(), "LowGearTicks")      ||
               strcom(itr->name.GetString(), "MinPeriodUsec")      ||
               strcom(itr->name.GetString(), "MountGearTicks")      ||
               strcom(itr->name.GetString(), "MaxPeriodUsec") 
                ))
            {
                vec.push_back (itr->name.GetString());
            }
        }
        for (size_t i = 0; i < vec.size(); i++)
        {
          m_doc.RemoveMember(vec.at(i).c_str());
        }
      }
    bool sanity_checks()
    {
      bool ret = true;
      ret &= check_member<double>   ("MinPeriodUsec"      , {15, 15, 15} );
      ret &= check_member<double>   ("MaxPeriodUsec"      , {268435.0, 268435.0, 268435.0});
      ret &= check_member<uint8_t>   ("MotorModeSlew"     , {7,7,7});
      ret &= check_member<uint8_t>   ("MotorModeGoTo"     , {7,7,7});
      ret &= check_member<uint8_t>   ("MotorUStepping"    , {32,32,32});
      ret &= check_member<uint8_t>   ("MotorFullStepCount", {200,200,200});
      ret &= check_member<uint8_t>   ("HighGearTicks"     , {60,60,60});
      ret &= check_member<uint8_t>   ("LowGearTicks"      , {12,12,12});
      ret &= check_member<uint8_t>   ("MountGearTicks"    , {144,144,144});
      ret &= check_member<bool>   ("IsTMC"                , {false,false,false});
      if (ret)
        ctx.log<INFO>("CfgCnfig: %s- Config loaded successfully\n",__func__);
      else
        ctx.log<ERROR>("CfgCnfig: %s- Failed to load config\n",__func__);

      return ret;
    }

    bool PushData()
    {
      bool ret = true;
      m_doc.RemoveAllMembers();
      ret &= push_member<double>   ("MinPeriodUsec", m_params->minPeriod_usec);
      ret &= push_member<double>   ("MaxPeriodUsec", m_params->maxPeriod_usec);
      ret &= push_member<uint8_t>   ("MotorModeSlew", m_params->motorMode[0]);
      ret &= push_member<uint8_t>   ("MotorModeGoTo", m_params->motorMode[1]);
      ret &= push_member<uint8_t>   ("MotorUStepping", m_params->motor_ustepping);
      ret &= push_member<uint8_t>   ("MotorFullStepCount", m_params->motor_revticks);
      ret &= push_member<uint8_t>   ("HighGearTicks", m_params->high_gear_ticks);
      ret &= push_member<uint8_t>   ("LowGearTicks", m_params->low_gear_ticks);
      ret &= push_member<uint8_t>   ("MountGearTicks", m_params->mount_gearticks);
      ret &= push_member<bool>   ("IsTMC", m_params->is_TMC);
      if (ret)
        ctx.log<INFO>("CfgCnfig: %s- Config pushed successfully\n",__func__);
      else
        ctx.log<ERROR>("CfgCnfig: %s- Failed to push config\n",__func__);
      return ret;
    
    }

    bool PullData()
    {
      bool ret = true;
      ret &= pull_member<double>   ("MinPeriodUsec", m_params->minPeriod_usec);
      ret &= pull_member<double>   ("MaxPeriodUsec", m_params->maxPeriod_usec);
      ret &= pull_member<uint8_t>   ("MotorModeSlew", m_params->motorMode[0]);
      ret &= pull_member<uint8_t>   ("MotorModeGoTo", m_params->motorMode[1]);
      ret &= pull_member<uint8_t>   ("MotorUStepping", m_params->motor_ustepping);
      ret &= pull_member<uint8_t>   ("MotorFullStepCount", m_params->motor_revticks);
      ret &= pull_member<uint8_t>   ("HighGearTicks", m_params->high_gear_ticks);
      ret &= pull_member<uint8_t>   ("LowGearTicks", m_params->low_gear_ticks);
      ret &= pull_member<uint8_t>   ("MountGearTicks", m_params->mount_gearticks);
      ret &= pull_member<bool>   ("IsTMC", m_params->is_TMC);
      if (ret)
        ctx.log<INFO>("CfgCnfig: %s- Config pulled successfully\n",__func__);
      else
        ctx.log<ERROR>("CfgCnfig: %s- Failed to pull config\n",__func__);
      return ret;
    
    }
  private:
    std::string m_path;
    Document m_doc;  // Default template parameter uses UTF8 and MemoryPoolAllocator.
    parameters *m_params;

    Context& ctx;

    template<typename Tw>
    bool pull_member(std::string key, Tw* ptr)
    {
      const Value& a = m_doc[key.c_str()];  
      for (SizeType i = 0; i < a.Size(); i++) // rapidjson uses SizeType instead of size_t.
      {
        if (std::is_same<Tw, double>())
          ptr[i] = a[i].GetDouble();
        else if (std::is_same<Tw, uint32_t>() || std::is_same<Tw, uint8_t>() ) 
          ptr[i] = a[i].GetUint();
        else if (std::is_same<Tw, bool>())
          ptr[i] = a[i].GetBool();
        else
        {
          ctx.log<ERROR>("CfgCnfig: %s- unidentified type %s; \n",__func__, key.c_str());
          return false;
        }
      } 
      
      return true;
    }
    template<typename Tw>
    bool push_member(std::string key, Tw* ptr)
    {
      return check_member<Tw>(key, {ptr[0], ptr[1], ptr[2]});
      /*Value& a = m_doc[key.c_str()];  
      for (SizeType i = 0; i < a.Size(); i++) // rapidjson uses SizeType instead of size_t.
      {
        if (std::is_same<Tw, double>())
          a[i].SetDouble(ptr[i]);
        else if (std::is_same<Tw, uint32_t>() || std::is_same<Tw, uint8_t>() ) 
          a[i].SetUint(ptr[i]);
        else if (std::is_same<Tw, bool>())
          a[i].SetBool(ptr[i]);
        else
        {
          ctx.log<ERROR>("CfgCnfig: %s- unidentified type %s; \n",__func__, key.c_str());
          return false;
        }
      } 
      */
      return true;
    }

    template<typename Tw>
    bool check_member(std::string key, std::array<Tw, 3> def)
    {
      Type T;
      int ret = 0;
      if (std::is_same<Tw, double>() || std::is_same<Tw, uint32_t>() || std::is_same<Tw, uint8_t>())
      {
        ret = check_cfg<kNumberType>(key);
        T = kNumberType;
      }
      else if (std::is_same<Tw, bool>())
      {
        ret = check_cfg<kTrueType>(key);
        T = kTrueType;
      }
      else
      {
          std::cout << "unidentified type" << std::endl;
          return false;
      }
      if (ret == 0) return true;
      if (ret != 1)
      {
        m_doc.RemoveMember(key.c_str());
      }
      Value ar(kArrayType);
      Value vals[3];
      Value valk;
      valk.SetString(key.c_str(), key.size(),m_doc.GetAllocator());
      for (size_t i = 0; i < 3; i++)
      {
        if (std::is_same<Tw, double>())
          vals[i].SetDouble(def[i]);
        else if (std::is_same<Tw, uint32_t>() || std::is_same<Tw, uint8_t>() ) 
          vals[i].SetUint(def[i]);
        else if (std::is_same<Tw, bool>())
          vals[i].SetBool(def[i]);
        else
        {
          ctx.log<ERROR>("CfgCnfig: %s- unidentified type %s; code: %u\n",__func__, key.c_str(), T);
          return false;
        }
        ar.PushBack(vals[i], m_doc.GetAllocator());
      }
      m_doc.AddMember(valk, ar, m_doc.GetAllocator());
      
      return true;
    }

    std::string JToString()
    {
        StringBuffer sb;
        PrettyWriter<StringBuffer> writer(sb);
        m_doc.Accept(writer);    // Accept() traverses the DOM and generates Handler events.
        return sb.GetString();
    }
    template<Type T>
    int check_cfg(std::string key)
    {
      try{
      if (!m_doc.HasMember(key.c_str())) return 1;
      if (!m_doc[key.c_str()].IsArray()) return 2;
      
      const Value& a = m_doc[key.c_str()];
      if (a.Size() != 3)
      {
        ctx.log<ERROR>("CfgCnfig: %s- Array size mismatch %s; got: %u\n",__func__, key.c_str(), a.Size());
        return 3;
      }
      for (size_t i = 0; i < a.Size(); i++)
        if (T != kTrueType && T != kFalseType)
        {
          if (a[i].GetType() != T) 
          {
            ctx.log<ERROR>("CfgCnfig: %s- Type mismatch %s; got: %u\n",__func__, key.c_str(), a[i].GetType());
            return 4;
          }
        }
        else
        {
          if (!a[i].IsBool()) 
          {
            ctx.log<ERROR>("CfgCnfig: %s- Type mismatch %s; got: %u\n",__func__, key.c_str(), a[i].GetType());
            return 4;
          }
        }
      }
      catch(std::runtime_error const& e)
      {
        ctx.log<PANIC>("CfgCnfig: %s- catch %s\n",__func__, e.what());
      }
      return 0;
    }


    bool strcom (std::string str1, std::string str2)
    {
      return (str1.compare(str2) == 0);
    }
};






/*enum Type {
    kNullType = 0,      //!< null
    kFalseType = 1,     //!< false
    kTrueType = 2,      //!< true
    kObjectType = 3,    //!< object
    kArrayType = 4,     //!< array 
    kStringType = 5,    //!< string
    kNumberType = 6     //!< number
};
*/
#endif
