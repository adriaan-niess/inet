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

#include "inet/linklayer/ethernet/EtherPhyFrame_m.h"
#include "inet/protocol/transceiver/StreamingTransmitter.h"

namespace inet {

Define_Module(StreamingTransmitter);

void StreamingTransmitter::initialize(int stage)
{
    PacketTransmitterBase::initialize(stage);
    if (stage == INITSTAGE_LOCAL) {
        datarate = bps(par("datarate"));
        txEndTimer = new cMessage("endTimer");
    }
}

void StreamingTransmitter::handleMessage(cMessage *message)
{
    if (message == txEndTimer) {
        sendPacketEnd(signal, outputGate, signal->getDuration());
        signal = nullptr;
        producer->handlePushPacketProcessed(txPacket, inputGate->getPathStartGate(), true);
        producer->handleCanPushPacket(inputGate->getPathStartGate());
    }
    else
        PacketTransmitterBase::handleMessage(message);
}

void StreamingTransmitter::pushPacket(Packet *packet, cGate *gate)
{
    Enter_Method("pushPacket");
    ASSERT(signal == nullptr);
    txPacket = packet;
    take(txPacket);
//    // TODO: new Signal
//    auto s = new EthernetSignal(packet->getName());
//    s->setBitrate(datarate.get());
    signal = createSignal(txPacket);
    sendPacketStart(signal->dup(), outputGate, signal->getDuration());
    scheduleTxEndTimer(signal);
}

simtime_t StreamingTransmitter::calculateDuration(const Packet *packet) const
{
    return packet->getDataLength().get() / datarate.get();
}

void StreamingTransmitter::scheduleTxEndTimer(Signal *signal)
{
    if (txEndTimer->isScheduled())
        cancelEvent(txEndTimer);
    scheduleAt(simTime() + signal->getDuration(), txEndTimer);
}

void StreamingTransmitter::pushPacketProgress(Packet *packet, cGate *gate, b position, b extraProcessableLength)
{
}

b StreamingTransmitter::getPushPacketProcessedLength(Packet *packet, cGate *gate)
{
    return b(0);
}

} // namespace inet

