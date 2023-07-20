# Narrativia - An iOS App to listen audiobooks using LibriVox API
---    

## Summary
This project was built during an intership, as a course completion, by two developers: Gloria Martins and Leandro Silva, both technicians in Mobile Applications. The purpose of the developing this application was to provide the students, by practicing, how to develop in the iOS platform.

## Introduction
The "Narrativia" app is **free to use** and includes the main functions for consuming audiobooks, such as:
* Offers a vast collection of audiobooks in more than a hundred (100) languages.
* Allows the user to have acess to their account thorught different devices and without internet connection.
* Reproduce the tracks while navigating and in the offline mode, if the audiobook was previous downloaded.

This app was designed to adress all the needs present in the market, with the plus of an user-friendly interface.
![App example](docs/mobile-app.png "App example")


## API LibriVox and Swagger
The main content presented on the app are provided by LibriVox API, a REST API, which contains three endpoints available for developers to integrate the audiobooks into their apps.
1. Returns the audiobooks 
2. Returns the track of an specific audiobook
3. Returns the books of an specific author 

However due the quantity of data in each object, as represented below, and aiming for easy access and management of data, we opted to document the API using Swagger in conjuction with Open API specifications.

Example: Request GET audiobooks 
> https://librivox.org/api/feed/audiobooks?format=json&extended=1'

Response:
```
{
  "books": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "genres": [
        {
          "id": "string",
          "name": "string"
        }
      ],
      "authors": [
        {
          "id": "string",
          "first_name": "string",
          "last_name": "string"
        }
      ],
      "num_sections": "string",
      "sections": [
        {
          "id": "string",
          "section_number": "string",
          "title": "string",
          "listen_url": "string",
          "language": "string",
          "playtime": "string",
          "file_name": "string",
          "readers": [
            {
              "reader_id": "string",
              "display_name": "string"
            }
          ],
          "genres": [
            {
              "id": "string",
              "name": "string"
            }
          ]
        }
      ],
      "language": "string",
      "url_zip_file": "string",
      "url_librivox": "string",
      "url_project": "string",
      "url_rss": "string",
      "totaltime": "string",
      "totaltimesecs": 0
    }
  ]
}
```
By creating the models on Swagger, the client code is easily generated and then embbed into the code. Below there's and example of how to call the API from Swift.
```
DefaultAPI.audiobooksTitletitleGet(title: text, format: "json", extended: 1) { [self] data, error in
[...]
}
```

## Database schemas
The "Narrativia" is populated by the API, but to enhance the user experience and enable offline acess, some data must be stored. Therefore, the apps utilizes two different database schemas:

Firestore
Exclusively used to stored some support content related to the genres came from API and personal data.



CoreData
Utilized to persist the data locally, so the offline mode could works. The CoreData data is updated everytime that the app is started, with a stablish connection, and when occurs some alteration on de remote database, ensuring a synchronism between both schemas.

*In case of offline updates, the sync algorithm stays effectivly as a result of the usage of Firebase Persistance

##Player





