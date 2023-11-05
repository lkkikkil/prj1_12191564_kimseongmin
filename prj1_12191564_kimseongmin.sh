#!/bin/sh

moviesFile=$1
ratingsFile=$2
usersFile=$3

getMovieInfo() {
  read -p "Please enter 'movie id'(1~1682):" movieId
  echo ""

  cat $moviesFile | awk -F\| -v _movieId=$movieId '$1 == _movieId {print $0}'
}

getActionMoives() {
  read -p "Do you want to get the data of ‘action’ genre movies from 'u.item'?(y/n):" answer
  echo ""

  if [ $answer = "y" ]
  then 
    cat $moviesFile | awk -F\| '$7 == 1 {print $1, $2}' | head -n 10
  elif [ $answer = "n" ]
  then 
    return 
  else 
    echo "wrong answer"
  fi
}

getAverageRating() {
  read -p "Please enter the 'movie id'(1~1682):" movieId
  echo ""

  cat $ratingsFile \
  | awk -v _movieId=$movieId '$2 == _movieId {sum+=$3; amount++}
  END {if (amount != 0) average = sum / amount; printf("average rating of %s: %.5f\n", _movieId, average)}' 
}

getMovieInfoDelURL() {
  read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" answer
  echo ""

  if [ $answer = "y" ]
  then 
    cat $moviesFile | head -n 10 | sed 's/[^|]*|/|/5'
  elif [ $answer = "n" ]
  then 
    return 
  else 
    echo "wrong answer"
  fi
}

getUserInfo() {
  read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
  echo ""

  if [ $answer = "y" ]
  then 
    cat $usersFile | head -n 10 \
    | sed -e 's/|M|/|male|/' -e 's/|F|/|female|/' \
    -Ee 's/([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)/user \1 is \2 years old \3 \4/'
  elif [ $answer = "n" ]
  then 
    return 
  else echo "wrong answer"
  fi
}

getModifiedMovieInfo() {
  read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" answer
  echo ""

  if [ $answer = "y" ]
  then 
    cat $moviesFile | tail -n 10 \
    | sed -Ee 's/\|([0-9]{2})-Jan-([0-9]{4})\|/|\201\1|/' \
    -Ee 's/\|([0-9]{2})-Feb-([0-9]{4})\|/|\202\1|/' \
    -Ee 's/\|([0-9]{2})-Mar-([0-9]{4})\|/|\203\1|/' \
    -Ee 's/\|([0-9]{2})-Apr-([0-9]{4})\|/|\204\1|/' \
    -Ee 's/\|([0-9]{2})-May-([0-9]{4})\|/|\205\1|/' \
    -Ee 's/\|([0-9]{2})-Jun-([0-9]{4})\|/|\206\1|/' \
    -Ee 's/\|([0-9]{2})-Jul-([0-9]{4})\|/|\207\1|/' \
    -Ee 's/\|([0-9]{2})-Aug-([0-9]{4})\|/|\208\1|/' \
    -Ee 's/\|([0-9]{2})-Sep-([0-9]{4})\|/|\209\1|/' \
    -Ee 's/\|([0-9]{2})-Oct-([0-9]{4})\|/|\210\1|/' \
    -Ee 's/\|([0-9]{2})-Nov-([0-9]{4})\|/|\211\1|/' \
    -Ee 's/\|([0-9]{2})-Dec-([0-9]{4})\|/|\212\1|/'
  elif [ $answer = "n" ]
  then 
    return 
  else 
    echo "wrong answer"
  fi
}

getRatedMoviesByUser() {
  read -p "Please enter the 'user id'(1~943):" userId
  echo ""

  sortedRatedMovies=$(cat $ratingsFile | awk -v _userId=$userId '$1 == _userId {print $2}' | sort -n)
  echo $sortedRatedMovies | tr ' ' '|' | sed 's/|$/\n/'
  echo ""

  n=1
  while [ $n -le 10 ]
  do
    movieId=$(echo $sortedRatedMovies | awk -v _n=$n '{print $_n}')
    cat $moviesFile | awk -F\| -v _movieId=$movieId '$1 == _movieId {print $1 "|" $2}'
    let n=n+1
  done
}

getAverageRatingByProgrammer() {
  read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" answer
  echo ""

  if [ $answer = "y" ]
  then
    programmerUserIds=$(cat $usersFile | awk -F\| '$2 >= 20 && $2 < 30 && $4 == "programmer" {print $1}')

    ratings=""
    for userId in $programmerUserIds
    do
      ratings+=$(cat $ratingsFile | awk -v _userId=$userId '$1 == _userId {print $2 "|" $3}')
      ratings+=' '
    done
    movieId=1
    movieAmount=$(cat $moviesFile | wc -l)
    while [ $movieId -le $movieAmount ]
    do
      echo $ratings | tr ' ' '\n' \
      | awk -v _movieId=$movieId -F\| '$1 == _movieId {sum+=$2; amount++} 
      END {if (amount != 0) printf("%s %.5f\n", _movieId, sum / amount)}' \
      | sed -e 's/[0]*$//' -e 's/\.$//'

      let movieId=movieId+1
    done
  elif [ $answer = "n" ]
  then 
    return 
  else echo "wrong answer"
  fi
}

echo "--------------------------"
echo "User Name: 김성민"
echo "Student Number: 12191564"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true
do
  read -p "Enter your choice [ 1-9 ] " order
  echo ""
  case $order in
  1) 
    getMovieInfo;;
  2)
    getActionMoives;;
  3)
    getAverageRating;;
  4)
    getMovieInfoDelURL;;
  5)
    getUserInfo;;
  6)
    getModifiedMovieInfo;;
  7)
    getRatedMoviesByUser;;
  8)
    getAverageRatingByProgrammer;;
  9)
    echo "Bye!"
    break;;
  *) 
    echo "wrong order";;
  esac
  echo ""
done
