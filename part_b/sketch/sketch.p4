/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;

#define SKETCH_ROW_LENGTH 65536
#define SKETCH_CELL_BIT_WIDTH 32

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header icmp_t {
    /* TODO: your code here */
}

header tcp_t {
    /* TODO: your code here */
}

header udp_t {
    /* TODO: your code here */
}

struct metadata {
    /* TODO: your code here */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    icmp_t       icmp;
    tcp_t        tcp;
    udp_t        udp;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        /* TODO: your code here */
        /* Hint: implement your parser */
        transition accept;
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    bit<32> hh_threshold = 0;
    bit<32> drop_threshold = 0;
    
    /* sketch data structure */
    /* Note: you may modify this structure as you wish */
    register<bit<SKETCH_CELL_BIT_WIDTH>> (SKETCH_ROW_LENGTH)  sketch_row0;
    register<bit<SKETCH_CELL_BIT_WIDTH>> (SKETCH_ROW_LENGTH)  sketch_row1;
    register<bit<SKETCH_CELL_BIT_WIDTH>> (SKETCH_ROW_LENGTH)  sketch_row2;
    register<bit<SKETCH_CELL_BIT_WIDTH>> (SKETCH_ROW_LENGTH)  sketch_row3;  

    /* TODO: your code here, if needed ;) */
    // ...

    action mirror_heavy_flow() {
        clone(CloneType.I2E, 0);    // mirror detected heavy flows to ports under session 0.
    }
    
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action get_thresholds_action(bit<32> hh_threshold_param, bit<32> drop_threshold_param) {
        hh_threshold = hh_threshold_param;
        drop_threshold = drop_threshold_param;
    }

    table get_thresholds {
        key = {}
        actions = {
            NoAction;
            get_thresholds_action;
        }
        default_action = NoAction();
    }

    action ipv4_forward_action(egressSpec_t port) {
        standard_metadata.egress_spec = port;
    }

    table ipv4_forward {
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        actions = {
            ipv4_forward_action;
            drop;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        if (hdr.ipv4.isValid()) {
            /* TODO: your code here */
            get_thresholds.apply();
            /* Hint 1: update the sketch and get the latest estimation */
            /* Hint 2: compare the estimation with the hh_threshold */
            /* Hint 3: to report HH flow, call mirror_heavy_flow() */
            /* Hint 4: how to ensure no duplicate HH reports to collector? */
            /* Hint 5: check drop_threshold, and drop if it is a potential DNS amplification attack */
            ipv4_forward.apply();
        } 
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        /* TODO: your code here */
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
