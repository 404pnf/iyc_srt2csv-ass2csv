
# requirements:

+ ruby 1.9.x; it's a must
+ gnu/linux or mac osx; windows complaints abuot encoding and I don't know how to fix it; no incentive, either
+ in case of problems, blame yourself and read this file again and again. 

# usage: 

      ruby scriptname.rb

1 all ass/srt files in a direcotry called 'source
1. put this script in the same folder where 'source' resides
1. type:  ruby scriptname.rb (replace scriptname.rb with either recursive-ass2csv.orb or recursive-srt2csv.rb)
1. a directory named 'target' would be generated with the csv files
1. profit!


# walk through

Make sure your folder structure looks like this.  The directory name 'source' and 'target' is hardcoed in the script.  So, stick to it. Use lowercase only!

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

       ruby recursive-ass2csv.rb

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
        - target
      	  - autumn
      	    - wooping.ass.csv
      	  - spring
      	    - wipe.ass.csv
      	- USC
      	  - USC.univ.4.spoiled.children.ass.csv
	  
# support and contribution

https://github.com/404pnf/srt2csv-ass2csv
