#!/bin/bash

# the function "round()" was taken from
# http://stempell.com/2009/08/rechnen-in-bash/

# the round function:
round()
{
	echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};


if ! ping openweathermap.org -c 1 > /dev/null
then
	echo "????"
	exit 0;
fi


# Get the source directory of the script.
# The config.json file should be in the same directory.
SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)


# Get the app ID and city ID from the config file.
APPID=$(cat $SOURCE/config.json | jq '.appid')
APPID="${APPID%\"}"
APPID="${APPID#\"}"

CITY_ID=$(cat $SOURCE/config.json | jq '.city_id')
CITY_ID="${CITY_ID%\"}"
CITY_ID="${CITY_ID#\"}"


# Format the request URL
URL="https://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&appid=$APPID"


# Query the weather data using the API.
RES=$(curl -s $URL)


# Get icon number.
ICON=$(echo $RES | jq '.weather[ 0 ].icon')
ICON="${ICON%\"}"
ICON="${ICON#\"}"


# Get temperature in Kelvin, Celsius, and Fahrenheit.
K_TEMP=$(echo $RES | jq '.main.temp')
C_TEMP=$(echo "$K_TEMP - 273.15" | bc -l)
F_TEMP=$(echo "($C_TEMP * 1.8) + 32" | bc -l)


# Get weather icon given icon number.
# Icon number documentation: https://openweathermap.org/weather-conditions
case $ICON in
	# Clear Sky
	01d)
		ICON="󰖙"
		;;
	01n)
		ICON="󰖔"
		;;

	# Few Clouds
	02d)
		ICON="󰖕"
		;;	
	02n)
		ICON="󰼱"
		;;	

	# Scattered Clouds
	03d | 03n)
		ICON="󰖐"
		;;	

	# Broken Overcast Clouds
	04d | 04n)
		ICON="󰖐"
		;;	


	# Shower Rain
	09d | 09n)
		ICON="󰖗"
		;;	

	# Moderate / Heavy Rain
	10d | 10n)
		ICON="󰖖"
		;;	
	# Thunderstorm 
	11d | 11n)
		ICON="󰙾"
		;;	
	
	# Snow
	13d | 13n)
		ICON="󰖘"
		;;	
	
	# Fog
	50d | 50n)
		ICON="󰞍"
		;;	

	# Unknown
	*)
		ICON="??"
		;;
esac


# Print out the weather string.
# This output is piped to the Polybar module.
echo "$ICON $(round $F_TEMP 0)°F"

