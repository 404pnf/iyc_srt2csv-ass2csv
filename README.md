
# usage: 

      ruby scriptname.rb

+ all ass files in a dir called 'source'
+ a folder named 'target' would be generated with the expected results
+ put this script in the same folder where 'source' and 'target' reside
+ type ruby scriptname.rb
+ profit!


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


## Expected output

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
