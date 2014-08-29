#Nimbus\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
Nimbus is a private file sharer and URL shortener. Heavily inspired by [Cloudapp](http://www.getcloudapp.com/), Nimbus is a free and open source solution to file sharing and URL shortening that you can host yourself and fully control.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
Nimbus consists of several components:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
* A website that displays sharing pages for generated links and redirects shortened URLs to their targets\n\n\n\n\n\n\n
* A website to manage shared items\n\n\n\n\n\n\n
* An API to manipulate shared items\n\n\n\n\n\n\n
* A Mac OS X menubar app to upload files and shorten links\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
The menubar app is only compatible with OS X 10.9 and up since it is written in [Swift](https://developer.apple.com/swift/). The files are stored in Amazon S3, so you must have an AWS account.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
##Features\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
- Share pages that show file previews or redirect to the shortened link\n\n\n\n\n\n\n
  - Image file previews\n\n\n\n\n\n\n
  - Text file previews with automatic syntax highlighting if applicable\n\n\n\n\n\n\n
- Screenshots are automatically uploaded and the share link is copied to the clipboard\n\n\n\n\n\n\n
- Drag a file or text to the menubar icon to upload it and copy the share link to the clipboard\n\n\n\n\n\n\n
- Drag a URL to the menubar icon to create a shortened link and copy it to the clipboard\n\n\n\n\n\n\n
- Keep track of view counts for files and shortened URLS\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
##Setup\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
To set up the Django app, perform the following steps on your server (assumes [pip](http://pip.readthedocs.org/en/latest/), [virtualenv](http://virtualenv.readthedocs.org/en/latest/), and [MySQL](http://www.mysql.com/) are already installed)\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
1. Create a virtualenv and activate it\n\n\n\n\n\n\n
2. Clone the repository (from here on, it is assumed that the respository's location is `/usr/local/www/Nimbus`)\n\n\n\n\n\n\n
3. While in the repository root, install the Python requirements by running\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
   ```bash\n\n\n\n\n\n\n
   pip install -r requirements/production.txt\n\n\n\n\n\n\n
   ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
4. Create a database and grant a user full access to it5.\n\n\n\n\n\n\n
5. Follow the instructions in `nimbus/settings/secret.sample.py` to create a secrets file with your MySQL and Amazon S3 credentials\n\n\n\n\n\n\n
6. Set up the environment for the Django app by running\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
   ```bash\n\n\n\n\n\n\n
   export PRODUCTION=TRUE\n\n\n\n\n\n\n
   ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
7. Set up the database and create your user by running `./manage.py syncdb`\n\n\n\n\n\n\n
8. Start a Django shell (`./manage.py shell`) and run the following commands, replacing `example.com` with your domain name\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
   ```python\n\n\n\n\n\n\n
   from django.contrib.sites.models import Site\n\n\n\n\n\n\n
   Site.objects.update(name=\\\\\\\"example.com\\\\\\\", domain=\\\\\\\"example.com\\\\\\\")\n\n\n\n\n\n\n
   ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
9. Collect static files by running\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
   ```bash\n\n\n\n\n\n\n
   yes yes | ./manage.py collectstatic\n\n\n\n\n\n\n
   ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Serving Nimbus\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
Make sure you have a domain name configured with the following records:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
@       IN A  <IP address of your server>\n\n\n\n\n\n\n
api     CNAME @\n\n\n\n\n\n\n
account CNAME @\n\n\n\n\n\n\n
files   CNAME files.<your domain name>.s3.amazonaws.com.\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
Also make sure you have an Amazon S3 bucket called `files.<your domain name>`\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
The recommended setup for serving Nimbus is [Gunicorn](http://gunicorn.org/) managed by [Supervisor](http://supervisord.org/) with [nginx](http://nginx.org/) as a reverse proxy. Configuration requirements are as follows.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
* Nginx must be listening on the subdomains `account` and `api` of your domain as well as the root domain. Forward all of this traffic to Gunicorn - the Django app handles the subdomain routing.\n\n\n\n\n\n\n
* The attribute `client_max_body_size` must be set in the nginx config to a sufficiently large value to allow uploads of big files.\n\n\n\n\n\n\n
* Static file requests (`/static/`) should be aliased to `nimbus/collected_static` in the repository root\n\n\n\n\n\n\n
* Supervisor must call the version of gunicorn in your virtualenv\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Example Supervisor Configuration\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
```ini\n\n\n\n\n\n\n
[program:nimbus]\n\n\n\n\n\n\n
directory = /usr/local/www/Nimbus\n\n\n\n\n\n\n
user = nobody\n\n\n\n\n\n\n
command = /usr/local/virtualenvs/Nimbus/bin/gunicorn nimbus.wsgi:application --user=nobody --workers=1 --bind=127.0.0.1:8080\n\n\n\n\n\n\n
environment = PRODUCTION=TRUE\n\n\n\n\n\n\n
stdout_logfile = /var/log/sites/nimbus.gunicorn.log\n\n\n\n\n\n\n
stderr_logfile = /var/log/sites/nimbus.gunicorn.log\n\n\n\n\n\n\n
autostart = true\n\n\n\n\n\n\n
autorestart = true\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Example Nginx Configuration\n\n\n\n\n\n\n
```nginx\n\n\n\n\n\n\n
client_max_body_size 1024M;\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
server {\n\n\n\n\n\n\n
    listen 80;\n\n\n\n\n\n\n
    server_name example.com account.example.com api.example.com;\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
    access_log /var/log/sites/nimbus.access.log;\n\n\n\n\n\n\n
    error_log /var/log/sites/nimbus.error.log;\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
    location /favicon.ico {\n\n\n\n\n\n\n
        alias /usr/local/www/Nimbus/nimbus/static/img/favicon.ico;\n\n\n\n\n\n\n
    }\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
    location /static/ {\n\n\n\n\n\n\n
        alias /usr/local/www/Nimbus/nimbus/collected_static/;\n\n\n\n\n\n\n
    }\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
    location / {\n\n\n\n\n\n\n
        rewrite ^/((?!(api-auth|admin))(.*))/$ /$1 permanent;\n\n\n\n\n\n\n
        proxy_pass http://127.0.0.1:8080;\n\n\n\n\n\n\n
        proxy_set_header X-Forwarded-Host $host;\n\n\n\n\n\n\n
        proxy_set_header Host $host;\n\n\n\n\n\n\n
        proxy_set_header X-Real-IP $remote_addr;\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
    }\n\n\n\n\n\n\n
}\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
##API Reference\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
The Nimbus API uses token authentication, so it is recommended that you secure the `account` and `api` subdomains with HTTPS. The `Authorization` header for requests that require it should have the following form:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
Token 81d1445d307741e63f5c6f26d4e840175c21a34d\n\n\n\n\n\n\n
```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
The term \\\\\\\"media item\\\\\\\" refers to a file or a shortened link.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Obtain Authorization Token\n\n\n\n\n\n\n
Obtain the API authorization token corresponding to a username/password pair.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `POST`\n\n\n\n\n\n\n
- URL: `/api-token-auth`\n\n\n\n\n\n\n
- Parameters\n\n\n\n\n\n\n
  - `username`: The username for the user whose token should be returned\n\n\n\n\n\n\n
  - `password`: The password for the user whose token should be returned\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 200 OK\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  {\n\n\n\n\n\n\n
      \\\\\\\"token\\\\\\\": \\\\\\\"81d1445d307741e63f5c6f26d4e840175c21a34d\\\\\\\"\n\n\n\n\n\n\n
  }\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Errors\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
If the provided credentials are not valid, the following response is returned:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
- Status: 400 Bad Request\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  {\n\n\n\n\n\n\n
      \\\\\\\"non_field_errors\\\\\\\": [\n\n\n\n\n\n\n
          \\\\\\\"Unable to login with provided credentials.\\\\\\\"\n\n\n\n\n\n\n
      ]\n\n\n\n\n\n\n
  }\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###List Media Items\n\n\n\n\n\n\n
List all media items created by the authorized user.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
All media items are serialized the same way. Links and files can be differentiated using the `media_type` attribute.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
Valid media type codes are as follows:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
- `URL`: Shortened URLS\n\n\n\n\n\n\n
- `IMG`: Image files\n\n\n\n\n\n\n
- `TXT`: Text files\n\n\n\n\n\n\n
- `ARC`: Archive files\n\n\n\n\n\n\n
- `AUD`: Audio files\n\n\n\n\n\n\n
- `VID`: Video files\n\n\n\n\n\n\n
- `ETC`: Other files\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `GET`\n\n\n\n\n\n\n
- URL: `/media/list`\n\n\n\n\n\n\n
- Optional URL Parameters:\n\n\n\n\n\n\n
  - `media_type`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 200 OK\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  [\n\n\n\n\n\n\n
      {\n\n\n\n\n\n\n
          \\\\\\\"url_hash\\\\\\\": \\\\\\\"clJwWj\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"share_url\\\\\\\": \\\\\\\"http://example.com/clJwWj\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"name\\\\\\\": \\\\\\\"example.png\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_url\\\\\\\": \\\\\\\"\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_file\\\\\\\": \\\\\\\"de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_file_url\\\\\\\": \\\\\\\"http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"view_count\\\\\\\": 4,\n\n\n\n\n\n\n
          \\\\\\\"upload_date\\\\\\\": \\\\\\\"2014-01-02T03:04:05.060Z\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"media_type\\\\\\\": \\\\\\\"IMG\\\\\\\"\n\n\n\n\n\n\n
      },\n\n\n\n\n\n\n
      {\n\n\n\n\n\n\n
          \\\\\\\"url_hash\\\\\\\": \\\\\\\"i7UrcU\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"share_url\\\\\\\": \\\\\\\"http://example.com/i7UrcU\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"name\\\\\\\": \\\\\\\"http://en.wikipedia.org/wiki/Example\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_url\\\\\\\": \\\\\\\"http://en.wikipedia.org/wiki/Example\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_file\\\\\\\": \\\\\\\"\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"target_file_url\\\\\\\": \\\\\\\"\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"view_count\\\\\\\": 2,\n\n\n\n\n\n\n
          \\\\\\\"upload_date\\\\\\\": \\\\\\\"upload_date\\\\\\\": \\\\\\\"2014-01-02T03:45:06.070Z\\\\\\\",\n\n\n\n\n\n\n
          \\\\\\\"media_type\\\\\\\": \\\\\\\"URL\\\\\\\"\n\n\n\n\n\n\n
      }\n\n\n\n\n\n\n
  ]\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Show Media Item Details\n\n\n\n\n\n\n
Show details for a media item.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `GET`\n\n\n\n\n\n\n
- URL: `/media/show`\n\n\n\n\n\n\n
- URL Parameters:\n\n\n\n\n\n\n
  - `url_hash`: The media type code used to filter the list (e.g. `GET /media/list?media_type=IMG` will list all images)\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 200 OK\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  {\n\n\n\n\n\n\n
      \\\\\\\"url_hash\\\\\\\": \\\\\\\"clJwWj\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"share_url\\\\\\\": \\\\\\\"http://example.com/clJwWj\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"name\\\\\\\": \\\\\\\"example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_url\\\\\\\": \\\\\\\"\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_file\\\\\\\": \\\\\\\"de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_file_url\\\\\\\": \\\\\\\"http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"view_count\\\\\\\": 4,\n\n\n\n\n\n\n
      \\\\\\\"upload_date\\\\\\\": \\\\\\\"2014-01-02T03:04:05.060Z\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"media_type\\\\\\\": \\\\\\\"IMG\\\\\\\"\n\n\n\n\n\n\n
  }\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Upload File\n\n\n\n\n\n\n
Create a media item for a file.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `POST`\n\n\n\n\n\n\n
- URL: `/media/add_file`\n\n\n\n\n\n\n
- Parameters\n\n\n\n\n\n\n
  - `file`: The file to upload.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 201 Created\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  {\n\n\n\n\n\n\n
      \\\\\\\"url_hash\\\\\\\": \\\\\\\"clJwWj\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"share_url\\\\\\\": \\\\\\\"http://example.com/clJwWj\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"name\\\\\\\": \\\\\\\"example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_file\\\\\\\": \\\\\\\"de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_file_url\\\\\\\": \\\\\\\"http://files.example.com/de807a6626ed47c1adf3696bfb2cb9ef/example.png\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"upload_date\\\\\\\": \\\\\\\"2014-01-02T03:04:05.060Z\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"media_type\\\\\\\": \\\\\\\"IMG\\\\\\\"\n\n\n\n\n\n\n
  }\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Add Link\n\n\n\n\n\n\n
Create a media item for a URL.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `POST`\n\n\n\n\n\n\n
- URL: `/media/add_link`\n\n\n\n\n\n\n
- Parameters\n\n\n\n\n\n\n
  - `target_url`: The URL to shorten.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 201 Created\n\n\n\n\n\n\n
- Body:\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
  ```js\n\n\n\n\n\n\n
  {\n\n\n\n\n\n\n
      \\\\\\\"url_hash\\\\\\\": \\\\\\\"i7UrcU\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"share_url\\\\\\\": \\\\\\\"http://example.com/i7UrcU\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"target_url\\\\\\\": \\\\\\\"http://en.wikipedia.org/wiki/Example\\\\\\\",\n\n\n\n\n\n\n
      \\\\\\\"upload_date\\\\\\\": \\\\\\\"2014-01-02T03:45:06.070Z\\\\\\\"\n\n\n\n\n\n\n
  }\n\n\n\n\n\n\n
  ```\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
***\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
###Delete Media Items\n\n\n\n\n\n\n
Delete one or more media items.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Request\n\n\n\n\n\n\n
- Requires: Authentication\n\n\n\n\n\n\n
- HTTP Request Method: `DELETE`\n\n\n\n\n\n\n
- URL: `/media/delete`\n\n\n\n\n\n\n
- URL Parameters\n\n\n\n\n\n\n
  - `url_hash`: The URL hash of the media item that should be deleted. This parameter can be repeated to delete multiple items.\n\n\n\n\n\n\n
\n\n\n\n\n\n\n
####Response\n\n\n\n\n\n\n
- Status: 204 No Content\n\n\n\n\n\n\n
