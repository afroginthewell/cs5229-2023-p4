# A-1: Fake Ping (4%)

## Introduction

In practice, network devices (e.g., firewall, routers) generate ICMP messages like Destination Unreachable, Packet Too Big when there are issues encountered in packet forwarding.
To give you a taste on how this is done, you are asked implement a simple P4 program that produces ICMP Echo Replies (though they are not exactly error messages, but the idea is similar) in response to ICMP Echo Requests.

[ICMP messages](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol) are differentiated by their type and code. 
For instance, ICMP Echo Requests are of type 8 and code 0.
To generate an ICMP Echo Reply, the corresponding type and code must be set.
At the same time, the ICMP header checksum needs to be updated accordingly.

Your switch will be connected to one host, `h1`, with a default route to the switch.
We will then perform pings from `h1` to any IP address, and it is expected that the switch will be responding to them, except for the destination addresses that are filtered by `icmp_filter_table`.
There is no other host in this topology.

Our P4 program will be written for the V1Model architecture implemented on P4.org's BMv2 software switch. 
The architecture file for the V1Model can be found at: `/usr/local/share/p4c/p4include/v1model.p4`. 
This file desribes the interfaces of the P4 programmable elements in the architecture, the supported externs, as well as the architecture's standard metadata fields. 
We encourage you to take a look at it.

## Step 1: Run the (incomplete) starter code

The directory with this README also contains a skeleton P4 program, `fake_ping.p4`, which does nothing. 
Your job will be to extend this skeleton program to properly respond to ICMP Echo Requests, and drop ICMP traffic that is filtered by the `icmp_filter_table`.

The list of filtered IP addresses that are installed as table entries can be found at `pod_topo/s1_runtime.json`.

Before that, let's compile the incomplete `fake_ping.p4` and bring up a switch in Mininet to test its behavior.

1. In your shell, run:
   ```bash
   make run
   ```
   This will:
   * compile `fake_ping.p4`, and
   * start the pod-topo in Mininet, and
   * configure all hosts with the commands listed in
   [pod-topo/topology.json](./pod-topo/topology.json)

2. You should now see a Mininet command prompt. 
   Try to ping between any host in the topology:
   ```bash
   mininet> h1 ping 8.8.8.8
   mininet> h1 ping 10.0.0.9
   ```
3. Type `exit` to leave each xterm and the Mininet command line.
   Then, to stop mininet:
   ```bash
   make stop
   ```
   And to delete all pcaps, build files, and logs:
   ```bash
   make clean
   ```

The ping failed because the switch currently has incomplete packet processing logic.
Your job is to complete the implementation so it can respond to ICMP Echo Requests.

## Step 2: Implement Fake Ping

The `fake_ping.p4` file contains a skeleton P4 program with key pieces of
logic replaced by `TODO` comments. Your implementation should follow
the structure given in this file---replace each `TODO` with logic implementing the missing piece.

## Step 3: Run your solution

Follow the instructions from Step 1. This time, you should be able to
sucessfully ping between any IPs from `h1`, except the defined filtered IP address(es).

### Troubleshooting

There are several problems that might manifest as you develop your program:

1. `fake_ping.p4` might fail to compile. In this case, `make run` will report the error emitted from the compiler and halt.

2. `fake_ping.p4` might compile but `h1` might fail to get any ICMP Echo Responses. The `logs/sX.log` files contain detailed logs that describing how each switch processes each packet. The output is detailed and can help pinpoint logic errors in your implementation. At the same time, you can also take a look at the PCAPs under `pcaps/`.

#### Cleaning up Mininet

In the latter two cases above, `make run` may leave a Mininet instance
running in the background. Use the following command to clean up
these instances:

```bash
make stop
```

## Running the Packet Test Framework (PTF)
We will be grading your using the Packet Test Framework (PTF), which allows us to specify test cases with different input/output packets to verify your P4 data plane program behavior.
This is inline with modern software engineering practices.

We have provided some public test cases that you can use to quickly test your program.
For that, simply do `./runptf.sh`.

Note that passing all the public test cases do not necessarily mean that you will get full marks for the exercise as there are other hidden test cases that will be used during grading.
In addition, not all public test cases will be scored as some are purely for sanity check.

## Relevant Documentation

The documentation for P4_16 and P4Runtime is available [here](https://p4.org/specs/).

All excercises in this repository use the `v1model` architecture, the documentation for which is available at:
1. The BMv2 Simple Switch target document accessible [here](https://github.com/p4lang/behavioral-model/blob/master/docs/simple_switch.md) talks mainly about the `v1model` architecture.
2. The include file `v1model.p4` has extensive comments and can be accessed [here](https://github.com/p4lang/p4c/blob/master/p4include/v1model.p4).