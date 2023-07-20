#Narrativia - An iOS App to listen audiobooks using LibriVox API
---    

##Summary
This project was build during an intership, as a course completion, by two developers: Gloria Martins and Leandro Silva, both technicians in Mobile Applications. The purpose of the development of this application was to provide the students, by practicing, how to develop on the iOS platform.

##Introduction
The "Narrativia" app is **free to use** and includes the main functions for consuming audiobooks, such as:
* Offers a vast collection of audiobooks in more than a hundred (100) languages.
* Ables the user to have acess to their account thorught different devices and without internet connection.
* Reproduce the tracks while navigating and in the offline mode, if the audiobook was previous downloaded.

This app was designed to adress all the needs present in the market, with the plus of an user-friendly interface.


As mentioned before, the content presented on the app are provided by LibriVox API, a REST API, which contains tree endpoints available for the developers intergrate the audiobooks into their apps.
1. Returns the audiobooks - https://librivox.org/api/feed/audiobooks
2. Returns the track of an specific audiobook - https://librivox.org/api/feed/audiotracks
3. Returns the books of an specific author - https://librivox.org/api/feed/authors

However due the quantity of data on each object and aiming a easily acess and management of data, image 2, we opted to document the API using Swagger in conjuction with Open API specifications.

