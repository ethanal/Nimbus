# API Reference

The Nimbus API uses token authentication, so it is recommended that you secure the `account` and `api` subdomains with HTTPS. The `Authorization` header for requests that require it should have the following form:

```
Token 81d1445d307741e63f5c6f26d4e840175c21a34d
```

The term "media item" refers to a file or a shortened link.

***

## Obtain Authorization Token
Obtain the API authorization token corresponding to a username/password pair.

### Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/api-token-auth`
- Parameters
  - `username`: The username for the user whose token should be returned
  - `password`: The password for the user whose token should be returned

### Response
- Status: 200 OK
- Body:

  ```js
  {
      "token": "81d1445d307741e63f5c6f26d4e840175c21a34d"
  }
  ```

### Errors

If the provided credentials are not valid, the following response is returned:

- Status: 400 Bad Request
- Body:

  ```js
  {
      "non_field_errors": [
          "Unable to login with provided credentials."
      ]
  }
  ```

***

## List Media Items
List all media items created by the authorized user.

All media items are serialized the same way. Links and files can be differentiated using the `media_type` attribute.

Valid media type codes are as follows:

- `URL`: Shortened URLS
- `IMG`: Image files
- `TXT`: Text files
- `ARC`: Archive files
- `AUD`: Audio files
- `VID`: Video files
- `ETC`: Other files

### Request
- Requires: Authentication
- HTTP Request Method: `GET`
- URL: `/media/list`
- Optional URL Parameters:
  - `media_type`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)

### Response
- Status: 200 OK
- Body:

  ```js
  [
      {
          "url_hash": "clJwWj",
          "share_url": "http://example.com/clJwWj",
          "name": "example.png",
          "target_url": "",
          "target_file": "de807a6626ed47c1adf3696bfb2cb9ef/example.png",
          "target_file_url": "http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png",
          "view_count": 4,
          "upload_date": "2014-01-02T03:04:05.060Z",
          "media_type": "IMG"
      },
      {
          "url_hash": "i7UrcU",
          "share_url": "http://example.com/i7UrcU",
          "name": "http://en.wikipedia.org/wiki/Example",
          "target_url": "http://en.wikipedia.org/wiki/Example",
          "target_file": "",
          "target_file_url": "",
          "view_count": 2,
          "upload_date": "upload_date": "2014-01-02T03:45:06.070Z",
          "media_type": "URL"
      }
  ]
  ```

***

## Show Media Item Details
Show details for a media item.

### Request
- Requires: Authentication
- HTTP Request Method: `GET`
- URL: `/media/show`
- URL Parameters:
  - `url_hash`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)

### Response
- Status: 200 OK
- Body:

  ```js
  {
      "url_hash": "clJwWj",
      "share_url": "http://example.com/clJwWj",
      "name": "example.png",
      "target_url": "",
      "target_file": "de807a6626ed47c1adf3696bfb2cb9ef/example.png",
      "target_file_url": "http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png",
      "view_count": 4,
      "upload_date": "2014-01-02T03:04:05.060Z",
      "media_type": "IMG"
  }
  ```

***

## Upload File
Create a media item for a file.

### Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/media/add_file`
- Parameters
  - `file`: The file to upload.

### Response
- Status: 201 Created
- Body:

  ```js
  {
      "url_hash": "clJwWj",
      "share_url": "http://example.com/clJwWj",
      "name": "example.png",
      "target_file": "de807a6626ed47c1adf3696bfb2cb9ef/example.png",
      "target_file_url": "http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png",
      "upload_date": "2014-01-02T03:04:05.060Z",
      "media_type": "IMG"
  }
  ```

***

## Add Link
Create a media item for a URL.

### Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/media/add_link`
- Parameters
  - `target_url`: The URL to shorten.

### Response
- Status: 201 Created
- Body:

  ```js
  {
      "url_hash": "i7UrcU",
      "share_url": "http://example.com/i7UrcU",
      "target_url": "http://en.wikipedia.org/wiki/Example",
      "upload_date": "2014-01-02T03:45:06.070Z"
  }
  ```

***

## Delete Media Items
Delete one or more media items.

### Request
- Requires: Authentication
- HTTP Request Method: `DELETE`
- URL: `/media/delete`
- URL Parameters
  - `url_hash`: The URL hash of the media item that should be deleted. This parameter can be repeated to delete multiple items.

### Response
- Status: 204 No Content

***
