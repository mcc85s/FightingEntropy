# **CPH Library – Managed Services Proposal**

### Introduction:

In this document, I intend to discuss the following:
1. Managed Services + Network Maintenance
2. Heavy-Handed Research
3. [FightingEntropy(π)]://Infrastructure Deployment System

#### 1) **Managed Services + Network Maintenance**
- Issues with the <current network infrastructure>
- Concerns with Meraki Cloud
- Regular maintenance (remote + on-site)
- Proposed Network Solution
- Proven Commitment
- Complaints + Maintenance
- Scope of duties
- Contractor
- Heavy-Handed Research

#### 2) **Heavy-Handed Research**
- What access point is this?
- Tell me more about Cisco Meraki MR12
- Incorrect Conclusion #1
- Incorrect Conclusion #2
- Providing Descriptors
- Making Visual Associations
- Incorrect Conclusion #3
- Incorrect Conclusion #4
- Correct Conclusion
- Legal Penetration Test
- Meraki Control Plane
- Wireless LAN Controller
- Meraki Cloud Cost Analysis
- Cost Effective Solution
- OPNsense Enterprise
- Draft Presentation
- Calculate Projected Savings
- OPNsense WLAN Design
- WPA3 Security Vulnerabilities
- Managed Service Provider

#### 3) [FightingEntropy(π)]://Infrastructure Deployment System
- Ambitious Automation
- Virtual Machines (1 + 2)
- Virtual Switches
- Roll Demonstration
- Review Scriptblock #1
- Multi-Tasking Installations
- OPNsense Installation
- Server Installation Complete
- Gateway Configuration (Phase 1)
- Server Configuration (Phase 1)
- Gateway Configuration (Phase 2)
- [FightingEntropy(π)][2021.10.0]
- Server Configuration (Phase 2)
- Get-FEDCPromo (Phase 1)
- Get-FEDCPromo (GUI)
- Get-FEDCPromo (Phase 2)
- Server Configuration (Phase 3)
- FEInfrastructure (Preview/Demo)
- Get-FEADLogin
- New-FEInfrastructure (GUI)
- Module Tab
- Config Tab
- Domain Tab
- Network Tab
- Sitemap Tab
- Adds Tab
- Virtual Tab
- Share Tab
- Imaging Tab
- Updates Tab

### 1) Managed Services + Network Maintenance
<div style="max-width:700px; font-size:13px; line-height:1.35; white-space:normal; word-wrap:break-word;">
  <p><b>[1A]: <u>Issues with the &lt;current network infrastructure&gt;</u></b></p>
  <table>
    <tr>
      <td>
        <font size="8">
        <p>
        I’d like to start out by making an indication that the current &lt;actual wireless access points&gt; managed by &lt;Cisco Meraki Cloud&gt; seem to be having connection issues on a &lt;regular basis&gt;. Sometimes, it is the &lt;internet service provider&gt; that is having issues, other times it is the &lt;Cisco Meraki MR52&gt; access points that are dropping connections, and failing to reestablish quality of service. For instance, you have a connection, but the throughput is 0 Kb/s.
        </p>
        <p>
        I always know when it is (1) or the (other), as I have been having a LOT of issues with the network, and I am not the only one. I have run ping tests numerous times to see whether it was ISP related, or the internal network.
        </p>
        <p>
        ISP related, ping jumps super high and fluctuates wildly, super erratic. That’s ISP/internet backbone junction.  
        Meraki cloud related, the ping will suddenly jump 33% higher, and start skipping. Pretty sure that’s Meraki, or maybe it’s someone out there using Cisco SD-WAN. I think Meraki and SD-WAN are used in conjunction in a lot of places, but I’m not positive of that.
        </p>
        <p>
        I’m not as concerned with the network skipping around dozens of times a day, I’m more concerned with how the network will occasionally drop my device(s) from the network when it is either uploading or downloading large files. These disruptions have wasted dozens of hours of my time.
        </p>
        <p>
          I’m not exaggerating that.
        </p>
        <p>
        Sometimes, I will upload a file that is 16GB (or larger) to the internet, and this network should be able to do that within an hour. If I had access to the Ethernet network, that would probably take several minutes.
        </p>
        <p>
        I am not the only one having issues with the network, as Keven Mathes from Grab-n-Go Vending has had his vending machine in the library for about (18) months or so? His case is a perfect example of it having a financial impact.
        </p>
        <p>
        During the course of that (18) months, he has told me about how he has an application on his phone that allows him to remote into the management console on the vending machine. However, in the periods of time where the device drops its’ connection, he cannot access it to determine its inventory, nor can it process credit card transactions.
        </p>
        <p>
        Therefore, the device will be out of order costing Mr. Mathes thousands of dollars in sales in some cases.
        </p>
        <p>
        Keven Mathes has complained about the network, and I told him that I KNOW it is because these access points are dropping clients. It does a configuration change or whatever…? Boom. You have a connection, but the rate is 0 Kb/s, which means the device thinks it has a connection but can’t send/receive data. So then it’s not going to try and reconnect to a network it’s already connected to.
        </p>
        <p>
        I’m not saying that these IT guys or Meraki gotta be perfect, but somethin’s gotta change.
        </p>
        <p>
        When this happens to the vending machine, it cannot process credit card transactions.  
        He will also have issues being able to remotely monitor the device, whereby disrupting his business.
        </p>
        <p>
        This in turn forces the vending machine to be &lt;INACCESSIBLE&gt; to anyone choosing to use the machine, and then Keven loses out on the income he is generating with that machine.
        </p>
        <p>
        The current IT director, Tom, his solution was to simply provide an Ethernet connection for the device.
        </p>
        </font>
      </td>
    </tr>
  </table>
</div>
