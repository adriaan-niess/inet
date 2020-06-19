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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see http://www.gnu.org/licenses/.
//

package inet.protocol.ethernet;

import inet.common.MessageDispatcher;
import inet.linklayer.contract.IEthernetInterface;
import inet.networklayer.common.InterfaceEntry;
import inet.protocol.common.InterPacketGap;
import inet.protocol.common.ProtocolChecker;
import inet.protocol.fragmentation.FragmentTagBasedDefragmenter;
import inet.protocol.ieee8022.IIeee8022LlcChecker;
import inet.protocol.ieee8022.IIeee8022LlcInserter;
import inet.protocol.ieee8022.IIeee8022SnapChecker;
import inet.protocol.ieee8022.IIeee8022SnapInserter;
import inet.protocol.server.PreemptingServer;
import inet.protocol.transceiver.contract.IPacketReceiver;
import inet.protocol.transceiver.contract.IPacketTransmitter;
import inet.queueing.classifier.PacketClassifier;
import inet.queueing.common.PacketMultiplexer;
import inet.queueing.contract.IPacketClassifier;
import inet.queueing.contract.IPacketFilter;
import inet.queueing.contract.IPacketFlow;
import inet.queueing.contract.IPacketQueue;
import inet.queueing.contract.IPacketServer;
import inet.queueing.contract.ITrafficConditioner;
import inet.queueing.scheduler.PriorityScheduler;

moduleinterface ISocketLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module OmittedSocketLayer like ISocketLayer
{
    parameters:
        @class(OmittedModule);
        @display("i=block/layer,black,50");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    connections:
        upperLayerIn --> lowerLayerOut;
        lowerLayerIn --> upperLayerOut;
}

moduleinterface IMeasurementLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module OmittedMeasurementLayer like IMeasurementLayer
{
    parameters:
        @class(OmittedModule);
        @display("i=block/layer,black,50");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    connections:
        upperLayerIn --> lowerLayerOut;
        lowerLayerIn --> upperLayerOut;
}

module MeasurementLayer like IMeasurementLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        measurementStarter: <default("TimingMeasurementStarter")> like IPacketFlow {
            parameters:
                @display("p=150,100");
        }
        measurementMaker: <default("TimingMeasurementMaker")> like IPacketFlow {
            parameters:
                @display("p=350,100");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> measurementStarter.in;
        measurementStarter.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> measurementMaker.in;
        measurementMaker.out --> { @display("m=n"); } --> upperLayerOut;
}

moduleinterface ITrafficConditionerLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module OmittedTrafficConditionerLayer like ITrafficConditionerLayer
{
    parameters:
        @class(OmittedModule);
        @display("i=block/layer,black,50");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    connections:
        upperLayerIn --> lowerLayerOut;
        lowerLayerIn --> upperLayerOut;
}

module TrafficConditionerLayer like ITrafficConditionerLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        ingressConditioner: <default("OmittedTrafficConditioner")> like ITrafficConditioner {
            @display("p=100,100");
        }
        egressConditioner: <default("OmittedTrafficConditioner")> like ITrafficConditioner {
            @display("p=300,100");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> ingressConditioner.in;
        ingressConditioner.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> egressConditioner.in;
        egressConditioner.out --> { @display("m=n"); } --> upperLayerOut;
}

moduleinterface IIeee8022LlcLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module OmittedIeee8022LlcLayer like IIeee8022LlcLayer
{
    parameters:
        @class(OmittedModule);
        @display("i=block/layer,black,50");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    connections:
        upperLayerIn --> lowerLayerOut;
        lowerLayerIn --> upperLayerOut;
}


module Ieee8022LlcLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        classifier: <default("PacketClassifier")> like IPacketClassifier {
            @display("p=200,100");
        }
        snapInserter: <default("Ieee8022SnapInserter")> like IIeee8022SnapInserter if typename != "" {
            @display("p=100,200");
        }
        m1: PacketMultiplexer {
            @display("p=100,300");
        }
        llcInserter: <default("Ieee8022LlcInserter")> like IIeee8022LlcInserter if typename != "" {
            @display("p=100,400");
        }
        m2: PacketMultiplexer {
            @display("p=200,500");
        }
        protocolChecker: ProtocolChecker {
            @display("p=500,100");
        }
        llcChecker: <default("Ieee8022LlcChecker")> like IIeee8022LlcChecker {
            @display("p=400,400");
        }
        snapChecker: <default("Ieee8022SnapChecker")> like IIeee8022SnapChecker {
            @display("p=600,400");
        }
        dp: MessageDispatcher {
            @display("p=500,300;b=100,5,,,,1");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> classifier.in;
        classifier.out++ --> snapInserter.in if exists(snapInserter);
        classifier.out++ --> m2.in++ if exists(llcInserter);
        classifier.out++ --> m1.in++;
        llcInserter.out --> m2.in++ if exists(llcInserter);
        snapInserter.out --> m1.in++ if exists(snapInserter);
        m2.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> dp.in++;
        dp.out++ --> llcChecker.in;
        protocolChecker.out --> { @display("m=n"); } --> upperLayerOut;
        m1.out --> llcInserter.in;
        llcChecker.out --> dp.in++;
        dp.out++ --> snapChecker.in;
        snapChecker.out --> dp.in++;
        dp.out++ --> protocolChecker.in;
}

