# Mikrotik / RouterOS Kid Control Script

## Description

These scripts build on top of the RouterOS kid control feature to get a grip on the kids' internet usage, especially the time spent on YouTube.

Since it is virtually impossible to block YouTube completely, the script attempts to monitor the bandwidth used by the kids' devices to detect streaming.
When the data consumption has remained in the "streaming range" (~200 kbps - ~1.4 Mbps) for a while, the bandwidth limit for the kid is reduced to a point where streaming is no longer viable (choked).
The limit is removed again after a while.
If streaming is no longer possible, the kids will hopefully find something else to do.

## Details

`checkConfig.rsc` parses the RouterOS configuration and updates an address list, ip firewall and queue for each kid.

The address list contains the IP addresses of the kid's devices (updated when the ARP table changes).

The script also creates a firewall filter rule to mark all traffic for each kid with the kid's name, and a queue for each kid.
The queue configuration will be updated by the `limitStreaming.rsc` script.
Note that due to the way RouterOS works, this means that the queue cannot be used for graphing - the graph will be reset every time the queue is updated.

`limitStreaming.rsc` is a scheduler job that checks the amount of data transferred by the kid's devices during the last 30 minutes. If the amount of data transferred exceeds the limit, the job chokes the bandwidth limit for the kid's devices to a point where streaming is no longer viable. The choke is removed after 3 hours.

## Usage

1. Disable the fasttrack forwarding rule.

2. Set up the kid control feature on your router to limit the times when the kids can use the internet. **Do not** set up any bandwidth limits. Assign the kids' devices to the kid control profile, and you're done.

It is not necessary to use static IP addresses for the kids' devices (but it is recommended for other reasons).

Upload all `*.rsc` files to your router and then run the `setup-kid-control.rsc` script once.

## Data rates for streaming

Depending on the video quality, video streaming consumes the following amount of data:

| Resolution              | per Minute    | bps          |
| ----------------------- | ------------- | ------------ |
| 144p                    | 2.5 MB        | 34.1 kbps    |
| 240p                    | 4.3 MB        | 58.9 kbps    |
| 360p                    | 7.4 MB        | 101.3 kbps   |
| 480p                    | 12.4 MB       | 169.7 kbps   |
| 720p (HD)               | 22.4 MB       | 306.7 kbps   |
| 1080p (Full HD)         | 37.5 MB       | 512.5 kbps   |
| 1440p (2K)              | 56.2 MB       | 768.8 kbps   |
| 2160p (4K)              | 84.4 MB       | 1.2 Mbps     |

