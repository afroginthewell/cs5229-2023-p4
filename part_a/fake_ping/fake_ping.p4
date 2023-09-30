/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;

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
    /* Hint: define ICMP header */
}

struct metadata {
    /* TODO: your code here */
    /* Hint: any metadata needed? */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    icmp_t       icmp;
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
    
    action drop() {
        /* TODO: your code here */
        /* Hint: do you need any metadata? */
        mark_to_drop(standard_metadata);
    }

    table icmp_filter_table {
        key = {
            hdr.ipv4.dstAddr : exact;
        }
        actions = {
            NoAction;
            drop;
        }
        default_action = NoAction();
    }

    apply {
        if (hdr.icmp.isValid()) {
            /*  TODO: your code here */
            icmp_filter_table.apply();
            /*  Hint 1: check if it needs to be dropped */
            /*  Hint 2: otherwise, convert the ICMP echo request to an echo response */
            /*  Hint 3: swap the source/ destionation addresses and set output port */
        } else {
            drop();
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
    apply {
        /*  TODO: uncomment the following */
        // update_checksum(
        //     hdr.ipv4.isValid(),
        //     { 
        //         hdr.ipv4.version,
        //         hdr.ipv4.ihl,
        //         hdr.ipv4.diffserv,
        //         hdr.ipv4.totalLen,
        //         hdr.ipv4.identification,
        //         hdr.ipv4.flags,
        //         hdr.ipv4.fragOffset,
        //         hdr.ipv4.ttl,
        //         hdr.ipv4.protocol,
        //         hdr.ipv4.srcAddr,
        //         hdr.ipv4.dstAddr 
        //     },
        //     hdr.ipv4.hdrChecksum,
        //     HashAlgorithm.csum16
        // );

        // update_checksum_with_payload(
        //     hdr.icmp.isValid(),
        //     {
        //         hdr.icmp.type,
        //         hdr.icmp.code
        //     },
        //     hdr.icmp.hdrChecksum,
        //     HashAlgorithm.csum16
        // );
    }
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
