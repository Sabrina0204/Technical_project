
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.node import Host
from mininet.node import OVSKernelSwitch
from mininet.log import setLogLevel, info
from mininet.node import RemoteController
from mininet.term import makeTerm


def myTopo():
    net = Mininet(topo=None, autoSetMacs=True, build=False, ipBase='10.0.1.0/24')

    c1 = net.addController('c1', RemoteController)
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch, failMode='secure')

    server1 = net.addHost('server1', cls=Host, defaultRoute=None)
    server2 = net.addHost('server2', cls=Host, defaultRoute=None)
    client = net.addHost('client', cls=Host, defaultRoute=None)

    net.addLink(server1, s1)
    net.addLink(server2, s1)
    net.addLink(client, s1)

    net.build()

    server1.setMAC(intf="server1-eth0", mac='00:00:00:00:00:01')
    server2.setMAC(intf="server2-eth0", mac='00:00:00:00:00:02')
    client.setMAC(intf="client-eth0", mac='00:00:00:00:00:03')

    server1.setIP(intf="server1-eth0", ip='10.0.1.2/24')
    server2.setIP(intf="server2-eth0", ip='10.0.1.3/24')
    client.setIP(intf="client-eth0", ip='10.0.1.5/24')

    net.start()

    net.terms += makeTerm(c1)
    net.terms += makeTerm(s1)
    net.terms += makeTerm(server1)
    net.terms += makeTerm(server2)
    net.terms += makeTerm(client)

    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    myTopo()
