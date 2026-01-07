## NOTE

It's highly discouraged to use raw **Packet** class provided by the G2O API.  
That's because it's easy to make some common mistakes like:

- Using improper type for saving packet id
- Reading the packet data in incorrect order (data was written in different order)

Not only that, but the default **Packet** class is a bit less flexible when it comes to transmitting the data.  
We recommend using [BPackets](https://gitlab.com/bcore1/bpackets) wrapper, that simplifies the management of networking code.