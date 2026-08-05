# genomics-variant-calling-pipeline
This was created using Claude Sonnet 5 High to learn bioinformatics tools for genomics variant calling in the folder. Anything outside of the folder is produced by [Sierra T. Mullins](https://sierrathoune-sketch.github.io/portfolio/#Education) using the output of the Claude model. I have modified, debugged, and troubleshooted to create projects following the markdown instructions in the folder genomics-variant-pipeline. Information below was summarized from [here](https://datacarpentry.github.io/organization-genomics/01-tidiness.html).

# Laboratory Notebooks
Electronic laboratory notebooks (ELNs) and laboratory notebooks best practices:
- Permanently bound book with consecutive signed and dated entires, witness entries when approrpiate pages sconsecutively numbered 
- Identify and describe reagents and specimens used with material source, instrument serial numbers and calibration dates, proper nouns for items, first person with who specifically did work, explain nonstandard abbreviations
- Use ink and never obliterate original writings
- Draw line through blank spaces or pages
- Outline new experiments with objectives and rationale
- Enter ideas and observations immediately, summarize discussions from lab meetings and ideas or suggestions made by others citing the persons by name

# Data Management Systems
- Sort and search
- Consistency through standards
- Ability to update records
- Store lab protocols, primary data including images, specimens and reagents, information about instruments
</br>
[Metadata Standards](dcc.ac.uk/resources/metadata-standards/list) and [Genomics Data Standards](https://www.gensc.org/pages/projects.html)

# Data Structures in Spreadsheets
- Do not change raw data
- Each observation/sample in its own row
- Variables in columns
- Column names explanatory without spaces uses "-" or "_" instead of space
- Do not combine multiple pieces of information in one cell
- Export cleaned data to text-based format like CSV

# Common Spreadsheet Errors
- Multiple tables and tabs
- Not filling in zeros
- Using problematic null values
- Using formatting to convey information or make data sheet look pretty
- Placing comments or units in cells
- Entering more than one piece of information in a cell
- Using problematic field names
- Using special characters in data
- Inlcusion of metadata in data table
- Date formatting

# Data Storage Guidelines
- Store data in an accessible location that is redundantly backed up in two locations that are in different physical areas
- Leave the raw data row
- If there is no local high performance computing center or data storage facility (ideal) back up on hard drives with two backups and keep them in different physical locations

# Shell 
- Clear (Ctr+l)
- $ is a prompt shows shell is waiting for input DO NOT TYPE IT, only the command that follows
- pwd = print working directory
- ls = listing (directories); add "~" shows home directory
- cd = change directory; navigate between folders "." current, ".." one level above directory
- -F = tells ls to add trailing / to names of directories since anything with is "/" after it is a directory, "*" after is program, no decorations indicates a file
- man ls = manual listing displays all other commands
- ls -F = lists all files in directory
- Pressing tab to fill in rest of directory name
- Up arrow previous command
- Ctrl+A = start of command
- Ctr+c = cancel command
- Ctr+r = reverse-search command history
- histroy = recent commands
- !COMMAND# = re-run
- cat = print contents on screen
- less = search read-only files
- head and tail = begininng and end of a program
- -n = print first or last n lines of file
- cp = copy
- mdir = make directory followed by space then name of directory
- mv = move files and rename
- ls -l = view permissions on file
- chmod -w = change mode and write permission
- rm = remove file - Y
- -r = remove directories
- rm -r = removes all files within directory
- rm -i = prompt if you want to delete every file regardless of permission setting
- grep = search plain-text files string or patterns
- wc -l = word count lines
- for = repeat command once for each item in a list
- Each loop ran is an iteration, each item assigned is variable, $ tells variable substitute value in its place "expanding" the variable
- basename = remove uniform part of name from list of files
- ".sh" = shell script
- wget = world wide web get download webpages or data at web address
- cURL = see URL display webpages or data at a web address
- which = looks through everything and tells what folder it's installed
- scp = secure copy protocol moves files between computer
<img width="1301" height="356" alt="image" src="https://github.com/user-attachments/assets/83dbe58f-bd9f-4cd7-9a4c-8f8d567527dd" />


# FASTQ
- Line 1 Begins with @ and then information about read
- Line 2 actual DNA sequence
- Line 3 begins with "+" and sometimes same info in line 1
- Line 4 string of characters represent quality score with same number of characters as line 2

# Cloud Computing
- whoami - username
- df -h = shows space on hard drive
- cat /proc/cpuinfo = shows how many processors (CPUs) machine has
- tree -L 9 = shows treeview of file system 1 level below your current location
- tmux = session or window
- sudo = super user do; allows user to run programs as administrator without logging off and logging back on as admin
- Most HPCCs (High Performannce Computing Clusters) puts limits on processors number, disk storage, time single processor may run, what programs installed and whom, who can access
- XSEDE, Open Science Grid, Open Science Data Cloud, Atmosphere, CyVerse (iPlant Collaboratorive) Atmosphere, JetStream
- Amazon EC2, Google Cloud, Microsoft Azure, IBM Cloud

# Bioinformatic Workflow
Sequence Reads + Quality Control (FASTQ) > Alignment (SAM/BAM) > Cleanup (BAM) > Variant Calling (VCF)
- Quality control by FastQC

# Bioinformatician Skill Sets
- General: time management, project management, management of multiple projects, independence, curiosity, self-motivation, ability to synthesize information, ability to complete projects, leadership, critical thinking, dedication, ability to communicate scientific concepts, analytical reasoning, scientific creativity, collaborative ability
- Computational: programming, software engineering, system administratino, algorith design and analysis, mechine learning, data mining, database design and management, scripting languages, ability to use scientific and statistical analysis software packages, open source software repositories, distributed and high-performance computing, networking, web authoring tools, web-based user interface implementation technologies, version control tools
- Biology: molecular biology, genomics, genetics, cell biology, biochemistry, evolutionary theory, regulatory genomics, systems biology, next generation sequencing, proteomics/mass spectrometry, specialized knowledge in one or more domains
- Statistics and Mathematics: application of statistics in the contexts of molecular biology and genomics, mastery of relevant statistical and mathematical modeling methods (including experimental design, descriptive and inferential statsitics, probability theory, differential equations and parameter estimation, graph theory, epidemiological data analysis, analysis of next generation sequencing using R and Bioconductor)
- Bioinforamtics: analysis of biological data; working in production environment managing scientific data; modeling and warehousing of biological data; using and building ontologies; retreiving and manipulating data from public repositories; ability to manage, interpret, and analyze large data sets; broad knowledge of bioinformatics analysis methodologies; familiarity with functional genetic nad genomic data; expertise in common bioinformatics software packages, tools, and algorithms


<a href="https://www.buymeacoffee.com/sierramullins" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-green.png" alt="Buy Me a Coffee" style="height: 60px !important;width: 217px !important;" ></a>
