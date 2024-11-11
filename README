This is a fun project for designs that:
* Does not have a VCO available
* Has a "low" frequency master clock
* Uses circuits that can work at higher frequencies

To improve, a little bit the performances, the phase comparator can run on both edges.


There are three projects, depending the application targeted.

* Dual_flip-flop

There are one flip flop per edge. If one of them is set, it hold the other one in reset state.
The output clock starts.
After the counter counts the N output clocks cycles, the active flip flop resets and the output clock stops.
The input reference CLK is connected to the J, the end of the counter to the K. The counter end can take one cycle to return to '0' but not more.
  ** The reference clock is returned to '0', the counter end sets the K to '1'.
  ** The reference clock raise to '1'. Regardless K is returned to '0' or not, the flip flop sets.
  ** The reference clock should return to '0' before a couple of cycles of its next raise. K has to be returned to '0'. 
The properties are:
  ** The advantage is the phase shift between the reference clock and the output clock
       is 2 times less than the "classics" way.
  ** The second advantage is the reference clock can have a high low-frequency jitter.
  ** The drawback is the client should support regular clocks stops.
  ** The constraints is the reference clock should return to 0 before the end of the "bulk".
  ** The constraints for a 74HC discrete implementation is to send the master clock to 2 xor gates,
       one has the other input tied to 0, the other to 1, in order to keep the 2 clocks close to the opposite phase. 
The performance of the circuits should be high as:
  the reset requested signal is delayed by two logic gates plus the counter delay.


* Dual_flipflop_counters

This one is similar to the one above, but each flip flop has its own counter.
It allows higher frequencies or lower performances of the circuits.
  ** The counter counts on the same edge than the flip flop.
  ** The logical gates at the output of the flips flops are only to generate the output clock.
  ** Two time their propagation time is assumed to be lower than the one of the flip-flop or counter.
  ** The counter and the flip-flop should be in the same technology.
  ** There is no gate between the highest counter bit and the K of the flip-flop, not between the flip-flop and the count or load/reset of the counter.
Then the maximum master clock is the maximum supported by the logic.


* Snapshot

This is a more classic DDS VCO in which the phase between the output and the ref-clock is taken on both edges.
A first latch takes a snapshot on the falling edge (one generally use the rising edge).
The second latch is the main one that takes the ref-clock and the (temporary) snapshot.
All the circuit has one bit on the right size of the coma (binary) while counting between 2 rising edges.
