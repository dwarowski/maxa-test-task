# SVG to PDF converter
## Dependencies
* Ruby v3.4.5
* Rails v8.0.2.1
* Docker v28.3.0
* Docker-Compose v2.38.1

## Startup
### First step: clone repository
```bash
git clone https://github.com/dwarowski/maxa-test-task.git
cd maxa-test-task
```

### Second step: setup configs
#### env
Create .env file and open it using your favorite text editor to set the key (if you don't have a key do credentials first) for rails docker. I`m gonna use nano
```bash
touch .env
nano .env
```

```bash
#---.env---
RAILS_MASTER_KEY=your_master_key
```
#### credentials
 
Usually you keep credentials key and yaml in your team but in this case we going to create a new credentials and a key
```ps
rm -rf credentials
EDITOR="nano" rails credentials:edit -e production
```
This command is going to open nano where you can edit the credentials if you need to. Also this command creates production.key. Change ``your_master_key`` to key inside this file

### Third step: Nginx
Create ssl certifates or use yours
```ps
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./config/nginx/ssl/localhost.key -out ./config/nginx/ssl/localhost.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Org/OU=IT/CN=localhost"
```

### Fourth step: Docker
use docker-compose to setup app
```bash
docker-compose up -d --build
```

## Docs
#### Endpoints
* /documents - multipart-form/image for convertion SVG to PDF returns error or url to converted file 
* /api-docs - swagger
* /documents/example.pdf - converted files where example.pdf is a filename for file on server 
* /* - view (simple frontend)
