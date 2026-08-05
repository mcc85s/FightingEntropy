# **CPH Library – Managed Services Proposal**

# **Introduction:**

**In this document, I intend to discuss the following:**

1) **Managed Services + Network Maintenance**
2) **Heavy-Handed Research**
3) **[FightingEntropy(π)]://Infrastructure Deployment System**

## 1) Managed Services + Network Maintenance
-  **A**: <u>Issues with the &lt;current network infrastructure&gt;</u>
-  **B**: <u>Concerns with Meraki Cloud</u>
-  **C**: <u>Regular maintenance (remote + on-site)</u>
-  **D**: <u>Proposed Network Solution</u>
-  **E**: <u>Proven Commitment</u>
-  **F**: <u>Complaints + Maintenance</u>
-  **G**: <u>Scope of duties</u>
-  **H**: <u>Contractor</u>
-  **I**: <u>Heavy-Handed Research</u>

## 2) Heavy-Handed Research
-  **A**: <u>What access point is this?</u>
-  **B**: <u>Tell me more about Cisco Meraki MR12</u>
-  **C**: <u>Incorrect Conclusion #1</u>
-  **D**: <u>Incorrect Conclusion #2</u>
-  **E**: <u>Providing Descriptors</u>
-  **F**: <u>Making Visual Associations</u>
-  **G**: <u>Incorrect Conclusion #3</u>
-  **H**: <u>Incorrect Conclusion #4</u>
-  **I**: <u>Correct Conclusion</u>
-  **J**: <u>Legal Penetration Test</u>
-  **K**: <u>Meraki Control Plane</u>
-  **L**: <u>Wireless LAN Controller</u>
-  **M**: <u>Meraki Cloud Cost Analysis</u>
-  **N**: <u>Cost Effective Solution</u>
-  **O**: <u>OPNsense Enterprise</u>
-  **P**: <u>Draft Presentation</u>
-  **Q**: <u>Calculate Projected Savings</u>
-  **R**: <u>OPNsense WLAN Design</u>
-  **S**: <u>WPA3 Security Vulnerabilities</u>
-  **T**: <u>Managed Service Provider</u>

## 3) [FightingEntropy(π)]://Infrastructure Deployment System
-  **A**: <u>Ambitious Automation</u>
-  **B**: <u>Virtual Machines (1  +  2)</u>
-  **C**: <u>Virtual Switches</u>
-  **D**: <u>Roll Demonstration</u>
-  **E**: <u>Review Scriptblock #1</u>
-  **F**: <u>Multi-Tasking Installations</u>
-  **G**: <u>OPNsense Installation</u>
-  **H**: <u>Server Installation Complete</u>
-  **I**: <u>Gateway Configuration (Phase 1)</u>
-  **J**: <u>Server Configuration (Phase 1)</u>
-  **K**: <u>Gateway Configuration (Phase 2)</u>
-  **L**: <u>**[FightingEntropy(π)][2021.10.0]**</u>
-  **M**: <u>Server Configuration (Phase 2)</u>
-  **N**: <u>Get-FEDCPromo  (Phase 1)</u>
-  **O**: <u>Get-FEDCPromo  (GUI)</u>
-  **P**: <u>Get-FEDCPromo  (Phase 2)</u>
-  **Q**: <u>Server Configuration (Phase 3)</u>
-  **R**: <u>FEInfrastructure (Preview/Demo)</u>
-  **S**: <u>Get-FEADLogin</u>
-  **T**: <u>New-FEInfrastructure  (GUI)</u>
-  **U**: <u>Module Tab</u>
-  **V**: <u>Config Tab</u>
-  **W**: <u>Domain Tab</u>
-  **X**: <u>Network Tab</u>
-  **Y**: <u>Sitemap Tab</u>
-  **Z**: <u>Adds Tab</u>
-  **AA**: <u>Virtual Tab</u>
-  **AB**: <u>Share Tab</u>
-  **AC**: <u>Imaging Tab</u>
-  **AD**: <u>Updates Tab</u>
- 
## 1) Managed Services + Network Maintenance

### [A]: Issues with the &lt;current network infrastructure&gt;

I’d like to start out by making an indication that the current **&lt;actual wireless access points&gt;** managed by **&lt;Cisco Meraki Cloud&gt;** seem to be having connection issues on a **&lt;regular basis&gt;**. Sometimes, it is the **&lt;internet service provider&gt;** that is having issues, other times it is the **&lt;Cisco Meraki MR52&gt;** access points that are dropping connections, and failing to re-establish **quality of service**.

For instance, you may be in a condition where you have a connection... but the throughput is **0 Kb/s**.

I always know when it is **(1)** or the **(other)**, as I have been having a LOT of issues with the network, and I am not the only one. I have run ping tests **numerous times** to see whether it was **ISP related**, or the **internal network**.

ISP related, ping jumps super high and fluctuates wildly, super erratic.
That’s the **(ISP + internet backbone)** junction.

**Meraki-cloud related**, the ping will suddenly jump **33% higher**, and start **skipping**. Pretty sure that’s **Meraki**, or maybe it’s someone out there using **Cisco SD-WAN**. I think **Meraki** and **SD-WAN** are used in conjunction in a lot of places, but I’m not positive of that.

