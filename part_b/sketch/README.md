# B: Network Monitoring with Sketches (10%)

## Introduction

Sketches are one of the commonly used probabilistic data structures used for 
counting given their sublinear memory requirements.

In this exercise, we will keep track of per-flow packet counts using sketches to perform heavy-hitter detection, i.e., detecting elephant flows.
Here, we refer heavy-hitter as a flow exceeding a certain threshold, i.e., `hh_threshold`.
You will be given a packet trace which will be replayed to simulate live network traffic.
Elephant flows that are detected will be mirrored to an external collector.

The packets received at the collector will be compared against the groundtruth and graded.
Your implementation should capture all the heavy hitters and report them (i.e., the first packet that exceeds the `hh_threshold`) to the external collector.
Also, there should not be any duplicate reports.
For example, if there are three heavy flows A, B, and C, but if the collector received duplicate reports of A, A, A, we treat it as one heavy flow detected only.
We configure the collector such that it will only collect the first *n* packets.

The provided traces also contain some suspicious DNS response traffic that are likely to be part of an DNS amplification attack.
As a precautionary measure, we drop these traffic when they exceed the another threshold, i.e., `drop_threshold`.
<!-- Once the `drop_threshold` is hit, the corresponding traffic must be dropped by the switch for the potential victim. -->

You are allowed to modify the provided sketch to use *any* other variants should you see fit to minimize the error rates.
However, you are strictly limited to use only up to 4 rows with up to 65536 entries in total.
Also, you should not change the naming scheme of the sketches, i.e., `sketch_rowX`, where `X` is 0, 1, 2, 3.
This will be inspected separately.

For this exercise, we provide you with two short packet traces under `sample-trace`.
In these short traces, as the counts are small and the number of flows are less, the expected error rates should be little to none.
This helps you to develop and validate your program with greater ease when comparing against the groundtruth.

That said, during grading, a long trace will be used.
In such cases, we allow an error rate of up to 10%.
For instance, if our threshold is at 100, we will account flows that have up to 110 packets as part of the HH flows from the groundtruth when evaluating your program as a true positive.

## Step 1: Running (incomplete) starter code

The directory with this README also contains a skeleton P4 program, `sketch.p4`.
Your job will be to extend this skeleton program to detect heavy-hitters and drop suspicious DNS traffic.

First, compile the incomplete `sketch.p4` and bring up a switch in Mininet to test its behavior.
To do that, do `make run`.
Next, in a separate terminal, run the script `./mirror_cmd_cfg.sh` to configure the mirroring session on the switch.
This is to mirror the detected heavy flows to the external collector located at port 3.

We have defined the rules that are to be installed to the `ipv4_forward` table, and a pre-configured threshold value in  the `get_thresholds` table (see `pod-topo/s1-runtime.json`).
The pre-configure threshold values are catered to the provided sample traces found under `sample-trace/`.

> Note: You can create your own traces for testing, and make sure to update the threshold values to fit your own trace.

Next, bring up three XTerm terminals for each hosts:
```bash
mininet> xterm h1 h2 h3
```

Before replaying the traces, we shall set up the collector at `h3`.
On `h3`, do the following:
```bash
# this is from h3's xterm terminal
root@p4# ./hh_collector.py 5
```
You can specify the number of reports that the collector should wait for.
The collector will print out a report at the end of the collection.

The provided sample traces currently have suspicious DNS response traffic destined towards `h2`.
We will do `tcpdump` on `h2` to observe these packets, and also to check if they are eventually dropped.
To observe these packets, do:
```bash
# this is from h2's xterm terminal
root@p4# tcpdump -i eth0 -n
```

Once `h2` and `h3` are ready, you can proceed to replay the traces.
To replay the traces, use the `generate_traffic.py` script.
You should do it from `h1`. 
An example are as follow:
```bash
# this is from h1's xterm terminal
root@p4# ./generate_traffic.p4 ./sample-trace/01-trace.csv
```
The `generate_traffic.py` script will print out a checkpoint for every 100 packet replayed.

Currently, you should not be receiving any traffic on `h2` and `h3` as the switch logic is not implemented.
Your job is to extend this file so it can forward traffic between h1 and h2, detect HH flows and drop suspicious DNS response traffic.

## Step 2: Implementation

The `sketch.p4` file contains a skeleton P4 program with key pieces of logic replaced by `TODO` comments. Your implementation should follow the structure given in this file---replace each `TODO` with logic implementing the missing piece.

## Step 3: Run your solution

Follow the instructions from Step 1.

The following discussion assumes the default thresholds configured at `pod-topo/s1-runtime.json`.

1. If you are replaying the trace `01-trace.csv`, the collector at `h3` should print out the first 5 HHs reported.
It should corresponding to the first 5 flows in `01-groundtruth.csv`.
At the same time, `h2` should receive less than ~100s of DNS response traffic as some of them will be dropped after hitting the `drop_threshold`.

2. On the other hand, if you are using `02-trace.csv`. you can set the collector at `h3` to expect only 1 flow.
Similarly, at `h2` you should only see half of DNS response traffic which the other half will be dropped after hitting the `drop_threshold`. 

### Troubleshooting

There are several problems that might manifest as you develop your program:

1. `sketch.p4` might fail to compile. In this case, `make run` will report the error emitted from the compiler and halt.

2. `sketch.p4` might compile but you might not be getting the HH reports or the DNS responses are not dropped. The `logs/sX.log` files contain detailed logs that describing how each switch processes each packet. The output is detailed and can help pinpoint logic errors in your implementation. At the same time, you can also take a look at the PCAPs under `pcaps/`.

3. You are not receiving the HH reports at the collector, `h3`? Double check if you ran the script `./mirror_cmd_cfg.sh` to setup the mirroring session on the switch after starting the switch through `make run`.

4. You can use the script `./reset_registers_cmd.sh` to clear all the registers (i.e., the sketch) on the switch before replaying another trace for testing. In case you have other data structures that are using registers that you would like to clear, you should add them to the `reset_register_cmd` file.

5. Testing with other traces? Or want to use a different threshold? Modify the file at `pod-topo/s1-runtime.json`.

#### Cleaning up Mininet

In cases where `make run` may leave a Mininet instance running in the background,  use the following command to clean up
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

The documentation for P4_16 and P4Runtime is available [here](https://p4.org/specs/)

All excercises in this repository use the `v1model` architecture, the documentation for which is available at:
1. The BMv2 Simple Switch target document accessible [here](https://github.com/p4lang/behavioral-model/blob/master/docs/simple_switch.md) talks mainly about the `v1model` architecture.
2. The include file `v1model.p4` has extensive comments and can be accessed [here](https://github.com/p4lang/p4c/blob/master/p4include/v1model.p4).