DRIVE_STANDINGS_FILE=drivers_standings.xml
DRIVE_LIST_FILE=drivers_list.xml

error=0
invalid_arguments_number=0
null_api_key=0
year_error=0
information_not_found=0
long=$(expr length "$API_KEY")


if [ $# -ne 2 ]
then
    echo "Invalid number of arguments error"
    exit 2
fi

#$API_KEY must be 40 chars long
if [ 40 -ne $long ]
then
    echo "Invalid Api Key or not found"
    exit 2
fi

if [ $2 -lt 2013 ] || [ $2 -gt 2023 ]
then
    echo "The year choosen has to be between 2013 and 2023"
    exit 2
fi


if [[ $1 =~ (sc|xf|cw|go|mc)$ ]]
then
    echo > /dev/null
else
    echo "Wrong categorie input error"
    exit 2
fi

competitionType=$1
year=$2


# Call to information and lineups endpoint
./scripts_bash/drivers_standings.sh $DRIVE_STANDINGS_FILE $competitionType $year
if [ $? -ne 0 ]
then
    exit 2
fi
./scripts_bash/drivers_list.sh $DRIVE_LIST_FILE $competitionType $year
if [ $? -ne 0 ]
then
    exit 2
fi

echo "Geting data..."
java net.sf.saxon.Query "invalid_arguments_number=$invalid_arguments_number" "null_api_key=$null_api_key" "information_not_found=$information_not_found" "year_error=$year_error" "year=$year" "competitionType=$competitionType" ./xqueries/extract_nascar_data.xq -o:./data/nascar_data.xml > /dev/null 2>&1

echo "Generating '.fo' archive"
java net.sf.saxon.Transform -s:data/nascar_data.xml -xsl:tools/generate_fo.xsl -o:tools/nascar_page.fo > /dev/null 2>&1

echo "Making the .pdf archive"
./fop-2.9/fop/fop ./tools/nascar_page.fo  nascar_report.pdf > /dev/null 2>&1
echo "The pdf name as \"nascar_report.pdf\" can be found at the actual directory"