I’m not as concerned with the network skipping around dozens of times a day. I’m more concerned with how the network will **occasionally drop my device(s) from the network** when it is either **(uploading/downloading)** large files. These disruptions have wasted _dozens_ of hours of my time.

I’m not exaggerating that.

Sometimes, I will upload a file that is **16GB** (_or larger_) to the internet, and this network should be able to do that within an **hour**. If I had access to the **Ethernet network**, that would probably take _several minutes_.

I am not the only one having issues with the **network**, as **Keven Mathes** from **Grab-n-Go Vending** has had his **vending machine** in the library for about **(18)** months or so?

His case is a perfect example of it having a **financial impact**.

During the course of that (18) months, he has told me about how he has an application on his phone that allows him to remote into the management console on the vending machine. However,  in the periods of time where the device drops its’ connection, he cannot access it to determine its inventory, nor can it process credit card transactions.

Therefore, the device will be out of order costing **Mr. Mathes** _thousands of dollars_ in sales, in some cases.

**Keven Mathes** has complained about the **network**, and I told him that I **KNOW** it is because these **access points** are _dropping clients_. It does a **configuration change** or whatever…? Boom. You have a _connection_, but the rate is **0 Kb/s**, which means the device THINKS it has a "connection", but can’t (send/receive) data.

So, then it’s not going to try and **reconnect** to a network it’s **already connected to**.

I’m not saying that these **IT guys** or **Meraki** gotta be _perfect_, but **somethin’s gotta change**.

When this happens to the **vending machine**, it cannot process **credit card transactions**.
He will also have issues being able to **remotely monitor the device**, whereby _disrupting his business_.

This in turn forces the vending machine to be **&lt;INACCESSIBLE&gt;** to anyone choosing to use the machine, and then **Mr. Mathes** loses out on the _income_ he is generating with that machine.

The current IT director, Tom, his solution was to simply provide an **Ethernet connection** for the device.

Same guy had me kicked out of the library for **(6)** months for plugging my **Ethernet cable** into the wall.

He also took my idea to **install solid state hard drives** into ALL of the computers in the **computer lab** and the **normal computers** after I sent a document to **director Alexandra Gutelius** in **October 2022**, regarding how I wanted to provide _service_ for the library, and fix the issues that **DeepFreeze &lt;continues to have&gt;**.

Yeah, I wrote that original document on the basis of the **BSOD**’s the computers would have each morning when I came in. For like several days, I came into the **computer lab**, and the **same machine** that tried to install a **Windows Update** got stuck, and wouldn’t boot.

I had seen that **exact failure** _hundreds_ of times before, when managing **Computer Answers**. A recent **Windows Update** caused the hard drive to get _corrupted_, and it wouldn’t **boot into the operating system** anymore.

Solution → _new hard drive_.

What’d I say to the tech that was working there in **October 2022**…?
**Install an SSD**.

That’s what they did. But, they took the idea that I wrote in the **document**, and went around installing them in **ALL** of the machines. Then, when I recorded what they were doing in **video**, I **opened the chassis on each box to show that they took my idea**, and **Alexandra** kicked me out of the library for **(3)** months, and put _padlocks_ on the backs of the computers.

Definitely overkill, but here’s a _helpful suggestion_.

Every morning, I come in, and if I see a device that’s **crashed**, I know _they haven’t seen it yet_. I will sometimes take a **picture**, other times I'll write on a post-it note **"DeepFreeze caused BSOD, needs to be reimaged”**. Because, I know how the _image process_ works.

Sometimes the _applications_ will throw an error, and other patrons at the library will ask me for help.

It’s like taking a **snapshot** of the computer at **(1)** point in time, and then restoring that **snapshot** AFTER rebooting. So, it cannot reliably process updates **consistently**. It needs to be more _dynamic_ and _allow updates_ and not keep restoring a **backed-up VHD** or whatever.

At the time in **October 2022**, I was thinking about building something that works like **CASSIE** and thinking to myself how hard could that be? **CASSIE** is probably doing what **[FightingEntropy(π)]** does to some extent.

Regardless, to this day, the devices will still occasionally throw a **(BSOD/Blue Screen of Death)**, which is indicative of corruption 1) on the _hard drive_, 2) _configuration_, 3) or from a recent _Windows Update_.

_
<1-001.jpg>
_

The above image is from a video I recorded _AFTER_ a **BSOD**, the **(start menu + GUI)** wasn’t responding.

We can talk about **&lt;DeepFreeze&gt;**, and how it does effectively the same job as **Microsoft**’s FREE **&lt;Image and Configuration Designer&gt;** to put a machine into like a “_kiosk_” mode.

Kiosk mode just uses **&lt;group policy&gt;** to _disable access_ to various components on the **operating system**, you don’t need an application like **&lt;DeepFreeze&gt;**, to do this.

I’m a **Microsoft Certified expert**, I know the **operating system** inside and out.

**&lt;Image and Configuration Designer&gt;** alone could replace **&lt;DeepFreeze&gt;**

However, neither **&lt;DeepFreeze&gt;** or **&lt;CASSIE&gt;** are my concern.

### [B]: Concerns with Meraki Cloud
