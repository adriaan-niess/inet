//
// Copyright (C) OpenSim Ltd.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.
//

package inet.node.base;

import inet.common.MessageDispatcher;
import inet.common.packet.recorder.PcapRecorder;
import inet.linklayer.contract.IEthernetInterface;
import inet.linklayer.contract.ILoopbackInterface;
import inet.linklayer.contract.IPppInterface;
import inet.linklayer.contract.ITunnelInterface;
import inet.linklayer.contract.IVlanInterface;
import inet.linklayer.contract.IWirelessInterface;
import inet.linklayer.ethernet.switch.MacRelayUnit;
import inet.networklayer.common.InterfaceTable;
import inet.protocol.ethernet.SimpleEthernetLayer;
import inet.protocol.ieee8021q.IIeee8021qChecker;
import inet.protocol.ieee8021q.IIeee8021qInserter;
import inet.queueing.common.PacketMultiplexer;
import inet.queueing.contract.IPacketClassifier;
import inet.queueing.contract.IPacketFilter;
import inet.queueing.contract.IPacketFlow;


module EthernetLayerSplitted
{
    parameters:
        string interfaceTableModule;
        *.interfaceTableModule = default(interfaceTableModule);
        paddingInserter.minLength = default(60B);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        typeOrLengthInserter: <default("EthernetTypeOrLengthInserter")> like IPacketFlow {
            @display("p=200,199");
        }
        ctagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "c";
            @display("p=50,199");
        }
        stagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "s";
            @display("p=350,199");
        }
        addressInserter: <default("EthernetAddressInserter")> like IPacketFlow {
            @display("p=200,400");
        }
        paddingInserter: <default("PaddingInserter")> like IPacketFlow {
            @display("p=200,500");
        }
        typeOrLengthChecker: <default("EthernetTypeOrLengthChecker")> like IPacketFilter {
            @display("p=500,300");
        }
        ctagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "c";
            @display("p=650,300");
        }
        stagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "s";
            @display("p=350,300");
        }
        addressChecker: <default("EthernetAddressChecker")> like IPacketFilter {
            @display("p=500,500");
        }
        messageDispatcher: MessageDispatcher {
            @display("p=500,199;b=10,10");
        }
        packetMultiplexer: PacketMultiplexer {
            @display("p=500,400");
        }
        classifier: <default("PacketClassifier")> like IPacketClassifier {
            @display("p=200,298");
        }
        packetMultiplexer1: PacketMultiplexer {
            @display("p=200,90");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> packetMultiplexer1.in++;
        addressInserter.out --> paddingInserter.in;
        paddingInserter.out --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> addressChecker.in;
        typeOrLengthChecker.out --> messageDispatcher.in++;
        messageDispatcher.out++ --> stagChecker.in;
        messageDispatcher.out++ --> ctagChecker.in;
        messageDispatcher.out++ --> upperLayerOut;
        ctagChecker.out --> packetMultiplexer.in++;
        stagChecker.out --> packetMultiplexer.in++;
        addressChecker.out --> packetMultiplexer.in++;
        packetMultiplexer.out --> typeOrLengthChecker.in;
        typeOrLengthInserter.out --> classifier.in;
        classifier.out++ --> addressInserter.in;
        classifier.out++ --> ctagInserter.in;
        classifier.out++ --> stagInserter.in;
        packetMultiplexer1.out --> typeOrLengthInserter.in;
        ctagInserter.out --> packetMultiplexer1.in++;
        stagInserter.out --> packetMultiplexer1.in++;
}

