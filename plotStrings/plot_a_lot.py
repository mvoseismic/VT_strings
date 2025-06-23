#!/usr/bin/env python
# plot_a_lot.py

#
# Reads all seisan files in strings directories and merges them, then
# - plots all traces in whole window
# - cuts them to a given time window
# - plots all traces in cut window
# - saves locally as a single miniseed file.
#
# R.C. Stewart, 2022-04-05
#
import os
import sys
import glob
import obspy
from obspy import read
from obspy import UTCDateTime
from datetime import timedelta
import numpy as np
import warnings
import gc



def main():

    # This is not good
    warnings.filterwarnings("ignore")

    # directory with seisan subdirectories
    dirSeisan = '/home/seisan/projects/Seismicity/VT_strings/data/seisan_files/0-new'
    #dirSeisan = './test'

    # directory with event list text files
    dirEventList = '/home/seisan/projects/Seismicity/VT_strings/data/event_lists/0-new'

    # iterate over directories in
    # that directory
    for dirSub in sorted(os.listdir(dirSeisan)):

        dirSeisanSub = os.path.join(dirSeisan, dirSub)

        # checking if it is a directory
        if os.path.isdir(dirSeisanSub):
            print(dirSeisanSub)

            # read all seisan files in directory and merge
            st = read(os.path.join(dirSeisanSub, "20*"))
            # get only selected MVO stations
            st2 = st.select( station="MSCP", channel="SHZ", sampling_rate=100 )
            st2 += st.select( station="MSUH", channel="SHZ", sampling_rate=100 )
            st2 += st.select( station="MSS1", channel="SHZ", sampling_rate=100 )
            st2 += st.select( station="MBFR", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBFR", channel="HH*", sampling_rate=200 )
            st2 += st.select( station="MBLG", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBLG", channel="HH*", sampling_rate=200 )
            st2 += st.select( station="MBLY", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBLY", channel="HH*", sampling_rate=200 )
            st2 += st.select( station="MBRY", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBBY", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBBY", channel="HH*", sampling_rate=200 )
            st2 += st.select( station="MBHA", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBHA", channel="SHZ", sampling_rate=100 )
            st2 += st.select( station="MSMX", channel="SHZ", sampling_rate=100 )
            st2 += st.select( station="MBGH", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBGH", channel="HH*", sampling_rate=200 )
            st2 += st.select( station="MBWH", channel="BH*", sampling_rate=100 )
            st2 += st.select( station="MBWW", channel="HH*", sampling_rate=100 )
            #print( st2 )
            st2.merge(method=1)

            del st
            gc.collect()
            
            # plot all traces
            filePlot = dirSub + '--VT_string-all_traces.png'
            st2.plot( outfile=filePlot, size=(1920,1024), linewidth=0.1, equal_scale=False )

            # Find event list file for this string
            fileEventList = os.path.join(dirEventList,dirSub) + ".txt"
            # checking if it is a file
            if os.path.isfile(fileEventList):
                #print(fileEventList)

                # Read all lines from text file
                with open(fileEventList) as ef:
                    efLines = ef.readlines()
                    ef.close()

                # Get datims from first and last lines
                lineFirst = efLines[0]
                #print( lineFirst )
                datimChunks = lineFirst.split()
                yr = int(datimChunks[0])
                mo = int(datimChunks[1])
                da = int(datimChunks[2])
                hr = int(datimChunks[3])
                mi = int(datimChunks[4])
                secondChunks = datimChunks[5].split('.') 
                se = int(secondChunks[0])
                ms = 100000 * ( int(secondChunks[1]) )
                datimFirst = UTCDateTime( yr, mo, da, hr, mi, se, ms )
                #print( datimFirst )
                lineLast = efLines[-1]
                #print( lineLast )
                datimChunks = lineLast.split()
                yr = int(datimChunks[0])
                mo = int(datimChunks[1])
                da = int(datimChunks[2])
                hr = int(datimChunks[3])
                mi = int(datimChunks[4])
                secondChunks = datimChunks[5].split('.') 
                se = int(secondChunks[0])
                ms = 100000 * ( int(secondChunks[1]) )
                datimLast = UTCDateTime( yr, mo, da, hr, mi, se, ms )

                # Trim traces
                delta5m = timedelta( minutes=5 )
                st2.trim( datimFirst-delta5m, datimLast+delta5m )
                # plot all trimmed traces
                filePlot = dirSub + '--VT_string-all_traces-trimmed.png'
                st2.plot( outfile=filePlot, size=(1920,1024), linewidth=0.1, equal_scale=False )

                # Program crashes on writing Masked Array Data, this fixes that.
                for tr in st2:
                    if isinstance(tr.data, np.ma.masked_array):
                        tr.data = tr.data.filled()

                # Save traces to miniseed file
                fileMseed = dirSub + '.mseed'
                st2.write( fileMseed, format='MSEED')

                del st2
                gc.collect()


if __name__ == "__main__":
    main()


