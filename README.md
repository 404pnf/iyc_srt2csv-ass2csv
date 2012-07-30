
# requirements:

+ ruby 1.9.x; it's a must
+ gnu/linux or mac osx; windows complaints abuot encoding and I don't know how to fix it; no incentive, either
+ in case of problems, blame yourself and read this file again. 


# usage: 

      ruby scriptname.rb inputfolder outputfolder

# nota bene, aka, N.B.

This s a quick-and-dirty solution for a specific use caes.  So lots of things are hardcoded and global variables all over the place.  Yes, it's ugly.  But it GTD!

Also the following assumptions are made:

1. input files are encoded in utf-8, if not, please re-encode your file.  On windowos, use notpad++
1. output files are encoded in utf-8 with BOM, because excel on windows need the BOM header to recognize that a csv file is encoded in utf-8; please blame Microsoft for this

Want a flexible solution?  Fork and DIY!


# walk through
## directory layout

      - somefolder
        - recursive-ass2csv.rb
        - source
          - MIT
      	  - autumn
      	   - wooping.ass
      	  - spring
      	   - wipe.ass
      	- USC
      	 - USC.univ.4.spoiled.children.ass
        - target

## run the scirpt

       ruby recursive-ass2csv.rb somefolder, outfolder

## expected output

      - somefolder
        - recursive-ass2csv.rb
        - source
          - MIT
      	  - autumn
      	    - wooping.ass
      	  - spring
      	    - wipe.ass
      	- USC
      	  - USC.univ.4.spoiled.children.ass
        - outputfolder
      	  - autumn
      	    - wooping.ass.csv
      	  - spring
      	    - wipe.ass.csv
      	- USC
      	  - USC.univ.4.spoiled.children.ass.csv
	  
# internal logic sum up

See the input file as text stream, one line a time.

Origianl transcript and translation can be in separate lines, but they share the same timestamp.

parse the line, get the timestamp, lang code, and transcript text, then make it a hash:  

hash[timestamp][:chs]
hash[timestamp][:eng]

sort the hash by timestamp.  This turn the hash to an array.

write the array to csv.

# support and contribution

https://github.com/404pnf/srt2csv-ass2csv