module EthernetLayerCurrent
{
    parameters:
        string interfaceTableModule;
        *.interfaceTableModule = default(interfaceTableModule);
        paddingInserter.minLength = default(60B);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        typeOrLengthInserter: <default("EthernetTypeOrLengthInserter")> like IPacketFlow {
            @display("p=200,76");
        }
        ctagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "c";
            @display("p=61,253");
        }
        stagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "s";
            @display("p=329,253");
        }
        addressInserter: <default("EthernetAddressInserter")> like IPacketFlow {
            @display("p=200,400");
        }
        paddingInserter: <default("PaddingInserter")> like IPacketFlow {
            @display("p=200,500");
        }
        typeOrLengthChecker: <default("EthernetTypeOrLengthChecker")> like IPacketFilter {
            @display("p=500,82");
        }
        ctagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "c";
            @display("p=649,347");
        }
        stagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "s";
            @display("p=360,347");
        }
        addressChecker: <default("EthernetAddressChecker")> like IPacketFilter {
            @display("p=500,500");
        }
        classifier: <default("PacketClassifier")> like IPacketClassifier {
            @display("p=200,298");
        }
        packetMultiplexer1: PacketMultiplexer {
            @display("p=200,199");
        }
        classifier1: <default("PacketClassifier")> like IPacketClassifier {
            @display("p=500,300");
        }
        packetMultiplexer: PacketMultiplexer {
            @display("p=500,400");
        }
        macRelayUnit: MacRelayUnit {
            @display("p=344,153");
        }
    connections:
        addressInserter.out --> paddingInserter.in;
        paddingInserter.out --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> addressChecker.in;
        classifier.out++ --> addressInserter.in;
        classifier.out++ --> ctagInserter.in;
        classifier.out++ --> stagInserter.in;
        ctagInserter.out --> packetMultiplexer1.in++;
        stagInserter.out --> packetMultiplexer1.in++;
        upperLayerIn --> typeOrLengthInserter.in;
        typeOrLengthInserter.out --> packetMultiplexer1.in++;
        packetMultiplexer1.out --> classifier.in;
        typeOrLengthChecker.out --> upperLayerOut;
        classifier1.out++ --> stagChecker.in;
        classifier1.out++ --> ctagChecker.in;
        addressChecker.out --> packetMultiplexer.in++;
        packetMultiplexer.out --> classifier1.in;
        stagChecker.out --> packetMultiplexer.in++;
        ctagChecker.out --> packetMultiplexer.in++;
        classifier1.out++ --> typeOrLengthChecker.in;
}

module EthernetLayerShifted
{
    parameters:
        string interfaceTableModule;
        *.interfaceTableModule = default(interfaceTableModule);
        paddingInserter.minLength = default(60B);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        typeOrLengthInserter: <default("EthernetTypeOrLengthInserter")> like IPacketFlow {
            @display("p=200,300");
        }
        ctagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "c";
            @display("p=61,134");
        }
        stagInserter: <default("OmittedIeee8021qInserter")> like IIeee8021qInserter {
            vlanTagType = "s";
            @display("p=335,134");
        }
        addressInserter: <default("EthernetAddressInserter")> like IPacketFlow {
            @display("p=200,400");
        }
        paddingInserter: <default("PaddingInserter")> like IPacketFlow {
            @display("p=200,500");
        }
        typeOrLengthChecker: <default("EthernetTypeOrLengthChecker")> like IPacketFilter {
            @display("p=500,400");
        }
        ctagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "c";
            @display("p=622,300");
        }
        stagChecker: <default("OmittedIeee8021qChecker")> like IIeee8021qChecker {
            vlanTagType = "s";
            @display("p=394,300");
        }
        addressChecker: <default("EthernetAddressChecker")> like IPacketFilter {
            @display("p=500,500");
        }
        classifier: <default("PacketClassifier")> like IPacketClassifier {
            @display("p=200,188");
        }
        packetMultiplexer1: PacketMultiplexer {
            @display("p=200,82");
        }
        messageDispatcher: MessageDispatcher {
            @display("p=500,134;b=10,10");
        }
    connections:
        addressInserter.out --> paddingInserter.in;
        paddingInserter.out --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> addressChecker.in;
        ctagInserter.out --> packetMultiplexer1.in++;
        stagInserter.out --> packetMultiplexer1.in++;
        classifier.out++ --> typeOrLengthInserter.in;
        classifier.out++ --> ctagInserter.in;
        classifier.out++ --> stagInserter.in;
        upperLayerIn --> packetMultiplexer1.in++;
        packetMultiplexer1.out --> classifier.in;
        typeOrLengthInserter.out --> addressInserter.in;
        addressChecker.out --> typeOrLengthChecker.in;
        typeOrLengthChecker.out --> messageDispatcher.in++;
        messageDispatcher.out++ --> stagChecker.in;
        messageDispatcher.out++ --> ctagChecker.in;
        messageDispatcher.out++ --> upperLayerOut;
        ctagChecker.out --> messageDispatcher.in++;
        stagChecker.out --> messageDispatcher.in++;
}

