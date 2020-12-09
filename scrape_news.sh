#!/bin/bash

# getting html file of ynet website
wget https://www.ynetnews.com/category/3082 

# using egrep to keep the lines which hold this type of links
# for now we have 9 characters articles, we filtered 10 characters articles by
# forcing a "#" or "\"" char after the last character, because we noticed
# that if it is a 9 characters artice, the next character must be one of the two.
egrep -o '(https://www\.ynetnews\.com/article/.........)(#|")' 3082 > all3082.txt

# we cut the last character to remain with only the link to the article 
while read line; do
	echo $line | cut -c1-42>>final3082.txt	#each link we filtered should have 42 characters
done < all3082.txt

# we used sort and uniq to keep one copy of each link/article
sort final3082.txt | uniq > links.txt
# counting number of articles
total=$(wc -l < links.txt)


# putting the number of articles in the first line of out results file
touch results.txt
echo $total>>results.txt

# we want to work on out articles in a new folder, so we can easily approach
# each one of them without unneccessary conditions
mkdir temp_dir
cp links.txt temp_dir
cd ./temp_dir

# crating html files for each article
while read line; do
	wget $line
done < links.txt

rm links.txt

# using egrep to count num of appearences of "Netanyahu" and "Gantz"
# keeping it in relevant variables
for filename in *; do
	egrep -o '(Netanyahu)' $filename > Netanyahu.txt
	cur_Netanyahu=$(wc -l < Netanyahu.txt)
	egrep -o '(Gantz)' $filename > Gantz.txt
	cur_Gantz=$(wc -l < Gantz.txt)

	# building the next lines in the results file
	if [[ $cur_Netanyahu == 0 ]] && [[ $cur_Gantz == 0 ]]; then
		echo 'https://www.ynetnews.com/article/'$filename', -'>>../results.txt
	else
		echo 'https://www.ynetnews.com/article/'$filename', Netanyahu,'$cur_Netanyahu', Gantz, '$cur_Gantz>>../results.txt
	fi
done

# converting results.txt to results.csv file
cd ../
cat results.txt | sed 's/;/\t/g' > results.csv

# commands we used to delete unnecessary files
# rm -r temp_dir
# rm -v (scrape_news.sh|results.csv|answers.txt)