moduleinterface IEthernetMacLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module EthernetMacLayer like IEthernetMacLayer
{
    parameters:
        outboundEmitter.signalName = "packetSentToLower";
        outboundEmitter.direction = "outbound";
        outboundEmitter.protocolName = "ethernetmac";
        inboundEmitter.signalName = "packetReceivedFromLower";
        inboundEmitter.direction = "inbound";
        inboundEmitter.protocolName = "ethernetmac";
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        queue: <default("PacketQueue")> like IPacketQueue {
            @display("p=200,100");
        }
        server: <default("InstantServer")> like IPacketServer {
            @display("p=200,200");
        }
        streamer: <default("OmittedPacketFlow")> like IPacketFlow {
            @display("p=200,300");
        }
        fcsInserter: <default("EthernetFcsInserter")> like IPacketFlow {
            @display("p=200,400");
        }
        outboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=200,500");
        }
        fcsChecker: <default("EthernetFcsChecker")> like IPacketFilter {
            @display("p=500,400");
        }
        inboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=500,500");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> queue.in;
        queue.out --> server.in;
        server.out --> streamer.in;
        streamer.out --> fcsInserter.in;
        fcsInserter.out --> outboundEmitter.in;
        outboundEmitter.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> inboundEmitter.in;
        inboundEmitter.out --> fcsChecker.in;
        fcsChecker.out --> { @display("m=n"); } --> upperLayerOut;
}

module EthernetRawMacLayer extends EthernetMacLayer
{
    parameters:
        typeOrLengthInserter.typename = default("OmittedPacketFlow");
        addressInserter.typename = default("OmittedPacketFlow");
        paddingInserter.typename = default("OmittedPacketFlow");
        fcsInserter.typename = default("OmittedPacketFlow");
        addressChecker.typename = default("OmittedPacketFilter");
        typeOrLengthChecker.typename = default("OmittedPacketFilter");
}

module EthernetStreamingMacLayer extends EthernetMacLayer
{
    parameters:
        server.typename = default("OmittedPacketServer");
        streamer.typename = default("PacketStreamer");
        transmitter.typename = default("StreamingTransmitter");
        receiver.typename = default("StreamingReceiver");
}

module EthernetFragmentingMacLayer extends EthernetMacLayer
{
    parameters:
        server.typename = default("OmittedPacketServer");
        streamer.typename = default("PreemptibleStreamer");
        streamer.minPacketLength = 60B;
        fcsInserter.typename = default("EthernetFragmentFcsInserter");
        preambleInserter.typename = default("EthernetFragmentPreambleInserter");
        transmitter.typename = default("PreemptibleTransmitter");
        fcsChecker.typename = default("EthernetFragmentFcsChecker");
        preambleChecker.typename = default("EthernetFragmentPreambleChecker");
    submodules:
        defragmenter: FragmentTagBasedDefragmenter {
            @display("p=500,300");
        }
    connections:
        fcsChecker.out --> { @reconnect; } --> defragmenter.in;
        defragmenter.out --> { @reconnect;@display("m=n"); } --> upperLayerOut;
}

