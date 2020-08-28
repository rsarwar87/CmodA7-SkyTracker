#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from koheron import command, connect
import time
import pdb

class FocuserInterface(object):
    def __init__(self, client):
        self.client = client

    # setter
    @command()
    def Initialize(self):
        return self.client.recv_bool()
    @command()
    def BoardVersion(self):
        return self.client.recv_uint32()
    @command()
    def GetGridPerRevolution(self):
        return self.client.recv_uint32()
    @command()
    def GetTimerInterruptFreq(self):
        return self.client.recv_uint32()
    @command()
    def StopFocuser(self, instant):
        return self.client.recv_bool()
    @command()
    def SetFocuserPosition(self, value):
        return self.client.recv_bool()
    @command()
    def GetFocuserPosition(self):
        return self.client.recv_uint32()
    @command()
    def GetFocuserAxisStatus(self):
        return self.client.recv_array(8, dtype='bool')
    @command()
    def FocuserIncrement(self, ncycles, period_ticks, direction):
        return self.client.recv_bool()
    @command()
    def FocuserGotoTarget(self, ncycles, period_ticks, direction):
        return self.client.recv_bool()
    @command()
    def FocuserSlewTo(self, period_ticks, direction):
        return self.client.recv_bool()
    @command()
    def GetFocuserHomePosition(self):
        return self.client.recv_uint32()
    @command()
    def GetTemp_pi1w(self):
        return self.client.recv_float()
    @command()
    def GetTemp_fpga(self, channel):
        return self.client.recv_float()
    @command()
    def set_min_period(self, val):
        return self.client.recv_bool()
    @command()
    def set_max_period(self, val):
        return self.client.recv_bool()
    @command()
    def get_min_period_ticks(self):
        return self.client.recv_uint32()
    @command()
    def get_max_period_ticks(self):
        return self.client.recv_uint32()
    @command()
    def get_backlash_period(self):
        return self.client.recv_uint32()
    @command()
    def get_backlash_cycles(self):
        return self.client.recv_uint32()

    def print_status(self):
        ret = driver.GetFocuserAxisStatus()
        print('Initialized: {0}'.format(ret[0]))
        print('IsRunning: {0}'.format(ret[1]))
        print('Direction: {0}'.format(ret[2]))
        print('SpeedMode: {0}'.format(ret[3]))
        print('IsGoto: {0}'.format(ret[4]))
        print('IsSlewTo: {0}'.format(ret[5]))
        print('Backlash Active: {0}'.format(ret[6]))
        print('HasFault: {0}'.format(ret[7]))

    def PrintAll(self):
        print('\n\BoardVersion: {0}'.format(self.BoardVersion()))
        print('GetGridPerRevolution: {0}'.format(self.GetGridPerRevolution()))
        print('GetTimerInterruptFreq: {0}'.format(self.GetTimerInterruptFreq()))
        print('GetFocuserPosition: {0}'.format(self.GetFocuserPosition()))
        print('GetFocuserHomePosition: {0}'.format(self.GetFocuserHomePosition()))
        print('get_min_period_ticks: {0}'.format(self.get_min_period_ticks()))
        print('get_max_period_ticks: {0}'.format(self.get_max_period_ticks()))
        print('get_backlash_cycles: {0}'.format(self.get_backlash_cycles()))
        print('get_backlash_period: {0}'.format(self.get_backlash_period()))


if __name__ == '__main__':
    host = os.getenv('HOST','192.168.1.140')
    client = connect(host, name='mars_star_tracker')
    driver = FocuserInterface(client)
    print('get_temp: {0}'.format(driver.GetTemp_pi1w()))
    print('Initialize: {0}'.format(driver.Initialize()))
    driver.print_status()







