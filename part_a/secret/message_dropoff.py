#!/usr/bin/env python3
import random
import socket
import sys

from scapy.all import *

class SECRET(Packet):
    name = "Secret"
    fields_desc = [
        BitField("opCode", 0, 16),
        BitField("mailboxNum", 0, 16),
        BitField("message", 0, 32)
    ]

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

def main():
    if len(sys.argv)<3:
        print('pass 2 arguments: <mailbox number> "<message>"')
        exit(1)

    mailboxNum = int(sys.argv[1])
    message = int.from_bytes(bytes(sys.argv[2],'UTF-8'), byteorder='big')

    addr = socket.gethostbyname("10.0.0.254")
    iface = get_if()
    bind_layers(UDP, SECRET, sport=0xFFFF, dport=0xFFFF)

    print("sending on interface %s to %s" % (iface, str(addr)))
    pkt =  Ether(src=get_if_hwaddr(iface), dst="08:00:00:00:FF:FF")
    pkt = pkt /IP(dst=addr) / UDP(dport=0xFFFF, sport=0xFFFF, chksum=0) / SECRET(opCode=1, mailboxNum=mailboxNum, message=message)
    pkt.show2()
    res_p = srp1(pkt, iface=iface, verbose=False, timeout=2)
    if not res_p:
        print("Timeout! No message received.")
    else:
        res_p.show()


if __name__ == '__main__':
    main()