module EthernetPreemptingMacLayer like IEthernetMacLayer
{
    parameters:
        volatile double bitrate @unit(bps);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        outboundClassifier: PacketClassifier {
            classifierClass = default("inet::PacketVlanReqClassifier");
            @display("p=200,100");
        }
        expressMacLayer: <default("EthernetStreamingMacLayer")> like IEthernetMacLayer {
            @display("p=300,200");
        }
        normalMacLayer: <default("EthernetFragmentingMacLayer")> like IEthernetMacLayer {
            @display("p=500,200");
        }
        scheduler: PriorityScheduler {
            @display("p=200,300");
        }
        preemptingServer: PreemptingServer {
            datarate = default(bitrate);
            @display("p=200,400");
        }
        inboundClassifier: PacketClassifier {
            classifierClass = default("inet::PacketFragmentTagClassifier");
            @display("p=600,300");
        }
        multiplexer: PacketMultiplexer {
            @display("p=600,100");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> outboundClassifier.in;
        outboundClassifier.out++ --> expressMacLayer.upperLayerIn;
        outboundClassifier.out++ --> normalMacLayer.upperLayerIn;
        expressMacLayer.lowerLayerOut --> scheduler.in++;
        normalMacLayer.lowerLayerOut --> scheduler.in++;
        scheduler.out --> preemptingServer.in;
        preemptingServer.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> inboundClassifier.in;
        inboundClassifier.out++ --> expressMacLayer.lowerLayerIn;
        inboundClassifier.out++ --> normalMacLayer.lowerLayerIn;
        expressMacLayer.upperLayerOut --> multiplexer.in++;
        normalMacLayer.upperLayerOut --> multiplexer.in++;
        multiplexer.out --> { @display("m=n"); } --> upperLayerOut;
}

moduleinterface IEthernetPhyLayer
{
    parameters:
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
}

module EthernetPhyLayer like IEthernetPhyLayer
{
    parameters:
        volatile double bitrate @unit(bps);
        outboundEmitter.signalName = "packetSentToLower";
        outboundEmitter.direction = "outbound";
        outboundEmitter.protocolName = "ethernetphy";
        inboundEmitter.signalName = "packetReceivedFromLower";
        inboundEmitter.direction = "inbound";
        inboundEmitter.protocolName = "ethernetphy";
        *.bitrate = default(bitrate);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        preambleInserter: <default("EthernetPreambleInserter")> like IPacketFlow {
            @display("p=200,100");
        }
        interFrameGapInserter: InterPacketGap {
            duration = default(96s / dropUnit(bitrate));
            @display("p=200,200");
        }
        outboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=200,300");
        }
        transmitter: <default("PreemptibleTransmitter")> like IPacketTransmitter {
            datarate = default(bitrate);
            @display("p=200,400");
        }
        preambleChecker: <default("EthernetPreambleChecker")> like IPacketFilter {
            @display("p=500,100");
        }
        inboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=500,300");
        }
        receiver: <default("StreamingReceiver")> like IPacketReceiver {
            datarate = default(bitrate);
            @display("p=500,400");
        }
    connections:
        upperLayerIn --> { @display("m=n"); } --> preambleInserter.in;
        preambleInserter.out --> interFrameGapInserter.in;
        interFrameGapInserter.out --> outboundEmitter.in;
        outboundEmitter.out --> transmitter.in;
        transmitter.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> receiver.in;
        receiver.out --> inboundEmitter.in;
        inboundEmitter.out --> preambleChecker.in;
        preambleChecker.out --> { @display("m=n"); } --> upperLayerOut;
}

module EthernetPreemptingPhyLayer like IEthernetPhyLayer
{
    parameters:
        volatile double bitrate @unit(bps);
        outboundEmitter.signalName = "packetSentToLower";
        outboundEmitter.direction = "outbound";
        outboundEmitter.protocolName = "ethernetphy";
        inboundEmitter.signalName = "packetReceivedFromLower";
        inboundEmitter.direction = "inbound";
        inboundEmitter.protocolName = "ethernetphy";
        *.bitrate = default(bitrate);
        @display("i=block/layer");
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input lowerLayerIn;
        output lowerLayerOut;
    submodules:
        preambleInserter: <default("EthernetPreambleInserter")> like IPacketFlow {
            @display("p=91,115");
        }
        interFrameGapInserter: InterPacketGap {
            duration = default(96s / dropUnit(bitrate));
            @display("p=200,200");
        }
        outboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=200,300");
        }
        transmitter: <default("PreemptibleTransmitter")> like IPacketTransmitter {
            datarate = default(bitrate);
            @display("p=200,400");
        }
        preambleChecker: <default("EthernetPreambleChecker")> like IPacketFilter {
            @display("p=418,161");
        }
        inboundEmitter: <default("PacketEmitter")> like IPacketFlow {
            @display("p=500,300");
        }
        receiver: <default("StreamingReceiver")> like IPacketReceiver {
            datarate = default(bitrate);
            @display("p=500,400");
        }
        packetClassifier: PacketClassifier {
            classifierClass = default("inet::PacketEthernetPreambleTypeClassifier");
            @display("p=500,200");
        }
        packetMultiplexer: PacketMultiplexer {
            @display("p=500,100");
        }
        preambleInserter1: <default("EthernetFragmentPreambleInserter")> like IPacketFlow {
            @display("p=304,106");
        }
        preambleChecker1: <default("EthernetFragmentPreambleChecker")> like IPacketFilter {
            @display("p=606,161");
        }
        packetClassifier1: PacketClassifier {
            classifierClass = default("inet::PacketFragmentTagClassifier");
            @display("p=200,42");
        }
        packetMultiplexer1: PacketMultiplexer {
            @display("p=200,161");
        }
    connections:
        interFrameGapInserter.out --> outboundEmitter.in;
        outboundEmitter.out --> transmitter.in;
        transmitter.out --> { @display("m=s"); } --> lowerLayerOut;

        lowerLayerIn --> { @display("m=s"); } --> receiver.in;
        receiver.out --> inboundEmitter.in;
        upperLayerIn --> packetClassifier1.in;
        packetClassifier1.out++ --> preambleInserter.in;
        packetClassifier1.out++ --> preambleInserter1.in;
        preambleInserter.out --> packetMultiplexer1.in++;
        preambleInserter1.out --> packetMultiplexer1.in++;
        packetMultiplexer1.out --> interFrameGapInserter.in;
        inboundEmitter.out --> packetClassifier.in;
        packetClassifier.out++ --> preambleChecker.in;
        packetClassifier.out++ --> preambleChecker1.in;
        preambleChecker.out --> packetMultiplexer.in++;
        preambleChecker1.out --> packetMultiplexer.in++;
        packetMultiplexer.out --> upperLayerOut;
}