module LinkLayerNodeBase extends NodeBase
{
    parameters:
        bool recordPcap = default(false);
        int numPcapRecorders = default(recordPcap ? 1 : 0);
        int numLoInterfaces = default(1);
        int numWlanInterfaces = default(0);
        int numEthInterfaces = default(0);  // minimum number of ethernet interfaces
        int numPppInterfaces = default(0);  // minimum number of PPP interfaces
        int numTunInterfaces = default(0);
        int numVlanInterfaces = default(0);
        pcapRecorder[*].pcapFile = default("results/" + fullPath() + ".pcap");
        mobility.typename = default(numWlanInterfaces > 0 ? "StationaryMobility" : "");
        *.interfaceTableModule = default(absPath(".interfaceTable"));
        wlan[*].radio.antenna.mobilityModule = default("^.^.^.mobility");
        @figure[linkLayer](type=rectangle; pos=250,456; size=1000,130; fillColor=#0000ff; lineColor=#808080; cornerRadius=5; fillOpacity=0.1);
        @figure[linkLayer.title](type=text; pos=1245,461; anchor=ne; text="link layer");
        @figure[interfaceLayer](type=rectangle; pos=250,606; size=1000,210; fillColor=#00ffff; lineColor=#808080; cornerRadius=5; fillOpacity=0.1);
        @figure[interfaceLayer.title](type=text; pos=1245,611; anchor=ne; text="interface layer");

    gates:
        input radioIn[numWlanInterfaces] @directIn;
        inout pppg[numPppInterfaces] @labels(PppFrame-conn) @allowUnconnected;
        inout ethg[numEthInterfaces] @labels(EtherFrame-conn) @allowUnconnected;

    submodules:
        pcapRecorder[numPcapRecorders]: PcapRecorder {
            parameters:
                @display("p=125,560;is=s");
        }
        interfaceTable: InterfaceTable {
            parameters:
                @display("p=125,240;is=s");
        }
        li: MessageDispatcher {
            parameters:
                @display("p=750,596;b=1000,5,,,,1");
        }
        ethernet: SimpleEthernetLayer {
            parameters:
                @display("p=375,526");
        }
        lo[numLoInterfaces]: <default("LoopbackInterface")> like ILoopbackInterface {
            parameters:
                @display("p=750,676,row,150");
        }
        // TODO: move wlan interfaces after eth interfaces, but it changes IP address assignment and breaks examples/inet/configurator/complex.ini
        wlan[numWlanInterfaces]: <default("Ieee80211Interface")> like IWirelessInterface {
            parameters:
                @display("p=375,766,row,150;q=queue");
        }
        ppp[sizeof(pppg)]: <default("PppInterface")> like IPppInterface {
            parameters:
                @display("p=300,676,row,150;q=txQueue");
        }
        eth[sizeof(ethg)]: <default("LayeredEthernetInterface")> like IEthernetInterface {
            parameters:
                @display("p=900,676,row,150;q=txQueue");
        }
        tun[numTunInterfaces]: <default("TunInterface")> like ITunnelInterface {
            parameters:
                @display("p=975,766,row,150;q=txQueue");
        }
        vlan[numVlanInterfaces]: <default("VlanInterface")> like IVlanInterface {
            parameters:
                @display("p=975,766,row,150;q=txQueue");
        }

    connections allowunconnected:
        ethernet.lowerLayerOut --> li.in++;
        li.out++ --> ethernet.lowerLayerIn;

        for i=0..sizeof(radioIn)-1 {
            radioIn[i] --> { @display("m=s"); } --> wlan[i].radioIn;
        }

        for i=0..sizeof(ethg)-1 {
            ethg[i] <--> { @display("m=s"); } <--> eth[i].phys;
        }

        for i=0..sizeof(pppg)-1 {
            pppg[i] <--> { @display("m=s"); } <--> ppp[i].phys;
        }

        for i=0..numLoInterfaces-1 {
            li.out++ --> lo[i].upperLayerIn;
            lo[i].upperLayerOut --> li.in++;
        }

        for i=0..sizeof(radioIn)-1 {
            wlan[i].upperLayerOut --> li.in++;
            wlan[i].upperLayerIn <-- li.out++;
        }

        for i=0..sizeof(ethg)-1 {
            eth[i].upperLayerOut --> li.in++;
            eth[i].upperLayerIn <-- li.out++;
        }

        for i=0..sizeof(pppg)-1 {
            ppp[i].upperLayerOut --> li.in++;
            ppp[i].upperLayerIn <-- li.out++;
        }

        for i=0..numTunInterfaces-1 {
            tun[i].upperLayerOut --> li.in++;
            tun[i].upperLayerIn <-- li.out++;
        }

        for i=0..numVlanInterfaces-1 {
            vlan[i].upperLayerOut --> li.in++;
            vlan[i].upperLayerIn <-- li.out++;
        }
}

