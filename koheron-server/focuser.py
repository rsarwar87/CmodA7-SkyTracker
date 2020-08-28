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
        return self.client.recv_bool()
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
    def GetTemp(self, channel):
        return self.client.recv_uint32()
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



if __name__ == '__main__':
    host = os.getenv('HOST','192.168.1.140')
    client = connect(host, name='mars_star_tracker')
    driver = FocuserInterface(client)
    print('get_temp: {0}'.format(driver.GetTemp(20)/4096*3.3*1.5*100))





