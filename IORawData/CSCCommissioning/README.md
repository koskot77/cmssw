CSCFileReader
=============

The CSCFileReader is an offline Event Builder unit for the Cathode Strip Chamber (CSC) system.
It merges event segments from up to 40 independent ReadOut Units (RUIs) and construct the CSC
raw event buffer for subsequent unpacking and analysis that can be done within CMSSW framework
or in a stand alone mode.

Each of the RUIs writes the local (regional) event data in an independent file. Each record in
this file consists of a raw readout event buffer wrapped in a header -- trailer code marks.
The hardware is designed to operate close to it's physical capacity so the error recovery mechanism
is an indispensable part of any software package manipulating data from such system. The RUI
buffer read by an instance of FileReaderDDU class (membered by CSCFileReader) and is assigned
with a *status flag* coding a potential corruption of a header (H) or trailer (T) code marks:

1. [H-T] --- normal event
2. [H-?]H --- more likely event with corrupted trailer
3. [H-max] --- "DDUoversize" condition
4. [?-T] --- could be anything
5. [?-?]H ---  could be anything (depends on previous event)
6. [?-max] --- could be anything
7. [FFFF] --- some standard sequence to complete Ethernet package

The FileReaderDDU instance can be instructed to select/reject events with any type of the _status flag_
by means of the _select_, _accept_, and _reject_ functions combined with the _next_ call.

An additional functionality includes reading partially built events from the Filter Units (FU)
by means of FileReaderDCC class. For the debugging purposes, the built events can be "unbuilt"
and logged back to independent RUI data files using CSCFileDumper module. 
