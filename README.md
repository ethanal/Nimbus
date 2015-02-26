#Nimbus

Nimbus is a private file sharer and URL shortener. Heavily inspired by [Cloudapp](http://www.getcloudapp.com/), Nimbus is a free and open source solution to file sharing and URL shortening that you can host yourself and fully control.

Nimbus consists of several components:

* A website that displays sharing pages for generated links and redirects shortened URLs to their targets
* A website to manage shared items
* An API to manipulate shared items
* A Mac OS X menubar app to upload files and shorten links

The menubar app is only compatible with OS X 10.9 and up since it is written in [Swift](https://developer.apple.com/swift/). The files are stored in Amazon S3, so you must have an AWS account.

##Features

- Share pages that show file previews or redirect to the shortened link
  - Image file previews
  - Text file previews with automatic syntax highlighting if applicable
- Screenshots are automatically uploaded and the share link is copied to the clipboard
- Drag a file or text to the menubar icon to upload it and copy the share link to the clipboard
- Drag a URL to the menubar icon to create a shortened link and copy it to the clipboard
- Keep track of view counts for files and shortened URLS

##Setup

To set up the Django app, perform the following steps on your server (assumes [pip](http://pip.readthedocs.org/en/latest/), [virtualenv](http://virtualenv.readthedocs.org/en/latest/), and [MySQL](http://www.mysql.com/) are already installed)

1. Create a virtualenv and activate it
2. Clone the repository (from here on, it is assumed that the respository's location is `/usr/local/www/Nimbus`)
3. While in the repository root, install the Python requirements by running

   ```bash
   pip install -r requirements/production.txt
   ```

4. Create a database and grant a user full access to it.
5. Follow the instructions in `nimbus/settings/secret.sample.py` to create a secrets file with your MySQL and Amazon S3 credentials
6. Set up the environment for the Django app by running

   ```bash
   export PRODUCTION=TRUE
   ```

7. Set up the database and create your user by running `./manage.py syncdb`
8. Start a Django shell (`./manage.py shell`) and run the following commands, replacing `example.com` with your domain name

   ```python
   from django.contrib.sites.models import Site
   Site.objects.update(name="example.com", domain="example.com")
   ```

9. Collect static files by running

   ```bash
   yes yes | ./manage.py collectstatic
   ```

###Serving Nimbus

Make sure you have a domain name configured with the following records:

```
@       IN A  <IP address of your server>
api     CNAME @
account CNAME @
files   CNAME files.<your domain name>.s3.amazonaws.com.
```

Also make sure you have an Amazon S3 bucket called `files.<your domain name>`

The recommended setup for serving Nimbus is [Gunicorn](http://gunicorn.org/) managed by [Supervisor](http://supervisord.org/) with [nginx](http://nginx.org/) as a reverse proxy. Configuration requirements are as follows.

* Nginx must be listening on the subdomains `account` and `api` of your domain as well as the root domain. Forward all of this traffic to Gunicorn - the Django app handles the subdomain routing.
* The attribute `client_max_body_size` must be set in the nginx config to a sufficiently large value to allow uploads of big files.
* Static file requests (`/static/`) should be aliased to `nimbus/collected_static` in the repository root
* Supervisor must call the version of gunicorn in your virtualenv

####Example Supervisor Configuration

```ini
[program:nimbus]
directory = /usr/local/www/Nimbus
user = nobody
command = /usr/local/virtualenvs/Nimbus/bin/gunicorn nimbus.wsgi:application --user=nobody --workers=1 --bind=127.0.0.1:8080
environment = PRODUCTION=TRUE
stdout_logfile = /var/log/sites/nimbus.gunicorn.log
stderr_logfile = /var/log/sites/nimbus.gunicorn.log
autostart = true
autorestart = true
```

####Example Nginx Configuration
```nginx
server {
    listen 80;
    server_name example.com account.example.com api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com account.example.com api.example.com;

    ssl on;
    ssl_certificate /usr/local/certs/example.com.crt;
    ssl_certificate_key /usr/local/certs/example.com.key;

    client_max_body_size 1024M;

    access_log /var/log/sites/nimbus.access.log;
    error_log /var/log/sites/nimbus.error.log;

    location /favicon.ico {
        alias /usr/local/www/Nimbus/nimbus/static/img/favicon.ico;
    }

    location /static/ {
        alias /usr/local/www/Nimbus/nimbus/collected_static/;
    }

    location / {
        rewrite ^/((?!(api-auth|admin))(.*))/$ /$1 permanent;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

    }
}
```

##API Reference

The Nimbus API uses token authentication, so it is recommended that you secure the `account` and `api` subdomains with HTTPS. The `Authorization` header for requests that require it should have the following form:

```
Token 81d1445d307741e63f5c6f26d4e840175c21a34d
```

The term "media item" refers to a file or a shortened link.

***

###Obtain Authorization Token
Obtain the API authorization token corresponding to a username/password pair.

####Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/api-token-auth`
- Parameters
  - `username`: The username for the user whose token should be returned
  - `password`: The password for the user whose token should be returned

####Response
- Status: 200 OK
- Body:

  ```js
  {
      "token": "81d1445d307741e63f5c6f26d4e840175c21a34d"
  }
  ```

####Errors

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

###List Media Items
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

####Request
- Requires: Authentication
- HTTP Request Method: `GET`
- URL: `/media/list`
- Optional URL Parameters:
  - `media_type`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)

####Response
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

###Show Media Item Details
Show details for a media item.

####Request
- Requires: Authentication
- HTTP Request Method: `GET`
- URL: `/media/show`
- URL Parameters:
  - `url_hash`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)

####Response
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

###Upload File
Create a media item for a file.

####Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/media/add_file`
- Parameters
  - `file`: The file to upload.

####Response
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

###Add Link
Create a media item for a URL.

####Request
- Requires: Authentication
- HTTP Request Method: `POST`
- URL: `/media/add_link`
- Parameters
  - `target_url`: The URL to shorten.

####Response
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

###Delete Media Items
Delete one or more media items.

####Request
- Requires: Authentication
- HTTP Request Method: `DELETE`
- URL: `/media/delete`
- URL Parameters
  - `url_hash`: The URL hash of the media item that should be deleted. This parameter can be repeated to delete multiple items.

####Response
- Status: 204 No Content

***

## Contact
Ethan Lowman
- https://github.com/ethanal
- ethan@ethanlowman.com
