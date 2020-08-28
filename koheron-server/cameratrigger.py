#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from koheron import command, connect
import time
import pdb

class CameraInterface(object):
    def __init__(self, client):
        self.client = client

    # setter
    @command()
    def set_cameratrigger_reg(self, value, isfpga):
        return self.client.recv_bool()
    @command()
    def get_cameratrigger_reg(self):  # fpga only
        return self.client.recv_bool()
    @command()
    def open_shutter(self, fpga):  # fpga only
        return self.client.recv_bool()
    @command()
    def close_shutter(self, fpga):  # fpga only
        return self.client.recv_bool()


if __name__ == '__main__':
    host = os.getenv('HOST','192.168.1.140')
    client = connect(host, name='mars_star_tracker')
    driver = CameraInterface(client)


    isfpga = False

    while True:
        driver.open_shutter(isfpga)
        time.sleep(1)
        driver.close_shutter(isfpga)
        time.sleep(1)






